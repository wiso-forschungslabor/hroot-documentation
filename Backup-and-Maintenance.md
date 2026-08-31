
This page covers routine administrative tasks, maintenance routines, and update procedures for `hroot`.

---

##  Database Backup & Restoration (Docker)

### Backup Database
Execute this command on the host server to export a compressed SQL dump of the database:

```bash
docker compose exec db mysqldump -u hroot -p hroot_production > backup_$(date +%F).sql
```

### Restore Database
To restore a backup file to the database container:

```bash
cat backup.sql | docker compose exec -T db mysql -u hroot -p hroot_production
```

---

## Update Procedures (Minor / Patch Updates)

For a complete and detailed walkthrough of all update scenarios (including major upgrades, background jobs, and migrating to Docker), see [Updating an existing installation](Updating-an-existing-installation.md).

### Docker-based Instances
1. **Backup database**:
   ```bash
   docker compose exec db mysqldump -u hroot -p${DATABASE_PASSWORD} ${DATABASE_NAME:-hroot_production} > backup_$(date +%F).sql
   ```
2. **Pull latest code**:
   ```bash
   git pull
   ```
3. **Rebuild & restart containers**:
   ```bash
   docker compose up -d --build
   ```
4. **Run database migrations**:
   ```bash
   docker compose exec web bundle exec rake db:migrate RAILS_ENV=production
   ```

### Manual (Bare-Metal) Installations
1. **Backup database**:
   ```bash
   mysqldump -u <db_user> -p <db_name> > backup_$(date +%F).sql
   ```
2. **Pull latest code**:
   ```bash
   git pull
   ```
3. **Install gems**:
   ```bash
   bundle install
   ```
4. **Run database migrations**:
   ```bash
   RAILS_ENV=production bundle exec rake db:migrate
   ```
5. **Recompile assets**:
   ```bash
   RAILS_ENV=production bundle exec rake assets:clobber
   RAILS_ENV=production bundle exec rake assets:precompile
   ```
6. **Update cronjobs**:
   ```bash
   RAILS_ENV=production bundle exec whenever --update-crontab
   ```
7. **Restart application server**:
   ```bash
   touch tmp/restart.txt  # for Passenger
   # or: sudo systemctl restart apache2 / nginx / puma
   ```

---

## ️ IT Administration Checklist

If `hroot` is configured to send emails using a university address space (e.g., `@uni-hamburg.de`), the university IT department must configure:

1.  **Outbound Firewall Permission**: Ensure outbound traffic on port **25** (or alternative SMTP ports like 465/587) is allowed for the server's IP address.
2.  **SPF Record**: The server's public IP address must be added to the university domain's SPF record as an authorized mail sender to prevent messages from ending up in spam folders.
3.  **SMTP Relay Server (Recommended)**: Request a dedicated SMTP relay from your IT department to handle message signing and delivery centrally.
