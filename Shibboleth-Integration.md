
This page describes the optional SAML authentication via Shibboleth (DFN-AAI / eduGAIN) using `omniauth-saml`, and how the system handles enrollment/matriculation verification for students.

## What is Shibboleth?

Shibboleth is a Single Sign-On (SSO) web authentication system based on the SAML (Security Assertion Markup Language) standard. It is widely used in academic federations (like DFN-AAI in Germany or eduGAIN internationally). By integrating Shibboleth, universities can configure `hroot` to allow students and staff to log in using their official university credentials. This eliminates the need for them to create separate passwords and provides an direct way to verify their university status.

---

## Activating and Configuring Shibboleth

Shibboleth is enabled via deployment environment variables and configured in the administration interface:

1.  **Backend Activation via `.env` file:**
    *   Set `SHIBBOLETH_ENABLED=true` to enable the SAML authentication backend.
    *   *Note:* Loading the OmniAuth SAML authentication strategy occurs during application boot and requires a server restart.
2.  **Branding & Styling via UI:**
    *   Go to **Site Settings -> Design & Layout** (`/admin/options/design` under *System & Plugins*).
    *   In the **Logo & Shibboleth** section, configure the **Institution Name** (e.g. `UHH`, `Uni Hamburg`) and customize the Shibboleth login button colors (background & text).
3.  **Pool Verification & Auto-Assignment via UI:**
    *   Go to **Site Settings -> Participant Pools** (`/admin/options/pools` under *Participants & Master Data*).
    *   Edit a pool to configure:
        *   **Shibboleth-Nutzer automatisch diesem Pool hinzufügen** (`auto_assign_shibboleth`): Automatically enrols Shibboleth users in this pool upon login.
        *   **Matrikelbescheinigung/Studiennachweis erforderlich** (`requires_matriculation`): Enforces valid matriculation proof for sessions in this pool.
        *   **Verifizierungs-Modus** (`verification_mode`): Set to `shibboleth`, `document_upload`, or `shibboleth_or_document`.

---

## Configuration via Environment Variables

The application reads configurations from the `.env` file. Adjust these settings inside your `.env`:

*   `SHIBBOLETH_ENABLED=false` - Enable SAML/Shibboleth login and strategy on boot.
*   `ENROLLMENT_VERIFICATION_ENABLED=true` - Global switch requiring students to have a valid matriculation proof.
*   `SHIBBOLETH_DISCOVERY_MODE=embedded` - Discovery mode (`direct`, `embedded`, or `redirect`). See details below.
*   `SHIBBOLETH_DS_URL` - Discovery service URL (used when `SHIBBOLETH_DISCOVERY_MODE=redirect`).
*   `SHIBBOLETH_SP_ENTITY_ID` - Your Service Provider (SP) entity ID (e.g. `https://hroot.your-uni.edu/shibboleth`).
*   `SHIBBOLETH_IDP_ENTITY_ID` - The Identity Provider (IdP) entity ID of your home university.
*   `SHIBBOLETH_PREFERRED_IDP_NAME` - Display name of your primary institution (e.g., `Universität Hamburg`).
*   `SHIBBOLETH_IDP_SSO_TARGET_URL` - Target redirection URL of your IdP SSO endpoint.
*   `SHIBBOLETH_IDP_SLO_TARGET_URL` - Target redirection URL of your IdP Single Logout (SLO) endpoint (optional).
*   `SHIBBOLETH_CERT_PATH` / `SHIBBOLETH_KEY_PATH` - Paths to the Service Provider certificates used for request signing and decryption.
*   `SHIBBOLETH_IDP_CERT_PATH` / `SHIBBOLETH_IDP_METADATA_URL` - Certificate or metadata XML URL for verifying the IdP.
*   `OMNIAUTH_FULL_HOST` - The full domain URL (including protocol) matching your registered SP metadata.

---

---

## Discovery Service Modes and Institution Naming

Hroot supports both single-institution deployments (e.g. dedicated to a single university) and multi-institution federation setups (e.g. DFN-AAI, eduGAIN).

### Institution Name Resolution (`SHIBBOLETH_PREFERRED_IDP_NAME` & UI Settings)

Button labels and titles automatically adapt depending on whether a preferred home institution is configured:

1. **Specific Institution Mode (Default for Single University Setups):**
   * **Configuration:** Set `SHIBBOLETH_PREFERRED_IDP_NAME="UHH"` (or in UI under *Site Settings -> Design -> Shibboleth*).
   * **Button Labels:** Buttons and headlines use the specific institution name (e.g., *"Login / Registrierung via UHH"*, *"Felder via UHH befüllen"*, *"Via UHH verifizieren"*).
   * **Behavior:** Clicking the primary button immediately directs to the home institution's IdP. In `redirect` mode, a secondary link *"Andere Hochschule / eduGAIN wählen"* is displayed below.

