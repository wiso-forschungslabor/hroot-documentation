This guide details the **Precompiled Zero-Touch Docker Deployment** for `hroot`. This is the recommended deployment method for standard production environments, academic laboratories, and universities that want a fast, reliable, and maintenance-free setup.

---

## 1. Overview & Key Advantages

In this mode, container images are pulled directly from the GitHub Container Registry (`ghcr.io/wiso-forschungslabor/hroot:latest` or your own custom fork's image). App secrets (`SECRET_KEY_BASE`, WebPush VAPID keypairs, and internal database credentials) are generated automatically on the first launch.

* **Key Advantages:**
  * **Instant Zero-Touch Start:** No time-consuming gem/asset compilation on your server, and no manual code cloning required to run the application.
  * **Full In-Browser Setup:** Database choice (internal Compose DB vs. external MySQL/MariaDB), schema migrations, SMTP/IMAP mail settings, and initial banking administrator account creation are completed directly through the Setup Wizard at `/setup`.
  * **Support for Custom Forks:** Laboratories maintaining their own fork on GitHub can build their own precompiled images via GitHub Actions and deploy them just as easily.
  * **One-Click In-App Updates:** Seamless version checks and automated updates directly in the Admin UI (`/admin/options/check`).

---

## 2. Prerequisites & Registry Authentication

1. **Install Docker Engine and Docker Compose v2:**
   ```bash
   sudo apt update
   sudo apt install docker.io docker-compose-v2 -y
   sudo usermod -aG docker $USER # Log out and back in to apply
   ```

2. **Registry Authentication (`ghcr.io`):**  
   For private repositories and private container packages, log in once on your server using your GitHub username and a Personal Access Token (with `read:packages` permission):
   ```bash
   echo $GITHUB_PAT | docker login ghcr.io -u <github-username> --password-stdin
   ```

---

## 3. Quickstart Installation

You can install HROOT using the automated **Interactive One-Line Installer** or manually with a **Minimal 2-Step Setup**:

### Option 1: Interactive One-Line Installer (Recommended)

Run the public bootstrap installation wizard directly in your server terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/wiso-forschungslabor/hroot-documentation/master/install.sh | bash
```

The installer will guide you through:
1. **GitHub Authentication:** Prompts for your GitHub Username and Personal Access Token (PAT with `repo` and `read:packages` scopes) to authenticate Docker with `ghcr.io`.
2. **Target Folder:** Select where HROOT files should be stored (Default: `./hroot`).
3. **Repository & Image:** Choose between the official upstream repository (`wiso-forschungslabor/hroot`) or your own custom GitHub Fork (`<your-account>/hroot`).
4. **Application Domain:** Enter your target domain (e.g. `hroot.example.org` or `localhost:3000`).
5. **Setup Token:** Automatically generates a secure `HROOT_SETUP_TOKEN` to protect `/setup`.
6. **Start:** Automatically writes `.env`, downloads `docker-compose.yml`, and launches the containers (`docker compose up -d`).


---

### Option 2: Minimal Manual 2-Step Setup

If you prefer to start manually without the installer:

1. **Create folder and download `docker-compose.yml`:**
   ```bash
   mkdir -p /srv/hroot && cd /srv/hroot
   curl -O https://raw.githubusercontent.com/wiso-forschungslabor/hroot/master/docker-compose.yml
   ```

2. **Launch containers with domain & setup token:**
   * **For Official Upstream Image:**
     ```bash
     APP_DOMAIN=hroot.example.org HROOT_SETUP_TOKEN=your-secure-setup-token docker compose up -d
     ```
   * **For Custom Fork Image:**
     ```bash
     HROOT_IMAGE=ghcr.io/<your-account>/hroot:latest UPDATE_GITHUB_REPO=<your-account>/hroot APP_DOMAIN=hroot.example.org HROOT_SETUP_TOKEN=your-secure-setup-token docker compose up -d
     ```

---

## 4. Complete Configuration in the Web Setup Wizard

Once the containers are running:

1. Open **`https://<APP_DOMAIN>/setup`** (or `http://localhost:3000/setup`) in your web browser.
2. Enter your **`HROOT_SETUP_TOKEN`** to unlock the assistant.
3. Complete the tabs:
   * **Database:** Select internal Docker DB or external MySQL/MariaDB server, click *„Test Connection“*, and then *„Initialize DB“*.
   * **E-Mail & IMAP:** Enter `CONTACT_EMAIL` and SMTP server credentials, then verify using *„Send Test E-Mail“*.
   * **First Superuser:** Enter name, email, and password for your initial banking administrator.
4. Click **Finish initial setup** to save settings and sign in to `hroot`.

---

## 5. Architectural Scenarios (Compose Override Modes)

Depending on your server infrastructure (as defined in the [Installation](Installation.md) Decision Matrix), choose the appropriate execution scenario:

### Scenario A: Standalone Docker (Standard Setup)
*Best for: A dedicated server running only a single `hroot` instance, where Docker handles SSL automatically on ports 80/443.*

```bash
docker compose up -d
```

---

### Scenario B: Multi-Instance / Shared Proxy Setup
*Best for: Hosting multiple independent laboratories or multiple `hroot` instances (e.g. testing, staging, and production) on the same server.*

This setup routes multiple instances through a central reverse proxy (`nginxproxy/nginx-proxy`) with automated Let's Encrypt SSL certificates.

* To start an instance connecting to a shared proxy:
  ```bash
  docker compose -p <project-name> -f docker-compose.yml -f docker/overrides/shared-proxy.yml up -d
  ```
* **Full Guide & Multi-Lab Example**: For the complete architecture explanation, central proxy setup, and a step-by-step example running 3 parallel instances, see **[Docker Multi-Instance Setup](Docker-Multi-Instance-Setup.md)**.

---

### Scenario C: App-Only Setup (External Host-Nginx / Apache)
*Best for: Serving `hroot` behind an existing NGINX or Apache web server already running directly on the Linux host.*

```bash
docker compose -f docker-compose.yml -f docker/overrides/app-only.yml up -d
```

---

### Scenario D: External Database Server
*Best for: Connecting `hroot` to an existing, centralized university MySQL/MariaDB server cluster.*

```bash
docker compose -f docker-compose.yml -f docker/overrides/ext-db.yml up -d
```

---

## 6. In-App Updates (One-Click)

Administrators can check for updates and trigger system upgrades directly in the web application:
1. Navigate to **Admin $\rightarrow$ Options $\rightarrow$ System Check & Updates** (`/admin/options/check`).
2. Compare the installed Git commit with the latest release available on GitHub.
3. Click **Update System Now** to trigger an automated, fail-safe update cycle:
   * **1. Database Snapshot:** A safety dump of MySQL is saved prior to any changes.
   * **2. Fast Image Download:** The new Docker layer is downloaded from `ghcr.io`.
   * **3. Schema Migrations:** `rake db:migrate` runs in isolation.
   * **4. Health Check:** The container starts and readiness is polled for up to 180 seconds.
   * **5. Automated Rollback:** If any error occurs, the previous image and database state are restored.

*For a detailed comparison of all update methods (including CLI and source-build updates), see **[Updating an existing installation](Updating-an-existing-installation.md)**.*

