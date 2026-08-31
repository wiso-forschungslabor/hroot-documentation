# Custom Field Definitions

Most labs need to introduce some custom field definitions - `hroot` provides a simple mechanism for customization: You can add additional fields to the user table.

Starting with version 4.0, custom fields can be managed **directly via the admin interface** (UI), removing the need to edit configuration files manually.

---

## Table of Contents

- [1. Custom Fields UI Management](#1-custom-fields-ui-management)
  - [Creating and Editing Custom Fields in the UI](#creating-and-editing-custom-fields-in-the-ui)
    - [General Properties](#general-properties)
    - [Additional Options](#additional-options)
    - [Conditional Display & Requirement Rules](#conditional-display--requirement-rules)
- [2. Integrated Translations Editor](#2-integrated-translations-editor)
- [3. Database Sync & Lifecycle](#3-database-sync--lifecycle)
- [4. File-based Configuration (`config.customfields`)](#4-file-based-configuration-configcustomfields)
  - [Complete Configuration Options](#complete-configuration-options)
  - [Conditional Display Example](#conditional-display-example-configenvironmentsproductionrb)
  - [Constraints & Incompatibilities](#constraints--incompatibilities)
  - [Example Configuration](#example-configuration)

---

## 1. Custom Fields UI Management

To manage custom fields:
1. Navigate to **Site Settings** > **Custom Fields** (under `options/custom_fields`).
2. Here you can see **Active Fields**, **Archived Fields**, and **Static Fields**.
3. After creating or editing fields, click **Trigger Server Restart** (which touches `tmp/restart.txt`) to make the web workers reload the updated schema.

### Creating and Editing Custom Fields in the UI
When adding or editing a custom field (`options/custom_fields/new`), you can configure the following options in the Site Settings UI:

#### General Properties
- **Name**: The internal field identifier (e.g. `matrikel`, `institution`, `address`). The corresponding database column will be prefixed with `custom_`.
- **Field Type**:
  - `text` - Free text entry field.
  - `selection` - Dropdown / choice list where the user picks from defined values.
  - `date` - Calendar date selector (supports optional month-only restriction).
  - `boolean` / `checkbox` - True/false toggles and checkboxes.
- **Restriction** (for `date` type):
  - `restrict_to_months` - Restricts the date picker to Month & Year (`YYYY-MM`).
- **Selection Options** (for `selection` type):
  - **Database Values**: Comma-separated list of values stored in the DB (e.g. `1, 2, 3` or `de, en, fr`).
  - **Store Multiple**: Allows selecting multiple choices from the selection list.
  - **Other Option**: Adds an "Other" choice with a free-text input field (`custom_<name>_other`).
- **Sort Order**: Numerical position controlling where the field appears relative to other fields.
- **Required**: Determines if participants are forced to fill this field.
- **Hidden**: Hides the field from participant-facing forms so only admins and experimenters can view and edit it.
- **Mutable**: If checked, participants can edit the value in their account settings after registration.

#### Additional Options
- **Fulltext Search**: Enables indexing this field for full-text search in admin user search.
- **Show in Registration**: Controls whether the field is rendered on the public registration form.
- **Translate Values**: Activates multi-language translation lookup for labels, headers, and option values.
- **Blacklist on User Deletion**: When a user account is deleted/anonymized, clears the field value and adds it to the system `Blacklist` table to prevent future re-registration with the same value (useful for matriculation numbers).

#### Conditional Display & Requirement Rules
Admins can define dynamic display and requirement conditions so a field is only shown/required when another user field satisfies a rule:
- **Condition Field** (`condition_field`): Pick any user field to depend on — including **standard fields** (`email`, `firstname`, `lastname`, `phone`, `secondary_email`, `shibboleth_id`) or **custom fields** (`institution`, `matrikel`, `gender`, `degree`, etc.).
- **Condition Operator** (`condition_operator`):
  - `equal` / `==` - Shown/required when the target field matches the value.
  - `not_equal` / `!=` - Shown/required when the target field DOES NOT match the value.
  - `contains` - Shown/required when the target field string contains the value.
  - `not_contains` - Shown/required when the target field DOES NOT contain the value.
  - `is_blank` - Shown/required when the target field is empty.
  - `is_present` - Shown/required when the target field is filled.
- **Condition Value** (`condition_value`): The string value to compare against (e.g. `uni-hamburg.de`). **Multiple values** can be specified separated by commas, semicolons, or pipes (e.g. `uni-hamburg.de, hsu-hamburg.de`). When multiple values are listed:
  - `equal` / `==` matches if the field value equals **any** of the listed values.
  - `not_equal` / `!=` matches if the field value does **not** equal any of the listed values.
  - `contains` matches if the field value contains **any** of the listed values.

---

## 2. Integrated Translations Editor

The creation/edit form has a dedicated translation section for all active site locales (e.g. German, English, Italian). You can provide translations for:
- **Field Label**: The caption shown next to the input field.
- **Header**: Column header label used in tables and admin user lists.
- **Option Values**: Human-readable translations for the defined database values (e.g. mapping numeric `1` to `Male` or `de` to `Deutsch`).

---

## 3. Database Sync & Lifecycle

- **Automatic Schema updates**: When a new custom field is saved in the UI, `hroot` automatically adds the new column to the database users table.
- **Archiving**: Clicking delete on an active field archives it (marks `active: false`). It will be hidden from the UI, but the collected data in the database remains safe.
- **Archived Fields deletion**: Deleting an archived field permanently drops the database column from the users table.

---

## 4. File-based Configuration (`config.customfields`)

Custom fields can also be defined statically in `config/environments/production.rb` (or `development.rb` / `test.rb`) using `config.customfields`:

### Complete Configuration Options

Each custom field definition hash supports the following properties:

- **`name`** (`Symbol` / `String`, required): The internal field identifier (e.g. `:student_id`, `:birthday`, `:address`). The corresponding database column will be named `custom_<name>`.
- **`type`** / **`field_type`** (`Symbol` / `String`, required): Field type. Supported values: `:text`, `:selection`, `:date`, `:boolean`, `:checkbox`.
- **`required`** (`Boolean`, default: `true`): Mandatory during registration.
- **`hidden`** (`Boolean`, default: `false`): Hidden from participant-facing forms.
- **`mutable`** (`Boolean`): Determines if participants can edit this field in account settings.
- **`translate`** (`Boolean`, default: `true`): Enables I18n translation lookup.
- **`hint`** (`Boolean`, default: `false`): Renders a localized hint message under the input field.
- **`show_in_registration`** (`Boolean`, default: `true`): Renders the field on the registration form.
- **`fulltext`** (`Boolean`, default: `false`): Enables indexing in admin user search.
- **`db_values`** (`Array`, default: `[]`): For `:selection` fields, allowed values in DB.
- **`store_multiple`** (`Boolean`, default: `false`): For `:selection` fields, multi-choice selection.
- **`other_option`** (`Boolean`, default: `false`): For `:selection` fields, adds "Other" free-text choice.
- **`regex`** (`String` / `Regexp`): Validates input format using regular expressions.
- **`on_delete`** (`Symbol`, default: `:keep`): Action on user account deletion (`:keep`, `:clear`, `:clear_and_block`).
- **`condition_field`** (`Symbol` / `String`): Target field name for conditional display (standard or custom field).
- **`condition_operator`** (`Symbol` / `String`): Operator (`:equal`, `:not_equal`, `:contains`, `:not_contains`, `:is_blank`, `:is_present`).
- **`condition_value`** (`String`): Comparison string value for conditional display.

### Conditional Display Example (`config/environments/production.rb`)

```ruby
config.customfields = [
  # Custom field for Home Institution (populated via Shibboleth schacHomeOrganization)
  { type: :text, name: :institution, required: false },

  # Address field: ONLY required & displayed if the user does NOT study at Uni Hamburg
  {
    type: :text,
    name: :address,
    required: true,
    condition_field: :institution,
    condition_operator: :not_equal,
    condition_value: 'uni-hamburg.de'
  }
]
```

### Constraints & Incompatibilities

> [!IMPORTANT]
> - **`store_multiple` and `other_option` cannot be combined:** Enabling both on a single `:selection` field will raise a runtime error on application boot.
> - **`hidden` and `required` cannot be combined:** A field cannot be hidden from participants and simultaneously marked as required.

### Example Configuration

```ruby
config.customfields = [
  # Required text field with regex validation and blacklist on user deletion
  { 
    type: :text, 
    name: :student_id, 
    required: true, 
    regex: /\A[0-9]{6,8}\z/,
    on_delete: :clear_and_block, # :keep, :clear, or :clear_and_block
    fulltext: true,
    hint: true
  },

  # Selection field with "Other" free-text input option
  { 
    type: :selection, 
    name: :gender, 
    db_values: %w[m f o], 
    other_option: true, # Cannot be combined with store_multiple!
    translate: true
  },

  # Optional date field restricted to month & year
  { 
    type: :date, 
    name: :begin_of_studies, 
    required: false, 
    restrict_to_months: true,
    mutable: true
  },

  # Hidden field for admin/experimenter use only
  { 
    type: :text, 
    name: :admin_notes, 
    hidden: true, 
    required: false # Hidden fields must never be required!
  }
]
```

To sync the database schema for file-defined fields, run:
```bash
RAILS_ENV=production bundle exec rake hroot:create_db_fields_for_custom_fields
```

