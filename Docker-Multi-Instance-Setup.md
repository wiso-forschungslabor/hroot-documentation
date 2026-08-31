This guide details how to host multiple independent laboratories or multiple `hroot` environments (e.g. production, staging, testing) on the same physical or virtual server using a shared reverse proxy and automated SSL management.

---

## Architecture Overview

In a multi-instance deployment:
1. **Central Shared Proxy**: A single central NGINX reverse proxy (`nginxproxy/nginx-proxy`) along with an ACME Let's Encrypt companion (`nginxproxy/acme-companion`) runs on the host's ports `80` and `443`.
2. **Shared Docker Network**: All web application containers connect to a common Docker bridge network named `proxy-network`.
3. **Isolated Instances**: Each `hroot` instance runs its own isolated application container (`web`), background worker (`cron`), and database (`db`), defined under a distinct Docker Compose project name.
4. **Dynamic SSL & Routing**: When an instance container starts, the central proxy automatically detects `VIRTUAL_HOST` and `LETSENCRYPT_HOST` from its `.env`, dynamically configures NGINX routing, and provisions SSL certificates.

```
                          [ Internet Traffic (Port 80 / 443) ]
                                          │
                                          ▼
                       ┌─────────────────────────────────────┐
                       │ Central NGINX Proxy + ACME (SSL)    │
                       │ (Network: proxy-network)            │
                       └──────────────────┬──────────────────┘
                                          │
           ┌──────────────────────────────┼──────────────────────────────┐
           │                              │                              │
           ▼                              ▼                              ▼
┌─────────────────────┐        ┌─────────────────────┐        ┌─────────────────────┐
│ Instance 1: ECON    │        │ Instance 2: PSYCH   │        │ Instance 3: MGMT    │
│ Domain: econ.lab... │        │ Domain: psych.lab...│        │ Domain: mgmt.lab... │
│ DB: hroot_econ      │        │ DB: hroot_psych     │        │ DB: hroot_mgmt      │
│ (web + cron + db)   │        │ (web + cron + db)   │        │ (web + cron + db)   │
└─────────────────────┘        └─────────────────────┘        └─────────────────────┘
```

---

## Step-by-Step Walkthrough: 3 Parallel Instances

In this example, we deploy 3 isolated instances:
- **Instance 1**: Economics Lab (`econ.lab.example.org`)
- **Instance 2**: Psychology Lab (`psych.lab.example.org`)
- **Instance 3**: Management Lab (`mgmt.lab.example.org`)

---

### Step 1: Create the Shared Docker Network
Create the external Docker bridge network once on the host:
```bash
docker network create proxy-network
```

---

### Step 2: Launch the Central Shared Proxy
1. Create a dedicated directory for the proxy service:
   ```bash
   sudo mkdir -p /srv/hroot/shared-proxy
   cd /srv/hroot/shared-proxy
   ```
2. Download or copy the shared proxy compose file (`docker/shared-proxy/docker-compose.yml`):
   ```bash
   curl -sSL https://raw.githubusercontent.com/wiso-forschungslabor/hroot/master/docker/shared-proxy/docker-compose.yml -o docker-compose.yml
   ```
3. Start the central proxy:
   ```bash
   docker compose up -d
   ```
*The proxy will now listen on ports 80 and 443 and automatically handle SSL certificates for all connected instances.*

---

### Step 3: Set Up Instance Directories
Create isolated directories for each laboratory instance:
```bash
sudo mkdir -p /srv/hroot/instances/{econ,psych,mgmt}
```

Clone the repository into each instance folder:
```bash
git clone https://github.com/wiso-forschungslabor/hroot.git /srv/hroot/instances/econ
git clone https://github.com/wiso-forschungslabor/hroot.git /srv/hroot/instances/psych
git clone https://github.com/wiso-forschungslabor/hroot.git /srv/hroot/instances/mgmt
```

---

### Step 4: Configure `.env` for Each Instance
In each instance directory, copy `.env.example` to `.env` and set unique parameters:

| Configuration Variable | Instance 1 (`econ`) | Instance 2 (`psych`) | Instance 3 (`mgmt`) |
| :--- | :--- | :--- | :--- |
| **`APP_DOMAIN`** | `econ.lab.example.org` | `psych.lab.example.org` | `mgmt.lab.example.org` |
| **`CONTACT_EMAIL`** | `econ-support@example.org` | `psych-support@example.org`| `mgmt-support@example.org`|
| **`LETSENCRYPT_EMAIL`**| `admin@example.org` | `admin@example.org` | `admin@example.org` |
| **`DATABASE_NAME`** | `hroot_econ` | `hroot_psych` | `hroot_mgmt` |
| **`DATABASE_USERNAME`**| `hroot_econ` | `hroot_psych` | `hroot_mgmt` |
| **`DATABASE_PASSWORD`**| *(Secret Password 1)* | *(Secret Password 2)* | *(Secret Password 3)* |
| **`DB_PORT`** | `33061` *(Host binding)*| `33062` | `33063` |
| **`APP_PORT`** | `3001` | `3002` | `3003` |
| **`SECRET_KEY_BASE`** | *(Unique 64-char Hex)* | *(Unique 64-char Hex)* | *(Unique 64-char Hex)* |

*(Tip: Generate unique secret keys with `bundle exec rails secret` or `openssl rand -hex 64`)*.

---

### Step 5: Start Each Instance
Start each instance using Docker Compose with the `shared-proxy.yml` override and a distinct project name (`-p`):

```bash
# 1. Economics Lab
cd /srv/hroot/instances/econ
docker compose -p hroot-econ -f docker-compose.yml -f docker/overrides/shared-proxy.yml up -d --build

# 2. Psychology Lab
cd /srv/hroot/instances/psych
docker compose -p hroot-psych -f docker-compose.yml -f docker/overrides/shared-proxy.yml up -d --build

# 3. Management Lab
cd /srv/hroot/instances/mgmt
docker compose -p hroot-mgmt -f docker-compose.yml -f docker/overrides/shared-proxy.yml up -d --build
```

---

### Step 6: Run Initial Database Setup & Create Admin Account
Execute `bin/docker-setup` inside each instance container to migrate tables and create the initial administrator:

```bash
# Instance 1
cd /srv/hroot/instances/econ
docker compose -p hroot-econ exec web bin/docker-setup

# Instance 2
cd /srv/hroot/instances/psych
docker compose -p hroot-psych exec web bin/docker-setup

# Instance 3
cd /srv/hroot/instances/mgmt
docker compose -p hroot-mgmt exec web bin/docker-setup
```

---

## Managing Multi-Instance Deployments

### Check Running Containers
```bash
docker ps
```

### View Logs of a Specific Instance
```bash
cd /srv/hroot/instances/econ
docker compose -p hroot-econ logs -f web cron
```

### Updating a Specific Instance
```bash
cd /srv/hroot/instances/econ
git pull origin master
docker compose -p hroot-econ -f docker-compose.yml -f docker/overrides/shared-proxy.yml up -d --build
docker compose -p hroot-econ exec web bundle exec rake db:migrate RAILS_ENV=production
```
