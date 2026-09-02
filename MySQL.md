hroot uses MySQL as a database server. On many ubuntu versions, MySQL is already installed, you can install it with the following command:

    sudo apt-get install mysql-server mysql-client libmysqlclient-dev

For more information see https://help.ubuntu.com/12.04/serverguide/mysql.html or the documentation of your linux distribution. You can also find a lot of information in the [MySQL installation guide](http://dev.mysql.com/doc/refman/5.5/en/installing.html).

You should create a separate user for hroot with a secure password. In a production environment with real users, it is the best option to allow access only from the local machine (or the machine where the webserver is running). Since this is all basic server administration knowledge, we will not go into further detail here and assume that you have a database user named hroot and you can connect to the database server using this user with the command

    mysql -u hroot -p

Depending on your setup, hroot will use the following databases:

- If you want to develop or to test hroot locally, the database hroot_development will be used
- If you want to run the automated test suite to verify your installation, the hroot_test database will be used
- If you want to run hroot in a production environment (with real users and real data), typically a database named hroot_production is used

Of course you can use any other name, but it is useful to know the default names. If you use the standard configuration, these databases will be used and created.
