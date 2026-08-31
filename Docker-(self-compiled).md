This guide details the **Self-Compiled & Classic CLI-First Docker Deployment** for `hroot`. This method is recommended when you want to modify the source code, add custom features/styling, build from custom Git forks, or perform automated headless server provisioning (e.g. via Ansible or scripts).

---

## 1. Overview & When to Choose Self-Compiled

In this mode, Docker compiles the application image directly on your server from the local source code and `Dockerfile`. All environment variables are pre-configured in `.env` before container launch.

* **When to Choose This Method:**
  * **Custom Code & Feature Modifications:** If your laboratory needs custom modifications in Rails controllers, views, or business logic, building from source compiles your local code directly into the container.
  * **Custom Corporate Design / Assets:** If you are adding institutional logos, custom CSS overrides, or localized templates directly into the source tree.
  * **Local Development & Testing:** Immediate local compilation of new branches or uncommitted changes without waiting for CI/CD pipelines.
  * **Headless / Automated Deployments:** If your IT infrastructure uses Ansible, Terraform, or Puppet to pre-populate `.env` files and provision containers automatically.

---

## 2. Prerequisites

1. **Install Docker and Docker Compose v2:**
   ```bash
   sudo apt update
   sudo apt install docker-compose-v2
   sudo usermod -aG docker $USER # Log out and back in to apply
   ```

2. **Clone the `hroot` Repository:**
   ```bash
   git clone https://github.com/wiso-forschungslabor/hroot.git
   cd hroot
   ```

---

## 3. Step-by-Step CLI Setup

### Step 1: Initialize `.env` and Generate Secrets
Run the included helper script to copy `.env.example` to `.env` and automatically generate cryptographic keys:
```bash
./bin/init-env
```
*This generates a secure `SECRET_KEY_BASE`, WebPush `VAPID` keypair, and randomized MySQL database passwords.*

### Step 2: Configure Environment Variables
Open `.env` in your preferred editor (e.g. `nano .env`) to customize your configuration:
* `APP_DOMAIN`: Your server hostname (e.g. `hroot.example.org` or `localhost`).
* `CONTACT_EMAIL`: Laboratory support/contact email address.
* `DATABASE_*`: Database credentials (if connecting to an external database).
* `SMTP_*`: Outgoing mail server configuration.
* *(See [Environment Configuration](Environment-Configuration.md) for the complete variable catalog).*

### Step 3: Build & Start Containers
Compile the Docker image locally and start the services in background:
```bash
docker compose up -d --build
```
*(The `--build` flag ensures that your local source code, gems, and assets are freshly compiled into the image).*

### Step 4: Run Initial Database Setup & Create Administrator
Initialize the MySQL schema, load lookup tables, and create the initial banking administrator account via CLI:
```bash
docker compose exec web bin/docker-setup
```

---

## 4. Choose Your Compose Mode

Depending on your server architecture, you can apply Compose override files:

### Scenario A: Standalone Docker (Standard Setup)
```bash
docker compose up -d --build
```

### Scenario B: Multi-Instance / Shared Proxy Setup
```bash
docker compose -p <project-name> -f docker-compose.yml -f docker/overrides/shared-proxy.yml up -d --build
```
*(See **[Docker Multi-Instance Setup](Docker-Multi-Instance-Setup.md)** for central reverse proxy configuration).*

### Scenario C: App-Only Setup (External Host-Nginx)
```bash
docker compose -f docker-compose.yml -f docker/overrides/app-only.yml up -d --build
```

### Scenario D: External Database
```bash
docker compose -f docker-compose.yml -f docker/overrides/ext-db.yml up -d --build
```

---

## 5. Recompiling After Code Changes

When you update or customize the code in your repository, recompile the container image:
```bash
# 1. Pull or edit your code changes
git pull

# 2. Rebuild and restart containers
docker compose up -d --build

# 3. Run any new database migrations if applicable
docker compose exec web bin/rails db:migrate
```
