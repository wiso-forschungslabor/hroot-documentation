# System Requirements & Deployment Prerequisites


Before installing `hroot`, ensure that your hosting environment, network infrastructure, email services, and user permissions meet the technical requirements outlined below.

---

## 1. Hardware & Operating System

| Component | Minimum Specification | Recommended Specification |
| :--- | :--- | :--- |
| **Operating System** | Linux (Ubuntu 22.04/24.04 LTS, Debian 12, RHEL / AlmaLinux 9) | Ubuntu 24.04 LTS or Debian 12 (64-bit x86_64) |
| **CPU** | 1 vCPU (Core) | 2–4 vCPUs for large subject pools & parallel sessions |
| **Memory (RAM)** | 2 GB RAM | 4 GB RAM (ensures fast Rails caching, database buffering & background workers) |
| **Disk Space** | 10 GB free storage | 25+ GB SSD (for Docker images, MySQL volumes, database backups, file uploads) |

---

## 2. Network, Domain & DNS Requirements

1. **Fully Qualified Domain Name (FQDN):**
   * A dedicated public domain or university subdomain (e.g. `hroot.wiso.uni-hamburg.de` or `lab-recruitment.example.org`).
   * **DNS A-Record / AAAA-Record:** Must point directly to the public IP address of your server.
2. **Firewall & Port Availability:**
   * **Port 80 (HTTP) & Port 443 (HTTPS):** Inbound traffic must be permitted for web clients and automatic SSL certificate generation (via Let's Encrypt / ACME Companion).
   * **Port 3000 (Internal/Custom Proxy):** Required only if HROOT is operated behind an existing university reverse proxy (e.g. institutional NGINX, Apache, Traefik, or Cloudflare Tunnel).
   * **Outbound Internet Access (Port 443):** Required for pulling container images from GitHub Container Registry (`ghcr.io`) and receiving automated updates.

---

## 3. Mailing & Email Service Requirements (Critical)

Email communication is the core mechanism of HROOT for participant recruitment, invitation waves, session reminders, and login codes.

### Outgoing E-Mail (SMTP)
* **SMTP Server:** A reliable SMTP server or institutional mail relay (e.g. `smtp.uni-hamburg.de`).
* **Port & Security:** Port 587 (STARTTLS) or Port 465 (SSL/TLS). Port 25 without authentication is supported for local university relays.
* **Credentials:** Valid SMTP username and password.
* **Sender Addresses:**
  * `SENDER_EMAIL`: Address from which emails are sent (e.g. `recruitment@uni-hamburg.de`).
  * `CONTACT_EMAIL`: Reply-to address visible to participants.
* **Throughput Allowance:** Ensure your mail relay allows sending bulk invitation waves (e.g. 500–2,000 emails/hour) without triggering aggressive spam blocks.

### Incoming E-Mail (IMAP / Optional but Strongly Recommended)
* **Purpose:** Enables HROOT to automatically read incoming participant replies, process bounce notifications, and handle unsubscribe requests.
* **Requirements:** IMAP host (e.g. `imap.uni-hamburg.de`), Port 993 (SSL), username, password, and folder name (default: `INBOX`).

---

## 4. Software & User Permission Requirements (Non-Root / Sudo-Free)

HROOT is engineered to run in **unprivileged user-space** without requiring permanent `root` or `sudo` privileges during installation and operations.

### One-Time Server Preparation (By System Administrator)
```bash
# 1. Install Docker Engine & Compose plugin (v2)
sudo apt update && sudo apt install docker.io docker-compose-v2 -y

# 2. Add your service user (e.g. 'hroot' or 'labadmin') to the docker group
sudo usermod -aG docker $USER

# 3. Apply group membership (or log out and back in)
newgrp docker
```

### Installation Rights (By Laboratory Operator / Normal User)
* **No `sudo` required:** As long as the operating user belongs to the `docker` group, the entire installation, secret generation, and container management run **100% unprivileged**.
* All application files, `.env` configurations, and uploads are stored in the user's home directory (e.g. `~/hroot` or `/srv/hroot`).

---

## 5. Software License & GitHub Access

* **Access Authorization:** An authorized grant to access the private HROOT repository (`wiso-forschungslabor/hroot` or an authorized fork) is required.
  * Information and licensing details: [https://uhh.de/wiso-hroot-info](https://uhh.de/wiso-hroot-info).
* **GitHub Personal Access Token (PAT):**
  * A classic GitHub token with **`repo`** (Private repository access) and **`read:packages`** (GitHub Container Registry `ghcr.io` download) scopes.

---

## 6. Optional Feature Prerequisites

| Feature | Technical Prerequisites | Purpose |
| :--- | :--- | :--- |
| **Android SMS Gateway** | Android smartphone with SIM card + [Android SMS Gateway App](https://github.com/capcom6/android-sms-gateway) (URL & API Key) | Fast SMS dispatch for experiment invitation alerts and last-minute session reminders. |
| **WebPush Notifications** | Modern browser (HTTPS required) | Browser desktop/mobile push notifications for participants. Keys are auto-generated. |
| **Shibboleth / SAML SSO** | University IdP Entity ID, SSO Target URL & X.509 Certificate Fingerprint | Single Sign-On for campus students and faculty staff. |
| **Bot Protection (Captcha)** | hCaptcha Site/Secret Key or Cloudflare Turnstile Site/Secret Key | Protection against automated spam registrations on public registration forms. |
| **Kimai Time Tracking** | Kimai Instance URL, Username & API Token | Automatic synchronization of laboratory staff shifts and work hours. |
| **External Database** | MySQL 8.0+ / MariaDB 10.6+ (`utf8mb4` character set & collation) | Connecting HROOT to a central, managed campus database cluster instead of internal Compose DB. |

---

## 7. Next Step: Installation

Once your prerequisites are verified, continue with the **[Installation](Installation.md)** guide or run the interactive one-line installer:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/wiso-forschungslabor/hroot-documentation/master/install.sh)"
```
