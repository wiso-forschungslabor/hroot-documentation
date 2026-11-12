# HROOT Documentation & Installer Scripts

This repository hosts the official installer, automated updater scripts, and landing documentation for the **HROOT** laboratory management software.

Full administrative guides and system manuals are maintained in the **[HROOT Wiki Documentation](https://github.com/wiso-forschungslabor/hroot-documentation/wiki)**.

---

## Quick Start & Installation

To install HROOT on a fresh Linux server (Ubuntu, Debian, AlmaLinux, Rocky) with precompiled Docker containers:

```bash
curl -fsSL https://raw.githubusercontent.com/wiso-forschungslabor/hroot-documentation/master/install.sh | bash
```

---

## 1-Command Updating (`update.sh`)

To update an existing Docker-based HROOT installation (automatically validates GitHub token / PAT, creates pre-update database backup, pulls updated images, and restarts containers):

```bash
# Navigate to your HROOT directory and execute:
cd ~/hroot
curl -fsSL https://raw.githubusercontent.com/wiso-forschungslabor/hroot-documentation/master/update.sh | bash
```

*(Alternatively, if running locally inside the HROOT directory, run `./bin/update`)*.

---

## Key Documentation Topics

* 🚀 **[First Steps After Installation](https://github.com/wiso-forschungslabor/hroot-documentation/wiki/First-steps-after-installation)**
* 🔄 **[Updating an Existing Installation](https://github.com/wiso-forschungslabor/hroot-documentation/wiki/Updating-an-existing-installation)**
* 🛡️ **[Migrating to Rootless Docker](https://github.com/wiso-forschungslabor/hroot-documentation/wiki/Migrating-an-Existing-Docker-Installation-to-Rootless-Docker)**
* 📦 **[Migrating from Legacy Bare-Metal to Docker](https://github.com/wiso-forschungslabor/hroot-documentation/wiki/Migrating-from-Legacy-Installation-to-Docker)**

