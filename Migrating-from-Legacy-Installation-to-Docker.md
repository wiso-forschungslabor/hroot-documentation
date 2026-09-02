This guide details the complete migration path for upgrading an existing, older `hroot` installation (v2.x / v3.x installed directly on bare-metal with Apache/Nginx, Phusion Passenger/Puma, RVM, and legacy settings in `config/environments/production.rb`) to the modern, containerized **hroot v4.0+ Docker architecture**.

---

## 1. Decision Guide: Precompiled Image vs. Self-Compiled Build

Before migrating, choose the Docker deployment flavor that best matches your laboratory's infrastructure:

| Feature / Criterion | Option A: Precompiled Docker Image (Recommended) | Option B: Self-Compiled Docker Build (Source Code) |
| :--- | :--- | :--- |
| **Best For** | Standard production deployments, university labs wanting zero maintenance overhead. | Custom forks, laboratories with local code modifications, or air-gapped environments. |
| **Image Source** | Pulled pre-built from GitHub Container Registry (`ghcr.io`). | Compiled locally on the server from cloned Git repository. |
| **Server CPU / RAM Needed** | **Minimal** (No compilation needed on server). | **Moderate** (Server builds Ruby gems & precompiles assets). |
| **Setup Speed** | **Instant** (Seconds to pull & start). | **5–10 minutes** (Initial image build time). |
| **In-App 1-Click Updates** | **Full Support** via Admin UI (`/admin/options/check`). | Manual / CLI updates (`git pull && docker compose up -d --build`). |
| **Registry Authentication** | Requires one-time `docker login ghcr.io` (for private repos). | No registry login needed (builds locally). |
| **Dedicated Guide** | **[Docker (precompiled)](Docker-(precompiled).md)** | **[Docker (self-compiled)](Docker-(self-compiled).md)** |

---

## 2. Overview: What Changed in hroot v4.0?

| Area | Legacy hroot (v2.x / v3.x) | Modern hroot (v4.0+) |
| :--- | :--- | :--- |
| **Runtime & Hosting** | Direct on Linux host (Apache + Passenger, Puma, RVM) | **Docker & Docker Compose** (isolated containers) |
| **Configuration** | Hardcoded in `config/environments/production.rb` & `database.yml` | **Central `.env` environment variables** or **Web Setup Wizard** |
| **Secrets & Keys** | Hardcoded in files or `secrets.yml` | **Auto-generated `SECRET_KEY_BASE` & `VAPID` keys** |
| **Background Tasks** | Host crontab via manual `whenever --update-crontab` | **Automated `cron` container** in Docker Compose |
| **Ruby Version** | Legacy Ruby 2.7 / 3.0 / 3.2 via RVM | **Ruby 3.3 / 4.0** managed automatically inside container |
| **Update Process** | Manual 10-step CLI procedure on host OS | **1-Click Auto-Update** or `docker compose pull` |

---

## 3. Pre-Migration Checklist

Before starting the migration, ensure you have:
1. Root or `sudo` access to your server.
2. Sufficient disk space for database dumps and Docker images (~5–10 GB recommended).
3. Scheduled maintenance window for your research laboratory.
4. If using **Option A (Precompiled Image)** with a private repository: A GitHub Personal Access Token (PAT) with `read:packages` permission.

---

## 4. Step-by-Step Migration Procedure

### Step 1: Create Full Backups of Existing Data

1. **Export the Legacy MySQL Database:**
   ```bash
   mysqldump -u <db_user> -p --single-transaction --routines --triggers <db_name> > ~/hroot_legacy_backup_$(date +%Y%m%d_%H%M).sql
   ```
2. **Back Up Uploaded Files (Participant Documents, Attachments):**
   ```bash
   cp -r /path/to/old/hroot/public/uploads ~/hroot_uploads_backup
   ```

---

### Step 2: Deactivate Old Host Services & Clear Host Crontab

To prevent background tasks from executing twice or ports (80/443/3000) colliding with Docker:

