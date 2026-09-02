### Starting a local server for testing and evaluation

You now should be able to launch a local server in development mode with the command

    rails server

or

    RAILS_ENV=production rails server

in case you only have a production environment.

Access the url http://localhost:3000 to see your server in action for the first time. You should be able to log in with your admin user account you created in an earlier step. If you want to evaluate hroot, you can do so with a local server, just keep in mind, that for a real installation, you need to setup hroot as a production server together with a webserver (i.e. apache). Also, several features are not working in the local server mode, a background job for sending emails is missing for example, so no emails will be sent out by the server.

***
**Do not use the development server on port 3000 to run a live hroot site! The performance and security of the development server is not sufficient to run a website with hundreds of users!**
***


### Running automated tests

To verify if your installation is working, you can run the automated test suite. You must have a local test database configured for this feature to work.

First, we initialize the test database. Run the following command in the hroot main folder:

    rails db:test:prepare

This will create a test database from your schema - this step might not be necessary, as the test database might already have been initialized, but better safe than sorry.

Now you can run the test suite with

    rails test

This might take a couple of minutes, resulting in the message that a number of tests have been run without error. Whenever you perform major changes to the system, you can run the tests again to verify that nothing important has been broken. Our test coverage is currently around 65%, but we hope to improve this number in the future.