2. **Generic Discovery / Federation Mode (For Cross-Institutional / WAYF-Only Setups):**
   * **Configuration:** Leave `SHIBBOLETH_PREFERRED_IDP_NAME` unset / empty, and set `SHIBBOLETH_DISCOVERY_MODE=redirect`.
   * **Button Labels:** Buttons automatically switch to a generic, neutral label (e.g., *"Login / Registrierung via Hochschul-Account (Shibboleth)"* in German, *"Login / Registration via University Account (SSO)"* in English).
   * **Behavior:** Clicking the primary button routes the user directly to the central DFN WAYF / Discovery Service (`SHIBBOLETH_DS_URL`) where they can select from all participating institutions. No duplicate secondary link is shown.

---

## Discovery Service Modes (`SHIBBOLETH_DISCOVERY_MODE`)

Hroot supports three discovery service modes to control how users choose their Identity Provider (IdP):

### 1. `direct` — Single Institution / Dedicated IdP
* **Use Case:** Your hroot instance is strictly dedicated to a single university or organisation.
* **Behavior:** No institution selection step. Clicking **"Login via <Institution>"** immediately redirects to the configured `SHIBBOLETH_IDP_SSO_TARGET_URL`.
* **Required Configuration:**
  ```bash
  SHIBBOLETH_DISCOVERY_MODE=direct
  SHIBBOLETH_PREFERRED_IDP_NAME="Uni Köln"
  SHIBBOLETH_IDP_ENTITY_ID=https://idp.example.com/shibboleth
  SHIBBOLETH_IDP_SSO_TARGET_URL=https://idp.example.com/idp/profile/SAML2/Redirect/SSO
  SHIBBOLETH_IDP_CERT_PATH=/rails/certs/idp-cert.pem # or SHIBBOLETH_IDP_METADATA_URL
  ```

### 2. `embedded` — SeamlessAccess / In-Page Search
* **Use Case:** Your institution participates in DFN-AAI or eduGAIN, and you want participants from other partner universities to be able to log in without leaving the page.
* **Behavior:** Embeds an interactive institution search widget directly on the hroot login page. Users can search and select any university in the federation. Your configured home institution is prominently displayed at the top for one-click access.
* **Required Configuration:**
  ```bash
  SHIBBOLETH_DISCOVERY_MODE=embedded
  SHIBBOLETH_IDP_ENTITY_ID=https://login.uni-hamburg.de/idp/shibboleth
  SHIBBOLETH_PREFERRED_IDP_NAME="UHH"
  ```

### 3. `redirect` — Central Federation WAYF (e.g. DFN-AAI Discovery Service)
* **Use Case:** Classic federation setup delegating the institution selection to a centralized discovery service (DFN WAYF).
* **Behavior:**
  * If `SHIBBOLETH_PREFERRED_IDP_NAME` is set: Main button logs into home university; sub-link leads to WAYF for external universities.
  * If `SHIBBOLETH_PREFERRED_IDP_NAME` is empty: Main button shows generic label and leads directly to the WAYF selector.
* **Required Configuration:**
  ```bash
  SHIBBOLETH_DISCOVERY_MODE=redirect
  # DFN Production Federation:
  SHIBBOLETH_DS_URL=https://wayf.aai.dfn.de/DFN-AAI/wayf
  # Or DFN Test Federation:
  # SHIBBOLETH_DS_URL=https://wayf.aai.dfn.de/DFN-AAI-Test/wayf
  ```

---

## Student Verification Flows

When student verification is active, `hroot` restricts students from registering for experiment sessions unless they have valid, unexpired enrollment proof. The system determines verification via two layers: pool-specific rules and legacy global overrides.

### 1. Connection between "Requires Matriculation" and Shibboleth
The enrollment verification flow relies on two distinct settings:
*   **Requires Matriculation (`requires_matriculation`):** Configured per pool, this flag specifies whether members of that pool are required to have a valid matriculation status (tracked via `matrikel_date`). If active, the system checks whether the user's `matrikel_date` is in the future.
*   **Verification Mode (`verification_mode`):** Determines the method of verifying this matriculation status. Shibboleth functions as an **automatic verification method**.
    *   *Without Shibboleth (Manual Upload):* The user uploads a file, which requires manual approval from an administrator to extend their `matrikel_date` (usually to the end of the current semester).
    *   *With Shibboleth (Automatic):* Logging in via Shibboleth instantly extends the user's `matrikel_date` automatically to the end of the current semester (if `shibboleth_matrikel_auto_update` is enabled in configuration), allowing the user to bypass manual admin approval and register immediately.

