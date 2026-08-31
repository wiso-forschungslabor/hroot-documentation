When you are logged in with the role 'admin' or 'banking_admin', you can export data across Users, Sessions, Experiments, and Financial records.

In the **Users** list, click on the **Aktionen** (*Current result*) dropdown menu in the top-right toolbar to choose from multiple export options:
- **Save as CSV** (*CSV exportieren*): Exports the current filtered view to a CSV file.
- **Save as Excel** (*Excel exportieren*): Exports the current filtered view to an Excel spreadsheet.
- **Pforten-Export (PDF/TXT)**: Generates a gate check-in / entry list for campus security.
- **Custom Export Profiles**: Downloads user data formatted according to saved custom export profiles.

Similar export buttons are available on the **Sessions** participants list and **Experiments** overview.

---

## Custom Export Profiles

Administrators can create customized export templates called **Export Profiles** to standardize reporting formats and automate recurring downloads.

### Creating Export Profiles
1. Navigate to **Site Settings -> Exports & Reports** (*Exporte & Berichte* under `options/export_profiles`).
2. Click **New Export Profile** (*Neues Export-Profil anlegen*).
3. Configure the profile details:
   - **Name**: A descriptive title for the export template (e.g. "SEPA Banking Payout Export" or "Lab Helper Attendance").
   - **Context**: The model context to export from:
     - `User`: Participant / User accounts directory.
     - `Session`: Session participants and check-in statuses.
     - `Experiment`: Experiment metadata and overview metrics.
     - `Payout Request`: Accumulated payout requests ledger.
     - `Banking`: Bank details and wire transfer exports.
     - `Session Invoice`: Individual session cost breakdown.
     - `Budget Invoice`: Experiment budget accounting overview.
   - **Format**: File format (`CSV` or `Excel`).
   - **Fields**: Check the precise database fields and custom profile attributes to include in the output columns.
4. Save the profile. Once created, it appears automatically as an option under the export dropdowns on the respective management pages.

### Reporting Settings (Socio-demographic fields)
At the bottom of the **Exports & Reports** settings page, you can define which participant demographic fields (such as age, gender, or custom fields) should be displayed in the experiment reporting dashboard.
- Select the target socio-demographic fields.
- Configure the **Top X** threshold (e.g. Top 5) to rank and aggregate minority selections under a grouped "Other/Sonstige" category in pool statistics.
