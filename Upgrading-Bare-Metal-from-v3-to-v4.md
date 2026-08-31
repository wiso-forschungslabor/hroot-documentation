This guide details the complete procedure for upgrading an existing **bare-metal (non-Docker)** `hroot v3.x` installation directly on your Linux server to **hroot v4.0+**, retaining native hosting with Ruby, MySQL, and Phusion Passenger or Puma.

---

## 1. Summary of Major Changes in v4.0 (Bare Metal)

| Component | Legacy hroot (v3.x) | Modern hroot (v4.0+) |
| :--- | :--- | :--- |
| **Configuration** | Hardcoded in `config/environments/production.rb` and `database.yml` | **Centralized `.env` file** (loaded via `dotenv-rails`) |
| **Secrets & Keys** | Hardcoded in files or `secrets.yml` | **Auto-generated `SECRET_KEY_BASE` & WebPush `VAPID` keys** in `.env` |
| **Ruby Management** | Legacy RVM with shell hooks and gemsets | **`rbenv`** (lightweight, non-intrusive `shims`) |
| **Ruby Version** | Ruby 2.7 / 3.0 / 3.2 | **Ruby version specified in `.ruby-version`** (e.g. `3.3.6`) |
| **Background Tasks** | Basic invitation cronjob | **Expanded `whenever` schedule** (Digests, Surveys, IMAP, Shifts) |
| **Web Server Config** | Pointed to RVM ruby binary | Points to **`rbenv` shim** (`/home/<user>/.rbenv/shims/ruby`) |

---

## 2. Pre-Upgrade Preparation

### Step 1: Create Complete Backups
1. **Export your MySQL Database:**
   ```bash
   mysqldump -u <db_user> -p --single-transaction --routines --triggers <db_name> > ~/hroot_v3_backup_$(date +%Y%m%d_%H%M).sql
   ```
2. **Back Up Uploaded Files:**
   ```bash
   cp -r /path/to/hroot/public/uploads ~/hroot_uploads_v3_backup
   ```

### Step 2: Enable Maintenance Mode
Notify users and prevent incoming requests during the upgrade:
```bash
cd /path/to/hroot
RAILS_ENV=production bundle exec rake rack:turnout:down[reason="We are running maintenance operations. Please check back shortly."]
```

---

## 3. Step-by-Step Upgrade Procedure

### Step 1: Switch Ruby Environment from RVM to rbenv (Recommended)

If your server still uses RVM, switch to `rbenv` to eliminate shell overrides and binary gem compilation issues:

1. **Remove RVM hooks from your shell:**
   Open `~/.bashrc`, `~/.bash_profile`, and `~/.profile`, and remove any lines referencing `.rvm`:
   ```bash
   # Remove lines like:
   # source ~/.rvm/scripts/rvm
   # export PATH="$PATH:$HOME/.rvm/bin"
   ```
2. **Unset RVM environment variables:**
   ```bash
   unset GEM_HOME GEM_PATH
   ```
3. **Install rbenv and ruby-build:**
   ```bash
   git clone https://github.com/rbenv/rbenv.git ~/.rbenv
   git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
   echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
   echo 'eval "$(rbenv init - bash)"' >> ~/.bashrc
   source ~/.bashrc
   ```
4. **Install the Ruby version required by hroot v4:**
   ```bash
   cd /path/to/hroot
   rbenv install $(cat .ruby-version)
   rbenv local $(cat .ruby-version)
   gem install bundler
   ```
*(For complete details, see **[Ruby and rbenv](Ruby-and-rbenv.md)**).*

---

### Step 2: Pull the latest hroot Codebase

Fetch the latest code and checkout the target release:
```bash
cd /path/to/hroot
git fetch origin
git checkout master  # or checkout a specific release tag, e.g. git checkout v4.0.0
```

---

### Step 3: Initialize and Populate `.env`

From `hroot 4.0` on, all laboratory and server settings are read from `.env` instead of hardcoded Ruby files.

1. **Initialize `.env` and generate cryptographic keys:**
   ```bash
   ./bin/init-env
   ```
   *This creates `.env` from `.env.example` and automatically generates secure keys for `SECRET_KEY_BASE`, WebPush `VAPID` keypairs, and internal credentials.*

2. **Transfer your laboratory settings into `.env`:**  
   Open your old `config/environments/production.rb`, `config/secrets.yml`, and `config/database.yml`, and copy your settings into `.env`:

