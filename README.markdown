# Dapistrano

Deploy Drupal with Drush Make.

* Ideas and code "borrowed" from https://github.com/previousnext/capistrano-drupal

## Pre-installation

* Set up SSH key access from your deployment machine, e.g. your laptop, to your target machine, e.g. your web server.
* Ensure that your Drupal database is accessible from your target machine.

## Installation

### Bundler

We recommend using [Bundler](http://bundler.io/) to install Dapistrano. If you don't already have it installed:

    $ sudo gem install bundler
    
The rest of these docs will assume you are using Bundler. 

### Project Directory

All of the Dapistrano files for a Drupal website live in a single directory, even if you're installing that site on multiple machines. We'll use Bundler to install Dapistrano's dependency gems into this directory, too.

    $ mkdir ~/my-site-dapistrano/
    $ cd ~/my-site-dapistrano/
    
### Gemfile

Create a ```Gemfile``` that tells Bundler where to find Dapistrano and its dependencies:

    source 'https://rubygems.org'
    gem 'dapistrano', :git => 'git://github.com/chadfennell/dapistrano.git'

### Install with Bundler

This ```--path``` parameter tells Bundler where to install Dapistrano and its dependencies:

    $ bundle install --path vendor/bundle    

Dapistrano and Capistrano come with executables. Use Bundler to create versions of those executables that will use only the gems in the bundle you just installed:

    $ bundle install --binstubs
    
You should now have executables in ~/my-site-dapistrano/bin/.

## Initialize Project Directory

    $ bin/dapify .

* Configure config/deploy/development.rb (Optional: create staging.rb and production.rb configurations based on this file)
* Create the directories specified in ":deploy_to"

## Run Setup

    $ bin/cap development deploy:setup

## Configure :deploy_to/shared Directory

Place a copy of ```.htaccess```, ```robots.txt``` and ```settings.php``` in your ```:deploy_to/shared``` directory:

    your_app_here.dev
    └── shared
        ├── files/
        ├── private/
        ├── .htaccess <-- you manually add
        ├── robots.txt <-- you manually add
        └── settings.php <-- you manually add

## Deploy!

    $ bin/cap development deploy
    $ bin/cap development deploy:rollback <-- You now have an "undo" button
    $ bin/cap development drupal:updatedb <-- Site into maintenance mode, drush updatedb run, site put back online

