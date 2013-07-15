# Dapistrano

Deploy Drupal with Drush Make.

* Ideas and code "borrowed" from https://github.com/previousnext/capistrano-drupal

## Pre-installation

* Set-up SSK keys between the server from which you will deploy and that of your target server.

## Installation

### Install dependencies


    $ gem install capistrano
    $ gem install railsless-deploy
    $ gem install dapistrano --local dapistrano-0.0.1.gem
    (For now, dapistrano is a UMN Internal utility)

### Initialize New Deployment Directory

    $ cd myproject
    $ dapify .

* Configure config/deploy/development.rb (Optional: create staging.rb and production.rb configurations based on this file)
* Create the directories specified in ":deploy_to"

### Run the setup task

    $ cap development deploy:setup

### Configure :deploy_to/shared directory

    # Place a copy of .htaccess, robots.txt and settings.php in your :deploy_to/shared directory:

    your_app_here.dev
    └── shared
        ├── files/
        ├── private/
        ├── .htaccess <-- you manually add
        ├── robots.txt <-- you manually add
        └── settings.php <-- you manually add

## Deploy!

    $ cap development deploy
    $ cap development deploy:rollback <-- You now have an "undo" button
    $ cap development drupal:updatedb <-- Site into maintenance mode, drush updatedb run, site put back online