1. **Clear Legacy Host Crontab:**
   ```bash
   cd /path/to/old/hroot
   RAILS_ENV=production bundle exec whenever --clear-crontab
   ```
2. **Stop and Disable Old Web Services:**
   * *If using Apache / Passenger:*
     ```bash
     sudo systemctl stop apache2
     sudo systemctl disable apache2
     ```
   * *If using NGINX / Puma / Systemd service:*
     ```bash
     sudo systemctl stop hroot nginx
     sudo systemctl disable hroot nginx
     ```

---

### Step 3: Install Docker Engine and Docker Compose v2

On your Ubuntu/Debian server:
```bash
sudo apt update
sudo apt install docker.io docker-compose-v2 -y
sudo usermod -aG docker $USER
# Log out and back in to apply group changes
```
*(Note: `docker.io` installs the underlying Docker daemon/engine, while `docker-compose-v2` installs the modern `docker compose` CLI orchestration plugin).*

---

### Step 4: Set Up New hroot 4.0 Directory & Configuration

1. **Clone the modern hroot repository:**
   ```bash
   git clone https://github.com/wiso-forschungslabor/hroot.git /srv/hroot
   cd /srv/hroot
   ```
   *(If using a custom fork: `git clone https://github.com/<your-account>/hroot.git /srv/hroot`)*

   > [!NOTE]
   > **Why clone the repository when using precompiled Docker images?**  
   > Cloning the repository provides the required orchestration configuration files ([`docker-compose.yml`](file:///srv/hroot/docker-compose.yml), initialization script `bin/init-env`, `.env.example`, and directory structure for persistent volume mounts like `uploads/`).  
   > When choosing **Option A (Precompiled Images)**, you will **not compile any code** on your server — Docker Compose directly pulls the pre-built image from `ghcr.io`.

2. **Initialize Environment Configuration:**
   ```bash
   chmod +x bin/init-env
   ./bin/init-env
   ```
   *This automatically generates secure random keys for `SECRET_KEY_BASE`, WebPush `VAPID` keypairs, and internal database passwords.*

3. **Extract Configuration to `.env`:**
   Open `/path/to/old/hroot/config/environments/production.rb` and configure your laboratory settings in `/srv/hroot/.env`:

   | Old Setting in `production.rb` | New Variable in `.env` | Example |
   | :--- | :--- | :--- |
   | `config.action_mailer.default_url_options = { host: '...' }` | `APP_DOMAIN` | `APP_DOMAIN=hroot.uni-hamburg.de` |
   | `config.action_mailer.smtp_settings = { address: '...' }` | `SMTP_ADDRESS` | `SMTP_ADDRESS=mail.uni-hamburg.de` |
   | `config.action_mailer.smtp_settings = { port: ... }` | `SMTP_PORT` | `SMTP_PORT=587` |
   | `config.action_mailer.smtp_settings = { user_name: '...' }` | `SMTP_USER_NAME` | `SMTP_USER_NAME=hroot-mailer` |
   | `config.action_mailer.smtp_settings = { password: '...' }` | `SMTP_PASSWORD` | `SMTP_PASSWORD=secret` |
   | `HROOT_SETTINGS[:contact_email]` | `CONTACT_EMAIL` | `CONTACT_EMAIL=labor@uni-hamburg.de` |
   | `HROOT_SETTINGS[:sender_email]` | `SENDER_EMAIL` | `SENDER_EMAIL=noreply@uni-hamburg.de` |
   | `HROOT_SETTINGS[:log_email]` | `LOG_EMAIL` | `LOG_EMAIL=admin@uni-hamburg.de` |

4. **Choose Your Target Database Architecture:**

   > [!TIP]
   > **Architecture Recommendation:**  
   > * **Option A (External Database Server):** If your university or IT department operates a dedicated MySQL/MariaDB database cluster with central backup strategies and high availability, keeping an **external database server** is the **recommended enterprise choice** for security and ease of disaster recovery.
   > * **Option B (Internal Docker MySQL Container):** If you want a self-contained all-in-one server with minimal administration overhead, Docker's internal MySQL container (`DATABASE_HOST=db`) manages everything in one place.

---

### Step 5: Restore Database & User Uploads

#### Scenario A: Migrating to Docker's Internal MySQL Container (`DATABASE_HOST=db`)
*Use this scenario if you want Docker to manage the database locally on the server (whether your old database was on the host or on an external server):*

1. Start only the MySQL database container:
   ```bash
   docker compose up -d db
   ```
2. Wait 10 seconds for MySQL initialization, then import your legacy database dump:
   ```bash
   docker compose exec -T db mysql -u root -p${MYSQL_ROOT_PASSWORD:-rootpassword} ${DATABASE_NAME:-hroot_production} < ~/hroot_legacy_backup_*.sql
   ```

#### Scenario B: Keeping an External Database Server (`DATABASE_HOST=<external_ip_or_host>`)
*Use this scenario if your existing database remains on a central external database server:*

1. Set `DATABASE_HOST`, `DATABASE_USERNAME`, `DATABASE_PASSWORD`, and `DATABASE_NAME` in `.env` to point to your external database server.
2. No import command is required into Docker — HROOT will connect directly to your existing database during container launch and apply schema migrations in Step 7.
3. Verify that your database user permissions permit running migrations (`ALTER TABLE`, `CREATE TABLE`, `ADD COLUMN`).

#### Restore User Uploads (Both Scenarios):
Copy the legacy uploads folder (participant documents, attachments) into the new Docker storage volume directory:
```bash
cp -r ~/hroot_uploads_backup/* /srv/hroot/uploads/
```


---

### Step 6: Launch Containers

Choose your deployment mode:

#### Option A: Precompiled Docker Image (Recommended)
1. Authenticate with GitHub Container Registry (one-time if using private repo/packages):
   ```bash
   docker login ghcr.io -u <your-github-username>
   ```
2. Start the services:
   ```bash
   docker compose up -d
   ```

#### Option B: Self-Compiled Docker Build (From Source)
1. Build and launch containers locally:
   ```bash
   docker compose up -d --build
   ```

---

### Step 7: Apply Database Migrations & Complete Setup via Wizard

You can finalize the migration using either the **In-Browser Setup Wizard** or the **CLI**:

#### Method 1: Using the In-Browser Setup Wizard (Recommended)
1. Open your browser at **`https://<APP_DOMAIN>/setup`** (or `http://localhost:3000/setup`).
2. Unlock the wizard using your `HROOT_SETUP_TOKEN` (defined in `.env`).
3. Select **„Upgrade from v3.x to v4.0 (Existing Database)“** in the Setup Type selector at the top.
4. Under the **Banking-Admin** tab:
   * If your legacy database does not have a user with the new `banking_admin` role, choose **„Promote an existing administrator to Banking-Admin“** from the dropdown list.
5. In the sidebar under **Database Status & Schema**:
   * Click **„Test Connection“** — HROOT verifies connectivity, detects your legacy user records, and counts pending v4 migrations.
   * Verify under **Database & Secrets** that your database connection preset (Internal Docker DB vs. External MySQL Server) is configured.
6. Click **„Run v4 Upgrade & Complete Setup“** — HROOT automatically applies all v4 schema migrations safely (`db:migrate`) without altering any participant or experiment data, promotes your administrator account, and completes setup.

#### Method 2: Using the Command Line
Run the schema migrations manually via Docker Compose:
```bash
docker compose exec web bin/rails db:migrate
```

---

### Step 8: Post-Migration Verification

1. **Verify Services & Cron Container:**
   ```bash
   docker compose ps
   docker compose logs -f cron
   ```
   *Confirm that background tasks (invitation queue, digest emails, IMAP bounce handlers) are operating normally.*
2. Sign in with an existing administrator account.
3. Check **Admin $\rightarrow$ Options $\rightarrow$ System Check & Updates** (`/admin/options/check`) to verify environment status.
4. Create a test experiment session to verify participant booking, email confirmations, and calendar synchronization.

