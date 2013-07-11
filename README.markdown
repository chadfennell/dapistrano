# Dapistrano

Deploy Drupal with Drush Make.

* Ideas and code "borrowed" from https://github.com/previousnext/capistrano-drupal

## Installation

    $ gem install capistrano
    $ gem install railsless-deploy
    $ gem install dapistrano --local dapistrano-0.0.1.gem
    (For now, dapistrano is a UMN Internal utility)

## Create a New Deployment Directory

    $ mkdir -p myproject/config/deploy
    $ cd myproject
    $ touch capfile

## Edit the capfile

    $ require 'rubygems'
    $ require 'dapistrano'
    
![capfile](http://libsystems.org/images/dapistrano.png)

## Create stage files:

    $ touch config/deploy/development.rb
    $ touch config/deploy/staging.rb
    $ touch config/deploy/production.rb
    
    config
    └── deploy
        ├── development.rb
        ├── production.rb
        └── staging.rb

## Minimally configure development.rb and Drush Make Files

[Example Deployment File](https://gist.github.com/chadfennell/5978955):

![capfile](http://libsystems.org/images/deploymentconfig.png)

* Create the directories specified in ":deploy_to"

## Run the setup task

    $ cap development deploy:setup
    
## Configure :deploy_to/shared directory

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
    
