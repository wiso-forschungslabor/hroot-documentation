Now that we have covered a broad range of configuration options, it is time to describe a realistic setting for running hroot in production. You probably have started a local server in development mode with the command `rails server`. When you did this, a small built in web server named webrick was started, this server is part of the rails distribution to enable developers to work, but this server is not a good choice to run a live site with many users.

In a production environment, you typically want to have a more powerful web server (apache, nginx), which runs your hroot installation. Unfortunately neither apache nor nginx in their base versions support Rails projects. A very good free option to run Rails projects using Apache is Phusion Passenger - we advise you to use this library for production mode. Installation and maintenance of a webserver is beyond the scope of this documentation, ask your local administrator or computer guy for help if you need assistance.

You can find the installation instructions and the software on this site:

https://www.phusionpassenger.com

There are several way of installing Phusion Passenger. On way is to follow the instructions in the manual of Phusion Passenger: 
https://www.phusionpassenger.com/docs/tutorials/deploy_to_production/

Both installation types will guide you through the setup, and setup typically involves the installation of several linux packages as a requirement. The documentation of Passenger is very good, so we would like to point you there for questions.

Once you have successfully installed Phusion Passenger, you can change the apache configuration to instruct Apache to serve your rails project. The location of the config files of Apache differs, you will typically have a virtual server for your domain you want to use for hroot. To configure a Rails project, you have to add the following code to your apache config file:


    <VirtualHost your_server_address:80 >
      ServerName "www.your-server-name.org"

      DocumentRoot /path/to/your/installation/of/hroot/public

      <Directory /path/to/your/installation/of/hroot/public>
        RailsEnv production

        # This relaxes Apache security settings.
        AllowOverride all

        # MultiViews must be turned off.
        Options -MultiViews
      </Directory>
    </VirtualHost>

Now you should be able to access your server with the url `www.your-server-name.org`, running in production mode.

We also advise strongly you to use `https` to serve hroot. Please obtain the necessary ssl certificates and run your server securely.


## Assets in the production environment

To speed up serving the static assets, these should get precompiled in a production environment. Missing this step is often also the reason for a broken layout once the server is put into production mode.

To generate the production ready CSS and JS files, run

    RAILS_ENV=production rails assets:precompile

This step must be repeated if you make changes to the javascript or CSS files of hroot.
