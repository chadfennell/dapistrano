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

All of the Dapistrano files for a Drupal website live in a single directory, even if you're installing that site on 
multiple machines. We'll use Bundler to install Dapistrano's dependency gems into this directory, too.

    $ mkdir ~/example.com-dapistrano/
    $ cd ~/example.com-dapistrano/
    
### Gemfile

Create a ```Gemfile``` that tells Bundler where to find Dapistrano and its dependencies:

```ruby
source 'https://rubygems.org'
gem 'dapistrano', :git => 'git://github.com/chadfennell/dapistrano.git'
```

### Install with Bundler

The ```--path``` parameter tells Bundler where to install Dapistrano and its dependencies:

    $ bundle install --path vendor/bundle    

Dapistrano and Capistrano come with executables. Use Bundler to ensure those executables will use only the gems in the
bundle you just installed, and not any versions of those same gems that may be installed elsewhere. There are two ways to do this.
We recommend this...

    $ bundle install --binstubs

...which will install bundler-wrapped executables in ```./bin```. The rest of these docs will assume the use of this method.

The other way is to prepend each executable call with ```bundle exec```. See the "Executables" section of [Gem Versioning and Bundler: Doing it Right](http://yehudakatz.com/2011/05/30/gem-versioning-and-bundler-doing-it-right/) for more details.

## Initialize Project Directory

    $ bin/dapify .

Dapistrano uses a Capistrano extension called [Multistage](https://github.com/capistrano/capistrano/wiki/2.x-Multistage-Extension),
which allows us to use a separate configuration file for each stage, i.e. environment, to which you will deploy your Drupal site.
Multistage expects to find configuration files, named ```#{stage}.rb```, in the ```config/deploy/``` directory. Dapistrano supports
these stages:

* development
* staging
* production

```dapify``` creates a boilerplate ```config/deploy/development.rb``` file. Next:

* Modify ```config/deploy/development.rb```, replacing the boilerplate values with your Drupal site's values.
* Optional: Create ```staging.rb``` and/or ```production.rb``` configuration files.
* Create the remote directories specified in ```:deploy_to``` in your configuration file(s).

## Run Setup

This command creates some, but not all, empty files and directories in ```:deploy_to/shared/``` that are
common or even required for setting up a Drupal site:

    $ bin/cap development deploy:setup

## Populate :deploy_to/shared/

Manually populate the empty files and directories, created by running the above command,
with content specific to your site and environment. These are the most-commonly-used and -needed:

    dev.example.com:#{:deploy_to}/
    └── shared/
        ├── .htaccess
        ├── robots.txt
        └── sites/default/
                  ├── settings.php
                  ├── files/
                  └── private/

### Adding Custom Files and Directories to :deploy_to/shared/

Dapistrano automatically creates symbolic links, in the ```:deploy_to/current/``` document root, to some files and directories
in ```:deploy_to/shared/```. These are defined in the ```:shared_symlinks``` array. Customizing the symbolic links Dapistrano creates
is as easy is modifying that array. In your recipes, you can override ```:shared_symlinks``` completely, or keep the defaults and
add your custom files and directories to it, like this:

```ruby
set :shared_symlinks, shared_symlinks + ['your','custom','items']
```

All items are assumed to be relative to ```:deploy_to/shared/```, and all links will be relative to ```:deploy_to/current/```.
This allows for deep linking into directories created by drush make. For example, one of the default symbolic links is ```sites/default```.

## Deploy!

    $ bin/cap development deploy
    $ bin/cap development deploy:rollback <-- You now have an "undo" button
    $ bin/cap development drush:updatedb <-- Site into maintenance mode, drush updatedb run, site put back online

