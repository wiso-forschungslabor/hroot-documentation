It is time to explain some concepts to give you a broad view of different parts of the system. This page aims at giving you an overview of where to look and what to expect. You can find more detailed information to some of the topics in later chapters. It might be convenient to have a local copy of the code to navigate through it, see [Manual Deployment](Manual-Deployment.md) to learn how to set up your environment.

## Rails concepts

### Directory structure

Every project developed with Ruby on Rails has a fixed directory structure. The hroot project has the same organisation. These are some folders and their contents:

- _app_: contains the application code. This folder is further structured in _controllers_ (application logic), _models_ (database access), _views_ (templates for all viewable pages) and _assets_ (Javascripts, CSS-files)
- _config_: contains all configuration files
- _db_: contains the description of the database (in form of _migrations_)
- _log_: contains log files (useful for debugging!)
- _test_: contains automated tests
- _public_: contains public assets (i.e. images)
- _uploads_: contains all uploaded files (not Rails standard, but added by hroot) 

You can see another overview on this page: http://guides.rubyonrails.org/v3.2.14/getting_started.html#creating-the-blog-application

### Environments and Configurations

Rails applications can run in different environments - that means the code is the same, but the configuration of the application is (very) different. Typically, a rails app runs in one of the following environments:

- _development_: The server is configured for development, meaning that on every reload of a page the code is reinterpreted. This is slow, but convenient for developers, who only have to reload a page to see changes in the code. The database typically contains a few test entries. Mails are not sent to actual users, and assets like javascripts or CSS style files are not compressed for performance.

- _test_: This environment contains configurations for automated tests. The test database is __destroyed and recreated__ for each run of the test suite, so be careful to always use a different database for the test environment.

- _production_: In this environment, the server is optimized for speed. Code is cached and not reloaded per page request, Javascripts and CSS are compressed for faster downloads. Page caching might be used, and emails are actually sent out to real users.

The configuration files for the different environments can be found in the folder [config/environments](https://github.com/wiso-forschungslabor/hroot/tree/master/config/environments). You can add more environments if needed, for example a staging environment for a test server close to the production environment to preview development changes to a wider audience.

### Gems, Gemfile and Bundler

Packages and external add-ons are called gems in the ruby world. hroot uses many of those, for example [devise](https://github.com/plataformatec/devise) for login and authentication, or [haml](http://haml.info/) as a template language. You can find a list of all gems in the [Gemfile](https://github.com/wiso-forschungslabor/hroot/tree/master/Gemfile). Gems are installed and updated with a tool called bundler, which reads the Gemfile, downloads and installes the necessary gems and keeps track of versions in the file Gemfile.lock (please NEVER edit this file).

### Internationalization (I18n)

hroot uses the rails i18n framework, meaning that all text strings are stored in languages files (in .yml format). This way the user can choose the interface language, and it is fairly easy to add more languages. See [config/locales/en.yml](https://github.com/wiso-forschungslabor/hroot/blob/master/config/locales/en.yml) for an example. Currently, we have locales for English and German, we are more than happy about additional locales, please contribute if you have the time.

### rake and rails

In ealier versions of hroot and rails, rake was used as a task runner - however, most tasks are not run using the `rails` command. You can get an overview over all tasks by running 

    rails -T

in your hroot home folder.

### Assets and asset compilation

Rails supports a concept called asset compilation. That means that in production mode, all Javascript and CSS files are minimized by removing all whitespace characters (and many other optimizations). This effectively makes files unreadable, but they are a lot smaller and can be transmitted faster. When you run hroot in production mode, you have to run the asset compilation to have styles and javascript support. If you can't see images or many buttons are unresponsive after installation, you might have to run the asset compilation.

### Migrations

In rails, a database migration is a small script that creates tables, updates and alters them and performs necessary changes to data in case a new feature requires changes in the databases. Over the time, [quite a few migrations have accumulated](https://github.com/wiso-forschungslabor/hroot/tree/master/db/migrate). These migrations have to be executed on installation to create the hroot database

### Webservers

To run hroot in production mode, a webserver is required. For testing purposes, a small server (webrick) is included in rails, so it is possible to start the application locally for testing. However, in a production environment a webserver with rails support is needed. There are a couple of options out there, we recommend using Apache or Nginx together with [Phusion Passenger](https://www.phusionpassenger.com/). You can think of passenger as a module for Apache which enables running Rails projects, similar to mod_php, which enables Apache to run PHP.

Another popular server option is [unicorn](http://unicorn.bogomips.org/), in this case Apache serves only as a proxy.
