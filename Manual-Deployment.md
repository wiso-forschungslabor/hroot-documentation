
This guide is for administrators installing `hroot` directly on a Linux server without Docker.

> [!NOTE]
> Manual deployment requires maintaining your own Ruby runtime environment, database server, assets precompilation, and background cron schedules. For new installations, consider using [Docker Deployment](Docker-Deployment).

---

## System Requirements

Install the necessary system packages (example for Ubuntu/Debian):

```bash
sudo apt update
sudo apt install build-essential pkg-config libmysqlclient-dev libvips42 git curl nodejs
```

*   **Ruby**: Version 4.0.6 (Installation via [rbenv](Ruby-and-rbenv) recommended).
*   **JavaScript Runtime**: Node.js (v18+ recommended) or any ExecJS-compatible runtime for asset precompilation.
*   **Database**: MySQL 8.0+ or MariaDB.

---

## ⚙️ Setup and Installation

### 1. Ruby & Gems
Ensure you are in the project root directory. If using rbenv:

```bash
rbenv install 4.0.6
gem install bundler
bundle install
```

### 2. Database Creation & Permissions
Copy the environment template: `cp .env.example .env` and adjust the database credentials.

If you are using a local MySQL/MariaDB instance, log in to your database console and manually create the database and user:

```sql
CREATE DATABASE hroot_production;
CREATE USER 'hroot'@'localhost' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON hroot_production.* TO 'hroot'@'localhost';
FLUSH PRIVILEGES;
```

### 3. Database Migration
Ensure `RAILS_MASTER_KEY` and the database variables are set in `.env`, then run migrations:

```bash
bin/rails db:migrate
```

### 4. Initial Administrator Account
Create the initial superuser account interactively using the Rails setup command:

```bash
bin/rails hroot:create_admin
```

Follow the interactive prompts to set the administrator's name, email, and password.

> [!TIP]
> If you need to remove an admin user from the command line later, you can run:
> `bin/rails "hroot:remove_admin[email@domain.net]"`

### 5. Assets & Background Jobs
Precompile assets for production and configure the cron schedule for background email/digest queues using the `whenever` gem:

```bash
bin/rails assets:precompile
whenever -w
```

### 6. Directory Permissions
Set proper read/write permissions for directories where logs, uploads, and active storage items are saved:

```bash
chmod -R 755 storage log tmp uploads
```

---

##  Web Server Setup

To serve the Rails application in production without Docker, you will need to configure a web server like NGINX paired with an application server:
- For step-by-step Passenger integration, see [Production server with Phusion Passenger](Production-server-with-Phusion-Passenger).
- For setting up cron queues, see [Cronjob for background task](Cronjob-for-background-task).
