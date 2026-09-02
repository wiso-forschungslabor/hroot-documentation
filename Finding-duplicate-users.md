
In `hroot`, administrators can identify and manage duplicate participant profiles using built-in duplicate detection rules. This helps prevent participants from creating multiple accounts to bypass recruitment limits or restrictions.

---

## 1. Where to Access Duplicate Search

There are two primary locations in `hroot` to manage duplicates:
1.  **Duplicate Users Settings:** Navigate to **Site Settings -> Duplicate Users** (*Doppelte Benutzer* / `/admin/options/duplicate_checks` under *Participants & Master Data*). This allows administrators to customize, enable/disable, and configure the duplicate detection rules.
2.  **User Search Filters:** Go to **Users** (`/admin/users`). In the filter sidebar under the **Duplicate accounts** (*Doppelte Benutzer*) section, check the respective options to filter the user list directly.

---

## 2. Types of Duplicate Checks

The system performs three automated default matching queries (which can be customized in Site Settings):

### Match Type A: Identical First & Last Names (`name`)
*   **Query Condition:** Matches accounts where the **First Name** AND the **Last Name** are identical (`firstname` and `lastname`).
*   **Use Case:** Catching simple re-registrations under the same name but using a different email address.

### Match Type B: Identical Last Name & Date of Birth (`birthday`)
*   **Query Condition:** Matches accounts where the **Last Name** AND the **Date of Birth** (`lastname` and birthday custom field) are identical.
*   **Use Case:** Catching users who register with a slightly different first name (e.g., "John" vs. "Johnny" or "Jon") but share the same family name and birth date.

### Match Type C: Identical Bank Details (`iban`)
*   **Query Condition:** Matches accounts with an identical **IBAN** (`iban`).
*   **Use Case:** Catching users who attempt to create multiple participant accounts to participate multiple times while utilizing the same bank account for payouts.

---

## 3. Managing Duplicate Accounts

When duplicates are listed:
*   **Visual Indicators:** Matching profiles display warning icons in the user list. Hovering over the icon displays the specific duplicate detection reason.
*   **Merging Accounts:** Select the suspected accounts using the checkboxes in the **Users** overview, click **Aktionen** (*Current result*), and select **Benutzer zusammenführen...** (*Merge Users*) to inspect profile data side-by-side and merge them into a single primary account.
*   **Exclusion:** Users who are marked as permanently deleted (anonymized/inactive) or pairs explicitly marked as "ignored duplicates" are excluded from duplicate matching.
 
