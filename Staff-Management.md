*   [1. Task Management](#1-task-management)
    *   [1.1. Global Task Templates](#11-global-task-templates)
    *   [1.2. Experiment-specific Tasks](#12-experiment-specific-tasks)
    *   [1.3. Tasks on the Dashboard](#13-tasks-on-the-dashboard)
    *   [1.4. Permissions & Delegation](#14-permissions--delegation)
*   [2. Staff Availabilities](#2-staff-availabilities)
    *   [2.1. Recurring & One-Time Availabilities](#21-recurring--one-time-availabilities)
    *   [2.2. Calendar Integration](#22-calendar-integration)
*   [3. Two-Factor Authentication (2FA)](#3-two-factor-authentication-2fa)
    *   [3.1. Enabling 2FA](#31-enabling-2fa)
    *   [3.2. Resetting 2FA Tokens](#32-resetting-2fa-tokens)
*   [4. Kimai Absence & Vacation Synchronization](#4-kimai-absence--vacation-synchronization)
    *   [4.1. Absence Sync Workflow](#41-absence-sync-workflow)
    *   [4.2. Calendar Display](#42-calendar-display)

> [!NOTE]
> **Who is "Staff"?** In `hroot`, the term **Staff** (*Personal*) refers collectively to all internal team members involved in lab operations (Administrators, Banking-Administrators, and Experimenters / Lab Assistants) who execute tasks, run sessions, or submit working time availabilities.

---

## 1. Task Management

hroot provides a powerful task management workflow to automate checklists and track responsibilities before, during, and after experiments.

* **Module Activation**: Enabled under **Site Settings -> Plugins / Features** (`/admin/options/features`) via the switch **Staff Tasks** (*Aufgabenverwaltung*).
* **Configuration Location**: Task templates, buckets (phases), and project step definitions are managed under **Site Settings -> Project steps** (`/admin/options/project_steps`).

### 1.1. Global Task Templates
Administrators can define reusable **Task Templates** at the system level under **Site Settings -> Project steps**. These templates serve as blueprints for standard tasks:
- **Structure**: Each template belongs to a **Task Bucket** (visual phase, e.g. Preparation, Execution, Post-processing).
- **Settings**: Templates define a title, detailed description/instructions, default priority (Low, Medium, High), and default assignee.
- **Recurrence**: Standard recurrence intervals (e.g. Daily, Weekly) can be configured.
- **Project Templates**: Multiple task templates and buckets are grouped into **Project Templates**. When creating a new experiment, selecting a project template automatically schedules all associated tasks.

### 1.2. Experiment-specific Tasks
In addition to global templates, researchers can create custom tasks tailored specifically to a single experiment or session:
- **Custom Tasks**: Created within the experiment's planning tab.
- **Session Linking**: Tasks can be linked to a specific session (e.g. "Prepare lab laptops for Session on Monday").
- **State Flow**: Tasks progress through states: Open, In Progress, Completed, or Cancelled. Sequential processing ensures only the oldest open task in a recurring series is visible.

### 1.3. Tasks on the Dashboard
Assigned tasks are dynamically integrated into the administrator/staff dashboards:
- **Kanban Board**: Drag-and-drop board displaying tasks in columns by their status (Open, In Progress, Completed, Cancelled). Users can filter by assignee or phase.
- **Gantt / Timeline View**: Visualizes session timelines alongside task deadlines. Highlights overdue tasks with warnings.
- **Quick Actions**: Allows completing or editing tasks directly from the dashboard views.

### 1.4. Permissions & Delegation
* **Creating & Delegating**: Any standard Administrator can create tasks and delegate them to any active team member.
* **Editing Scope**: Standard Administrators can view all tasks across the system, and can edit, update status, or delete tasks that they created (`created_by`) or that are assigned to them (`assigned_to`).
* **Full Task Governance**: Banking-Administrators have full administrative authority to edit, reassign, or delete any task in the system, even if created by and assigned to other team members.

---

## 2. Staff Availabilities

To coordinate session scheduling with staff members (experimenters, observers, supervisors), hroot tracks individual availability.

* **Module Activation**: Enabled under **Site Settings -> Plugins / Features** (`/admin/options/features`) via **Staff Availabilities** (*Mitarbeiter-Verfügbarkeiten*).

### 2.1. Recurring & One-Time Availabilities
Staff members can manage their availability directly in their profile settings:
- **Recurring Slots**: Weekly repeating times when they are generally available (e.g. every Wednesday 10:00 - 14:00).
- **One-Time Slots**: Specific date-and-time overrides for individual weeks.
- **Confirmation Flow**: Staff must confirm their availability week-by-week. If required weeks are unconfirmed, a warning indicator is shown.
- **Permissions**: Standard Administrators can view and edit only their **own** working times. Banking-Administrators have full access to view, edit, and configure availabilities and exception dates for **all** staff members.

### 2.2. Calendar Integration
- **Availabilities Overlay**: Administrators can toggle "Show availabilities" in the calendar view. Available staff members are listed directly next to scheduled sessions, allowing simple drag-and-drop shift assignment.

---

## 3. Two-Factor Authentication (2FA)

To secure administrative accounts, hroot supports Time-based One-Time Passwords (TOTP) for two-factor authentication.

### 3.1. Enabling 2FA
- **Configuration Location**: Navigate to **Site Settings -> Plugins / Features** (`/admin/options/features` under *System & Plugins*).
- **Global Settings**: Check the box **Admin Zwei-Faktor-Authentifizierung (2FA)** (`enable_admin_2fa`). Once active, TOTP 2FA is required for all accounts with the roles `admin` and `banking_admin`.
- **Setup**: Upon logging in, staff members are prompted to scan a QR code using an authenticator app (e.g. Google Authenticator, Bitwarden) and verify the setup with a one-time code.
- **Remember Device**: Users can check "Trust this device" during login to remember the browser for 90 days.

### 3.2. Resetting 2FA Tokens
- **Admin Reset**: If a staff member loses access to their authenticator device, administrators can reset the 2FA configuration in the user's profile settings. This clears the TOTP secret and allows the user to re-register their device upon their next login.

---

## 4. Kimai Absence & Vacation Synchronization

hroot integrates with the time-tracking tool Kimai to automatically synchronize and display staff absences and holidays.

### 4.1. Absence Sync Workflow
- **Background Sync**: hroot queries the Kimai API at regular intervals or on-demand to fetch vacation records, sick leave, and other absences logged by staff members.
- **Automatic Matching**: Absences in Kimai are mapped to hroot staff profiles using email addresses.

### 4.2. Calendar Display
- **Visual Schedule**: Synced absences are displayed directly in the hroot calendar view as blocked periods. This prevents administrators from scheduling staff members for sessions during their vacation or sick leave.