| Old Location & Setting | New Variable in `.env` | Example |
| :--- | :--- | :--- |
| `production.rb`: `default_url_options[:host]` | `APP_DOMAIN` | `APP_DOMAIN=hroot.example.org` |
| `production.rb`: `default_url_options[:protocol]` | `APP_PROTOCOL` | `APP_PROTOCOL=https` |
| `production.rb`: `HROOT_SETTINGS[:contact_email]` | `CONTACT_EMAIL` | `CONTACT_EMAIL=lab@example.org` |
| `production.rb`: `HROOT_SETTINGS[:sender_email]` | `SENDER_EMAIL` | `SENDER_EMAIL=noreply@example.org` |
| `production.rb`: `HROOT_SETTINGS[:log_email]` | `LOG_EMAIL` | `LOG_EMAIL=admin@example.org` |
| `production.rb`: `smtp_settings[:address]` | `SMTP_ADDRESS` | `SMTP_ADDRESS=smtp.example.org` |
| `production.rb`: `smtp_settings[:port]` | `SMTP_PORT` | `SMTP_PORT=587` |
| `production.rb`: `smtp_settings[:user_name]` | `SMTP_USER_NAME` | `SMTP_USER_NAME=mailer-user` |
| `production.rb`: `smtp_settings[:password]` | `SMTP_PASSWORD` | `SMTP_PASSWORD=secret-smtp-pass` |
| `database.yml`: `production.host` | `DATABASE_HOST` | `DATABASE_HOST=localhost` |
| `database.yml`: `production.username` | `DATABASE_USERNAME` | `DATABASE_USERNAME=hroot` |
| `database.yml`: `production.password` | `DATABASE_PASSWORD` | `DATABASE_PASSWORD=secret-db-pass` |
| `database.yml`: `production.database` | `DATABASE_NAME` | `DATABASE_NAME=hroot_production` |

*(See **[Environment Configuration](Environment-Configuration.md)** for the full list of optional features like Shibboleth, Kimai, SMS gateways, and Bot Protection).*

---

### Step 4: Install Dependencies & Run Database Migrations

1. **Install Ruby Gems:**
   ```bash
   bundle config set --local deployment 'true'
   bundle config set --local without 'development test'
   bundle install
   ```

2. **Run Database Schema Migrations:**
   ```bash
   RAILS_ENV=production bin/rails db:migrate
   ```
   *This applies all new schema additions in v4 (survey completion links, push notifications, staff roles, updated indexes, and dynamic settings).*

---

### Step 5: Precompile Frontend Assets

Clear stale cached assets and compile the modern asset pipeline:
```bash
RAILS_ENV=production bin/rails assets:clobber
RAILS_ENV=production bin/rails assets:precompile
```

---

### Step 6: Update Background Cronjobs (`whenever`)

`hroot 4.0` introduces automated invitation digest processing, survey timeout monitors, and IMAP reply processing. Register the updated schedule in your system crontab:
```bash
RAILS_ENV=production bundle exec whenever --update-crontab
```
*To inspect the registered cron jobs, run `crontab -l`.*

---

### Step 7: Update Web Server Configuration (Passenger / Puma)

If you upgraded Ruby or switched to `rbenv`, update your web server's Ruby path:

#### A. For Phusion Passenger with Apache:
Edit `/etc/apache2/sites-available/hroot.conf` (or `/etc/apache2/mods-available/passenger.conf`):
```apache
# Ensure Passenger uses the rbenv shim:
PassengerRuby /home/hroot/.rbenv/shims/ruby
```
Restart Apache:
```bash
sudo systemctl restart apache2
```

#### B. For Phusion Passenger with NGINX:
Edit `/etc/nginx/sites-available/hroot`:
```nginx
passenger_ruby /home/hroot/.rbenv/shims/ruby;
```
Restart NGINX:
```bash
sudo systemctl restart nginx
```

#### C. For Standalone Puma (Systemd):
Edit `/etc/systemd/system/hroot.service` to point `ExecStart` to `/home/hroot/.rbenv/shims/bundle exec puma ...`:
```bash
sudo systemctl daemon-reload
sudo systemctl restart hroot
```

#### D. Touch Passenger Restart File:
```bash
touch tmp/restart.txt
```

---

### Step 8: Disable Maintenance Mode & Verify

1. **Disable maintenance mode:**
   ```bash
   RAILS_ENV=production bundle exec rake rack:turnout:up
   ```

2. **Run System Diagnostic Checks:**
   * Open `https://<APP_DOMAIN>/admin/options/check` in your browser.
   * Verify that database connectivity, mailer delivery, and background tasks are healthy.
   * Send a test email from the Admin options page.
