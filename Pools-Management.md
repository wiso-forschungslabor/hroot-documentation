
In `hroot`, participants can be divided into different **User Pools** (*Teilnehmerpools*). This allows for clean separation, targeted recruitment of subjects (e.g., by campus, department, or specific criteria), and customizable enrollment conditions.

* **Location in hroot**: **Site Settings -> Participant Pools** (`/admin/options/pools` under *Participants & Master Data*).

---

## Configuration Options for Pools

When creating or editing a pool, the following configuration settings are available:

### 1. Localization & Description
*   **Name (Multilingual):** The name of the pool for each active language in the application (e.g., German, English).
*   **Description (Multilingual):** An optional description explaining the purpose of the pool to participants.
*   **Privacy Policy (Multilingual):** A pool-specific privacy policy. If configured, participants must accept this specific policy when joining or registering.

### 2. Privacy & Legal Settings
*   **Use Global Privacy Policy:** 
    *   *Enabled:* The privacy policy configured in the global settings is used, and any pool-specific privacy text is ignored.
    *   *Disabled:* The pool-specific privacy policy must be accepted. This is useful when different participant categories require different legal disclosures.

### 3. Access & Automation
*   **Allow Self Selection:**
    *   *Enabled:* Participants can independently choose to join or leave this pool via their profile settings or during signup.
    *   *Disabled:* The pool is not freely selectable; assignments are made exclusively by administrators, signup tokens, or automated interfaces.
*   **Auto-Assign Shibboleth:** If users register or log in via Shibboleth (university SSO), they are automatically added as members of this pool.

### 4. Transition & Expiry Settings (Alumni / Student Status Redirects)
These options control how users can transition between pools (e.g., from a student pool to a citizen pool once they graduate):
*   **Transition Target Pool:** Specifies the destination pool where a user will be moved if their status or verification in this pool expires.
*   **Allow Expiry Transition:** If active, when a user's verification expires, they will see an option on their verification page (Option B: "I am no longer a student/member of this group"). Clicking this automatically moves them to the target pool, immediately restoring their active status (assuming the target pool does not require student verification).
*   **Enforce Secondary Email:** If enabled, the user is required to provide an alternative (private) email address. This is critical for university pools where the primary institutional address will eventually be deactivated, enabling login recovery after graduation.

### 5. Requirements & Mandatory Fields
*   **Requires Matriculation:** 
    *   Declares the pool as a student pool.
    *   Participants in this pool must provide a valid matriculation date (`matrikel_date`) during signup.
    *   *Note:* This is completely independent of Shibboleth and can be used on any installation.
*   **Requires Banking:** Specifies whether members of this pool must provide payout details (IBAN/BIC) to sign up for sessions.

### 6. Verification Mode
This setting controls how membership eligibility is checked and verified:
*   **None (`none`):** No verification is needed. Users only need to enter their matriculation date, but do not need to upload documents.
*   **Shibboleth Login (`shibboleth`):** Access requires the user to successfully authenticate via Shibboleth, verifying their affiliation with the institution.
*   **Document Upload (`document_upload`):** The participant must upload a document (e.g., enrollment certificate). Access to the pool and experiment registration is blocked until an administrator reviews and approves the document.
*   **Shibboleth or Document Upload (`shibboleth_or_document`):** Offers both options. The participant can verify either via Shibboleth login or by uploading a document for manual approval.

### 7. Linked Custom Fields
Configure which globally defined Custom Fields (e.g., field of study, handedness, vision) are relevant for the members of this pool.
*   Only the custom fields associated with the pool are displayed in the participant profile.
*   This prevents participants from having to fill out irrelevant profile questions.

### 8. Allowed Payment Types
Defines which payout or reimbursement methods (e.g., bank transfer, voucher, cash) are available for participants in this pool. The system filters payment options during session billing accordingly.

---

## Upgrade Migration & The Default Pool
When upgrading from older `hroot` versions (prior to the introduction of the Pool System):
1.  **Initial Pool Setup:** The database migration automatically creates a default pool named **"Standard-Pool"** (German) / **"Standard Pool"** (English).
2.  **Inherited Options:** The matriculation (`requires_matriculation`) and banking (`requires_banking`) settings for this default pool are inherited from your previous global installation settings.
3.  **User Association:** All existing participants in the system are automatically associated with this default pool to prevent registration errors and profile conflicts.
4.  **Registration Dependency:** A pool must always exist in the database; otherwise, the registration form cannot display pool checkboxes and will hide/disable all participant profile fields.

---

## Pool Administration & Filtering
Administrators can fully manage pools, including renaming, configuration, and linkage:
1.  Go to **Site Settings** -> **Participant Pools** (`/options/pools`).
2.  From here you can create new pools, delete unused ones, or edit the default pool.
3.  Changes to pool-specific names, requirements, linked custom fields, and allowed payment methods take effect immediately for all associated participants.
4.  **Participant Filtering:** In the user search / invitation pages, administrators can filter participants by pool membership (using `AND` / `OR` logic) to target specific audiences for experiments.