### 2. Pool-Specific Verification Modes
If the student belongs to one or more participant pools, the pool's specific configuration determines how they are verified (configured under **Site Settings** -> **Participant Pools** -> Edit Pool -> **Verification Mode**):

*   **`shibboleth`**: The student is required to log in via Shibboleth. If they did not authenticate using SAML, they are blocked from registering and prompted to log in via Shibboleth.
*   **`document_upload`**: The student must upload a proof of enrollment document (e.g., Certificate of Enrollment / Immatrikulationsbescheinigung).
*   **`shibboleth_or_document`**: The student can satisfy verification by *either* logging in via Shibboleth OR uploading a verification document.

### 3. What Happens to Students Without a Matriculation Number (Document Upload Flow)
For students who do not have a verified matriculation status (either because their university doesn't use Shibboleth, they registered manually, or their matriculation proof has expired):

1.  **Redirection to Upload Page:**
    When trying to sign up for an active session, they are prevented from registering and redirected to the `/enroll/matrikel_verification` page.
2.  **Document Upload:**
    They must upload a verification file (such as a photo or PDF of their student ID card or current semester certificate).
3.  **Pending Registration Permitted:**
    Upon uploading the document, their account's `verification_status` changes to `pending`. While in `pending` status, they are temporarily allowed to sign up for sessions so they do not miss slot deadlines.
4.  **Automatic Alerts:**
    When they sign up with a `pending` status, the system automatically sends them an email (using the **Missing Matriculation Proof** mail template configured in Site Settings) reminding them that their proof must be verified by the admin before the experiment session starts.
5.  **Admin Approval:**
    An administrator can view all pending verification files in the **Users** menu, check the upload, and click **Verify** or **Reject**. Approving sets their `matrikel_date` expiration (usually the end of the current semester) and marks them as verified.

---

## Attribute Mapping

The attributes returned by your IdP may vary. The app supports dynamic attribute mapping from environment variables (`.env`):
- `SHIBBOLETH_MAP_FIRSTNAME` - map first name attribute (e.g. `urn:oid:2.5.4.42` or `givenName`)
- `SHIBBOLETH_MAP_LASTNAME` - map last name attribute (e.g. `urn:oid:2.5.4.4` or `sn`)
- `SHIBBOLETH_MAP_EMAIL` - map email attribute (e.g. `urn:oid:0.9.2342.19200300.100.1.3` or `mail`)
- `SHIBBOLETH_MAP_CUSTOM_MATRIKEL` - map matriculation number (e.g. `urn:oid:1.3.6.1.4.1.25178.1.2.14` or `schacPersonalUniqueCode`)
- `SHIBBOLETH_MAP_CUSTOM_COURSE_OF_STUDIES` - map subject/course (e.g. `urn:oid:1.3.6.1.4.1.22177.400.1.1.3.5` or `dfnEduPersonFieldOfStudyString`)
- `SHIBBOLETH_MAP_AFFILIATION` - map affiliation attribute (defaults to `urn:oid:1.3.6.1.4.1.5923.1.1.1.1` or `eduPersonAffiliation`)
- `SHIBBOLETH_AFFILIATIONS_VERIFIED` - comma-separated list of affiliations considered verified/valid (defaults to `student`)

## Metadata and Setup Workflow

1. **Providing SP Metadata XML**: Host metadata XML under a public HTTPS URL (`https://<domain>/users/auth/saml/metadata`) or deliver XML directly to IdP admins.
2. **Metadata Requirements**:
   - **EntityID**: Unique identifier of your SP (e.g. `https://hroot.example.org/shibboleth`)
   - **ACS URL**: E.g., `https://<host>/users/auth/saml/callback` (HTTP-POST)
   - **KeyDescriptor**: Public certificate of your SP for signature verification.
   - **AttributeConsumingService**: List of requested attributes.

## User Linking Flow

When a participant authenticates via Shibboleth:
1. **Existing Account Linking**: If the email matches an existing account, the user is prompted to link their account to Shibboleth.
2. **Account Creation**: If no account exists, a new hroot account is created automatically using details retrieved from the Shibboleth metadata (first name, last name, email).

## Troubleshooting

1. **Verify Routes**:
   Verify that the Shibboleth routes are loaded by running:
   ```bash
   bin/rails routes | grep saml
   ```
2. **Check Strategy Registration**:
   To confirm that the OmniAuth strategy successfully loaded on boot, run:
   ```bash
   bin/rails runner "puts Rails.configuration.x.shibboleth_enabled; puts defined?(OmniAuth) ? OmniAuth.strategies.inspect : 'OmniAuth not loaded'"
   ```
3. **Check Logs**:
   If redirects fail or the signature verification fails, check the logs in `log/production.log` or `log/development.log` and make sure your `OMNIAUTH_FULL_HOST` and SP certificates match the metadata uploaded to the DFN/eduGAIN registry.
