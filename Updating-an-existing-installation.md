# Updating an Existing Installation

This guide covers all update workflows for `hroot`, ranging from seamless **One-Click In-App updates** to manual bare-metal command-line upgrades.

> [!IMPORTANT]
> **Safety First:** Before performing any update or schema migration, always ensure a full database backup (`mysqldump`) and a copy of your uploaded files (`uploads/`) exist.

---

## Table of Contents

* [Update Methods Comparison Matrix](#update-methods-comparison-matrix)
* [1. In-App One-Click Auto-Update (Admin UI)](#1-in-app-one-click-auto-update-admin-ui)
* [2. Docker Update with Precompiled Image (`docker compose pull`)](#2-docker-update-with-precompiled-image-docker-compose-pull)
* [3. Docker Update with Source Code Build (`docker compose up -d --build`)](#3-docker-update-with-source-code-build-docker-compose-up--d---build)
* [4. Manual Bare-Metal Update (Legacy CLI)](#4-manual-bare-metal-update-legacy-cli)
* [5. Major Version Migration: Upgrading from Legacy hroot (v3.x) to v4.0](#5-major-version-migration-upgrading-from-legacy-hroot-v3x-to-v40)
* [6. Merging Upstream Updates & Building Images for Custom Forks](#6-merging-upstream-updates--building-images-for-custom-forks)


---

## Update Methods Comparison Matrix

The table below explains what actions are required across the four different update methods:

| Step / Action | 1. In-App Auto-Update | 2. Docker Precompiled Image | 3. Docker Source Build | 4. Manual Bare-Metal Update |
| :--- | :--- | :--- | :--- | :--- |
| **Trigger Mechanism** | Admin Web UI button | `docker compose pull` | `docker compose up -d --build` | Manual shell commands |
| **Safety DB Snapshot** | **Automated** (Pre-update dump) | Manual command | Manual command | Manual command |
| **`bundle install`** | **Pre-packaged in Image** (0s) | **Pre-packaged in Image** (0s) | **Automated** in Docker build stage | Manual `bundle install` |
| **`assets:precompile`** | **Pre-compiled in Image** (0s) | **Pre-compiled in Image** (0s) | **Automated** in Docker build stage | Manual `rake assets:precompile` |
| **Database Migrations** | **Automated** in isolated container | **Automated** via container entrypoint | Executed via `bin/rails db:migrate` | Manual `rake db:migrate` |
| **Background Cronjobs** | **Automated** (`cron` container) | **Automated** (`cron` container) | **Automated** (`cron` container) | Manual `whenever --update-crontab` |
| **Web Server Restart** | **Automated** (Zero-downtime reload) | **Automated** container restart | **Automated** container restart | `touch tmp/restart.txt` / systemd |
| **Health Check & Rollback** | **Automated 5-stage rollback** | Manual container rollback | Manual git rollback | Manual database & code restore |

---

## 1. In-App One-Click Auto-Update (Admin UI)

*Best for: Production installations using standard Docker deployment (`ghcr.io` image).*

Administrators can check for updates and trigger upgrades directly within the web interface without opening a server terminal:

1. Sign in as a **Banking Administrator**.
2. Navigate to **Admin $\rightarrow$ Options $\rightarrow$ System Check & Updates** (`/admin/options/check`).
3. The system compares your installed Git commit against the latest release on GitHub:
   * 🟢 **System is up to date:** No action required.
   * 🟡 **Update Available:** Displays the new version, commit message, and changes.
4. Click **Update System Now** to trigger the automated 5-stage update pipeline:
   * **Stage 1 (Database Snapshot):** A safety dump of your MySQL database is saved to `tmp/backups/`.
   * **Stage 2 (Image Download):** The new Docker image layer is downloaded from `ghcr.io` in background.
   * **Stage 3 (Schema Migration):** Database migrations (`db:migrate`) execute safely inside an isolated container.
   * **Stage 4 (Health Check):** The new application container starts and polls readiness for up to 180 seconds.
   * **Stage 5 (Automatic Rollback):** If any error occurs or the health check fails, the previous image and database state are restored automatically.

---

## 2. Docker Update with Precompiled Image (`docker compose pull`)

*Best for: Production Docker setups managed via command line or automated server cronjobs.*

1. **Create a quick database backup:**
   ```bash
   docker compose exec db mysqldump -u hroot -p${DATABASE_PASSWORD} ${DATABASE_NAME:-hroot_production} > backup_pre_update_$(date +%F).sql
   ```
2. **Pull the latest precompiled Docker image from `ghcr.io`:**
   ```bash
   docker compose pull
   ```
3. **Restart containers with the updated image:**
   ```bash
   docker compose up -d
   ```
   *The container entrypoint automatically executes `db:prepare` to apply any new database schema migrations.*
4. **Verify container logs:**
   ```bash
   docker compose logs -f web cron
   ```

---

## 3. Docker Update with Source Code Build (`docker compose up -d --build`)

*Best for: Laboratories running custom code modifications, forks, or self-compiled deployments.*

1. **Create a database backup:**
   ```bash
   docker compose exec db mysqldump -u hroot -p${DATABASE_PASSWORD} ${DATABASE_NAME:-hroot_production} > backup_pre_update_$(date +%F).sql
   ```
2. **Pull latest source code updates:**
   ```bash
   git pull origin master  # or your customized branch / tag
   ```
3. **Check for new environment variables:**
   ```bash
   diff -u .env .env.example
   ```
4. **Rebuild the Docker image and restart services:**
   ```bash
   docker compose up -d --build
   ```
   *Docker compiles new Ruby gems and precompiles frontend assets during the multi-stage build process.*
5. **Run database migrations:**
   ```bash
   docker compose exec web bin/rails db:migrate
   ```
6. **Verify operation:**
   ```bash
   docker compose logs -f web cron
   ```

---

## 4. Manual Bare-Metal Update (Legacy CLI)

*Best for: Legacy servers without Docker (running directly on Ubuntu with native Ruby, rbenv, Passenger/Puma, and MySQL).*

Follow these steps sequentially:

1. **Create a full database backup:**
   ```bash
   mysqldump -u <db_user> -p <db_name> > backup_pre_update_$(date +%F).sql
   ```
2. **(Optional) Enable Maintenance Page:**
   ```bash
   RAILS_ENV=production bundle exec rake rack:turnout:down[reason="Scheduled Maintenance Update"]
   ```
3. **Pull latest source code:**
   ```bash
   git pull origin master
   ```
4. **Check environment variables:**
   ```bash
   diff -u .env .env.example
   ```
5. **Check Ruby version:**  
   Ensure your active Ruby matches `.ruby-version` (e.g. `4.0.6`):
   ```bash
   ruby -v
   # If an upgrade is required: rbenv install 4.0.6 && rbenv global 4.0.6
   ```
6. **Install / Update Ruby Gems:**
   ```bash
   bundle install
   ```
7. **Run Database Migrations:**
   ```bash
   RAILS_ENV=production bin/rails db:migrate
   ```
8. **Recompile Frontend Assets:**
   ```bash
   RAILS_ENV=production bin/rails assets:clobber
   RAILS_ENV=production bin/rails assets:precompile
   ```
9. **Update Background Jobs in Crontab (`whenever`):**
   ```bash
   RAILS_ENV=production bundle exec whenever --update-crontab
   ```
10. **Restart the Web Server:**
    * *Phusion Passenger:*
      ```bash
      touch tmp/restart.txt
      ```
    * *Systemd / Puma / NGINX / Apache:*
      ```bash
      sudo systemctl restart hroot nginx   # or apache2
      ```
11. **Disable Maintenance Page:**
    ```bash
    RAILS_ENV=production bundle exec rake rack:turnout:up
    ```

---

## 5. Major Version Migration: Upgrading from Legacy hroot (v3.x) to v4.0

If your laboratory is upgrading from an older major version of `hroot` (v2.x / v3.x with hardcoded settings in `production.rb`, `database.yml`, RVM, and bare-metal Apache/Passenger), choose one of the following two dedicated upgrade paths:

### Path A: Migrate from Legacy Bare-Metal to Modern Docker v4.0 (Recommended)
Switch your installation to containerized Docker deployment for 1-click updates, isolated dependencies, and zero maintenance overhead.
👉 **Read the guide:** **[Migrating from Legacy Installation to Docker](Migrating-from-Legacy-Installation-to-Docker.md)**

### Path B: Upgrade Legacy Bare-Metal to Bare-Metal v4.0 (Native Non-Docker)
Keep your installation running directly on the Linux host with system Ruby, rbenv, Passenger/Puma, and MySQL, while upgrading the codebase to v4.0 and migrating configuration into `.env`.
👉 **Read the guide:** **[Upgrading Bare Metal from v3 to v4](Upgrading-Bare-Metal-from-v3-to-v4.md)**

---

## 6. Merging Upstream Updates & Building Images for Custom Forks

If your laboratory or institution maintains a custom fork of `hroot` (e.g. `https://github.com/<your-account>/hroot`):

> [!CAUTION]
> **Strict Privacy & Licensing Notice:**
> Any Docker images built from your fork on GitHub Container Registry (`ghcr.io`) **MUST remain Private** (`Private Packages`). Making the container image public makes the underlying source code accessible to the public, which constitutes a **violation of the software license / terms of use**. Ensure in your GitHub Package Settings that the image visibility is set to **Private**.

---

### Step 1: Merge Upstream Updates into Your Fork

To pull in updates published to the official `wiso-forschungslabor/hroot` repository:

1. **Commit any local custom changes:**
   ```bash
   git status
   git add . && git commit -m "Save local customizations"
   ```
2. **Add upstream repository as a remote (one-time setup):**
   ```bash
   git remote add upstream https://github.com/wiso-forschungslabor/hroot.git
   ```
3. **Fetch and merge latest upstream releases:**
   ```bash
   git fetch upstream
   git merge upstream/master
   ```
4. **Push the merged changes to your fork:**
   ```bash
   git push origin master  # or your customized branch
   ```

---

### Step 2: Build the Docker Image in Your Fork

You can build and publish your customized Docker image to `ghcr.io/<your-account>/hroot` using GitHub Actions:

1. **Enable GitHub Actions in your Fork (one-time setup):**
   * Go to your forked repository on GitHub $\rightarrow$ **Actions** tab.
   * Click **"I understand my workflows, go ahead and enable them"** if prompted.
2. **Trigger the Docker Build:**
   * **Option A (Via Git Tag):** Create and push a version tag matching `v*`:
     ```bash
     git tag v4.1.0-myCustomVersion
     git push origin v4.1.0-myCustomVerision
     ```
   * **Option B (Manual UI Trigger):** Go to GitHub $\rightarrow$ **Actions** $\rightarrow$ select **"Build and Publish Docker Image"** $\rightarrow$ click **Run workflow** $\rightarrow$ select your branch and click **Run workflow**.

GitHub Actions will automatically build the image and push it to `ghcr.io/<your-account>/hroot`.

---

### Step 3: Configure HROOT to Use Your Fork Image & Update Routine

To allow your server and the built-in In-App One-Click Update Routine (or `docker compose pull`) to track your custom fork (one-time-setup, after that, the system will automatically use that fork & Branch to check for updates):

1. **Configure your server's `.env` file:**
   ```env
   # Point Docker Compose to your fork's image
   HROOT_IMAGE=ghcr.io/<your-account>/hroot:latest

   # Point the In-App Update Checker to your GitHub repository and branch
   UPDATE_GITHUB_REPO=<your-account>/hroot
   UPDATE_BRANCH=master  # or your tracking branch
   ```

2. **Authenticate Docker with GitHub Container Registry (for Private Packages):**
   Since your fork's image is private, log in with a GitHub Personal Access Token (PAT with `read:packages` scope):
   ```bash
   echo $GITHUB_PAT | docker login ghcr.io -u <your-github-username> --password-stdin
   ```

3. **Deploy or Update:**
   * **Via Web UI:** Go to **Admin $\rightarrow$ Options $\rightarrow$ System Check & Updates** and click **Update System Now**.
   * **Via Terminal:** Run:
     ```bash
     docker compose pull && docker compose up -d
     ```

