
This page describes how to integrate `hroot` with **Kimai** (an open-source time-tracking platform) to automate tracking lab usage, staff labor hours, and session costs.

> [!NOTE]
> The Kimai integration is optional and can be enabled or disabled under the global **Feature Switches** in **Site Settings** (`config.enable_kimai_integration = true` in `production.rb` or via the admin settings panel).

---

## 1. Prerequisites: Required Kimai Plugins

To utilize the full capabilities of the Kimai integration, specific plugins must be installed on your Kimai instance:

1.  **Expenses Plugin:**
    *   *Required for:* Synchronizing payouts, show-up fees, donations, and manual expenses from `hroot` session lab reports.
    *   *How it works:* Without this plugin, API requests to `/api/expenses` will return `404 Not Found`. `hroot` will log warnings but gracefully bypass expense synchronization.
2.  **Keleo Absences / Keleo Controlling Plugin:**
    *   *Required for:* Synchronizing leaves and absences.
    *   *How it works:* Imports user absences from Kimai as availability exceptions (Staff Availability Exceptions) in `hroot`.

---

## 2. API & Global Settings Configuration

The API connection parameters can be configured via environment variables in your `.env` file (see [Environment Configuration](Environment-Configuration.md)):

```bash
# Kimai API Configuration
KIMAI_BASE_URL="https://your-kimai-instance.example.com"
KIMAI_API_TOKEN="YOUR_KIMAI_API_TOKEN"
```

Alternatively, these settings can be configured in `config/environments/production.rb`:

```ruby
config.enable_kimai_integration = true
config.kimai_base_url = ENV['KIMAI_BASE_URL'] || 'https://your-kimai-instance.example.com'
config.kimai_api_token = ENV['KIMAI_API_TOKEN'] || 'YOUR_KIMAI_API_TOKEN'
```

### Options & Expense Mappings

Once connected, navigate to **Site Settings > Kimai Tracking > Settings** (`/options/kimai/settings`) to configure:

*   **Expense Plugin Active:** Check this if the Kimai Expenses plugin is installed.
*   **Absences Active (Keleo):** Check this if you want to synchronize absences.
*   **Default Activity for Expenses:** Select the default activity to log expenses against if your Kimai configuration requires it.
*   **Category Mappings:** Map `hroot` session finance sources to Kimai expense categories:
    *   *Payout Sum*
    *   *Participant Count*
    *   *Usable Count*
    *   *Show-up Fees*
    *   *Donations/Deductions*
    *   *Labor Hours*
    *   *Manual Entry*: Defines custom key-value items that will show up in the session lab report form for manual input.
    *   *Rates:* Enter internal and external billing rates. `hroot` automatically applies the correct rate depending on whether the linked Kimai project is configured as *Internal* or *External*.

---

## 3. Linking Users

Every `hroot` staff member who triggers session postings or works on sessions must be paired with their Kimai user profile. If a user is not linked, posting expenses will fail because Kimai requires a valid author user ID.

### How to link users:
1.  Go to **Site Settings > Kimai Tracking** (`/options/kimai`).
2.  Click on **Link Users** in the top menu (or go to `/options/kimai/users`).
3.  You will see a list of active `hroot` staff members (Admins, Banking Admins, and User Admins).
4.  For each user, select the corresponding **Kimai User** from the dropdown menu and click **Link**.
5.  Alternatively, click **Sync Users** to auto-match profiles by email address.

---

## 4. Linking Experiments to Projects

To track timesheets or book session costs, each `hroot` experiment must be linked to a Kimai project.

### Option A: Manual Mapping (Existing Project)
1.  Go to **Site Settings > Kimai Tracking** (`/options/kimai`).
2.  Find the experiment under the pending list, or search for it.
3.  Click **Link Experiment**.
4.  Choose **Link to an existing project**.
5.  Select the Kimai project and classify it as **Internal** or **External** to determine which billing rates apply.

### Option B: Auto-Creation
1.  When creating a new experiment in `hroot`, check the box **Auto-Create Kimai Project**.
2.  `hroot` will automatically create the project in Kimai under a customer matched to the primary experimenter's name (`Lastname, Firstname`).
3.  It generates a unique project number (e.g., `EXP000042`) and syncs the budget and calculated duration automatically.

---

## 5. Daily Operations & Syncing

Once mapped, you can perform the following actions from the **Kimai Dashboard** or the respective experiment/session views:

### 5.1. Session Expense Posting (Lab Report)
In the Session Lab Report, experimenters can post finalized session expenditures to Kimai:
*   **Preview & Manual Adjustments**: Before submitting, `hroot` calculates the mapped expenses (payouts, participant counts, show-up fees, labor duration, manual entries) and displays a pre-filled preview table where values and rates can be adjusted if needed.
*   **Sync Button**: Clicking **Sync with Kimai** creates expense records in Kimai under the linked project.
*   **Smart Delta-Syncing**: If an expense record has already been marked as exported/billed in Kimai (`exported: true`), `hroot` will not overwrite it; instead, it automatically posts an adjustment delta (`+/- Difference`) to maintain financial integrity.
*   **Lab Report Status Display**:
    *   **Synchronized (Green)**: Shows confirmation timestamp, mapped categories, Kimai booking IDs (`#123`), individual costs, and cumulative totals.
    *   **Error (Red)**: Displays the exact error message returned by the Kimai API.
    *   **Not Synchronized (Yellow / Info)**: Indicates that financial data is available but has not yet been transmitted.

### 5.2. Sync Status in Session List ("Sessions" Page)
In the experiment's session overview (**Sessions**), every past session or session with financial activity displays a cloud status icon next to the financial summary:
*   <i class="fa fa-cloud-check text-success"></i> **Green Cloud (`synced`)**: The session has been successfully posted to Kimai.
*   <i class="fa fa-warning text-warning"></i> **Yellow Warning (`mismatch`)**: The current financial data in `hroot` differs from the data stored in Kimai (e.g., after retroactive participant or payout edits), indicating that a re-sync is recommended.
*   <i class="fa fa-cloud-upload text-muted"></i> **Grey Cloud (`not_synced`)**: The session has financial entries but has not yet been posted to Kimai.

### 5.3. Timesheets & Absence Syncing
*   **Import Timesheets:** Download logged hours from Kimai to calculate actual labor cost inside an `hroot` experiment.
*   **Sync Absences:** Queries the Keleo Absences API in Kimai and automatically imports leaves/vacation into `hroot` as all-day availability exceptions in the Staff Scheduling calendar.
*   **Automated Background Job (`KimaiSyncJob`):** When active, `hroot` automatically synchronizes users, updates project statistics for all active experiments, and pulls absence records in the background.
