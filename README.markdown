# Dapistrano

Deploy Drupal with Drush Make.

* Ideas and code "borrowed" from https://github.com/previousnext/capistrano-drupal

## Pre-installation

* Set up SSH key access from your deployment machine, e.g. your laptop, to your target machine, e.g. your web server.
* Ensure that your Drupal database is accessible from your target machine.

## Installation

### Install dependencies

For now, dapistrano is a UMN-internal utility, and not released to rubygems.org. Therefore, start by
cloning this dapistrano repository on your deployment machine, and then:

    $ gem install capistrano
    $ gem install railsless-deploy
    $ gem install dapistrano --local /path/to/dapistrano-0.0.1.gem

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

