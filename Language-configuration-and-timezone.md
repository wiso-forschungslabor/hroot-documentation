### Language configuration

The user interface of hroot can be used in different languages. System defaults are defined in `config/application.rb` and environment files, but administrators can also manage languages and translate strings dynamically directly within the web UI.

#### File-Based Configuration (System Setup)
Developers and system administrators can customize the available locales in the backend via `config/application.rb`:

    config.locales = [:en, :de]
    config.locale_names = {:en => 'English (en)', :de => 'Deutsch (de)'}

If you only want to provide an English user interface, change this to:

    config.locales = [:en]
    config.locale_names = {:en => 'English (en)'}

You can set the default locale with:

    config.i18n.default_locale = :en   # English as default

or:

    config.i18n.default_locale = :de   # German as default

When a user visits hroot for the first time, the default locale is chosen. The language choice of the user is stored in a cookie, in case the user opts for a different locale.

#### UI-Based Language Management & Live-Edit Mode
Administrators can configure translations dynamically via the **Site Settings** under the **Translations & Languages** tab.

*   **Manage & Add Languages:** Add new languages (such as Spanish or French) by providing a locale code, native name, and selecting a template language to copy strings from. Custom languages can be activated/deactivated, renamed, or deleted directly in the UI.
*   **Live-Edit Mode:** Allows administrators to translate UI elements in real-time. When enabled, pencil icons appear next to translatable strings. Clicking them opens an interface where you can save changes as a *Database Override* or write them directly into the underlying *YAML locale files*.

For a detailed setup guide, see the **Translations & Languages** section on the [Settings](Settings.md) page.

### Time zone of the server

You can set the timezone of the server with

    config.time_zone = 'Berlin'

You can run `rake time:zones:all` to see all possible time zone values.
