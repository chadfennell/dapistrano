require 'capistrano'
module Capistrano
  class Configuration
    def remove_file_if_exists(file)
      run "if test -f #{file}; then rm #{file}; fi"
    end
    def remove_dir_if_exists(dir)
      run "if test -d #{dir}; then rm -rf #{dir}; fi"
    end
    def symlink_file_if_exists(file, link)
      run "if test -f #{file}; then ln -nfs #{file} #{link}; fi"
    end
    def symlink_dir_if_exists(dir, link)
      run "if test -d #{dir}; then ln -nfs #{dir} #{link}; fi"
    end
  end
  module Dapistrano
    def self.load_into(configuration)
      configuration.load do

        require 'capistrano/recipes/deploy/scm'
        require 'capistrano/ext/multistage'
        require 'railsless-deploy'
        require 'net/http'
        require 'uri'

        # =========================================================================
        # These variables may be set in the client capfile if their default values
        # are not sufficient.
        # =========================================================================


        set :default_stage, "development"
        set :stages, %w(production development staging)
        set :scm, :git
        set :branch, "master"
        set :drush_command_path, "drush"
        set :group_writable, true
        set :use_sudo, false

        set(:deploy_to) { "/var/www/#{application}" }
        set :shared_children, ['files', 'private']
        set :core_files_to_remove, [
          'INSTALL.mysql.txt',
          'INSTALL.pgsql.txt',
          'CHANGELOG.txt',
          'COPYRIGHT.txt',
          'INSTALL.txt',
          'LICENSE.txt',
          'MAINTAINERS.txt',
          'UPGRADE.txt'
        ]

        # files that frequently require local customization
        set :override_core_files, ['robots.txt', '.htaccess']

        # Custom symlinks allow for apps to exist along side drupal
        after "deploy:update_code", "drupal:update_code", "drupal:symlink_shared", "custom_tasks:symlink", "drush:cache_clear"

        # Allow for drupal drush commands and such to be issued
        after "deploy", "custom_tasks:post_deploy"

        # WARNING! This task must be executed AFTER deploy:create_symlink, because it
        # depends on the newly-created docroot being web-accessible.
        after "deploy:create_symlink", "php:apc_clear"

        namespace :deploy do
          desc <<-DESC
            Prepares one or more servers for deployment. Before you can use any \
            of the Capistrano deployment tasks with your project, you will need to \
            make sure all of your servers have been prepared with `cap deploy:setup'. When \
            you add a new server to your cluster, you can easily run the setup task \
            on just that server by specifying the HOSTS environment variable:

              $ cap HOSTS=new.server.com deploy:setup

            It is safe to run this task on servers that have already been set up; it \
            will not destroy any deployed revisions or data.
          DESC
          task :setup, :except => { :no_release => true } do
            dirs = [deploy_to, releases_path, shared_path].join(' ')
            run "#{try_sudo} mkdir -p #{releases_path} #{shared_path}"
            run "#{try_sudo} chown -R #{user}:#{runner_group} #{deploy_to}"
            sub_dirs = shared_children.map { |d| File.join(shared_path, d) }
            run "#{try_sudo} mkdir -p #{sub_dirs.join(' ')}"
            run "#{try_sudo} chown -R #{user}:#{runner_group} #{shared_path}"
            run "#{try_sudo} chmod -R 2775 #{shared_path}"
          end

          # removed non rails stuff, ensure group writabilty
          task :finalize_update, :roles => :web, :except => { :no_release => true } do
            run "chmod -R g+w #{latest_release}" if fetch(:group_writable, true)
          end
        end

        namespace :drupal do

          task :update_code do
            # Locate the make file and run it
            args = fetch(:make_args, "")
            run "ls #{latest_release} | grep \.make" do |channel, stream, make_file|
              run "cd #{latest_release}; #{drush_command_path} make #{args} #{make_file} ."
              run "rm #{latest_release}/#{make_file}"
            end
            
            # If there's a README.md that accompanies the drush make file, remove it, too:
            remove_file_if_exists( "#{latest_release}/README.md" )

            core_files = core_files_to_remove.map { |cf| File.join(latest_release, cf) }
            run "rm #{core_files.join(' ')}"
          end

          desc "Symlink settings and files to shared directory. This allows the settings.php and \
            and sites/default/files directory to be correctly linked to the shared directory on a new deployment."
          task :symlink_shared do
            ["files", "private", "settings.php"].each do |asset|
              run "rm -rf #{latest_release}/#{asset} && ln -nfs #{shared_path}/#{asset} #{latest_release}/sites/default/#{asset}"
            end
            override_core_files.each do |file|
              run "rm #{latest_release}/#{file} && ln -nfs #{shared_path}/#{file} #{latest_release}/#{file}"
            end
          end


        end

        namespace :drush do

          desc "Run Drupal database migrations if required"
          task :updatedb, :on_error => :continue do
            :site_offline
            run "#{drush_command_path} -r #{latest_release} updatedb -y"
            :site_online
          end

          desc "Clear the drupal cache"
          task :cache_clear, :on_error => :continue do
            run "#{drush_command_path} -r #{latest_release} cc all"
          end

          desc "Set the site offline"
          task :site_offline, :on_error => :continue do
            run "#{drush_command_path} -r #{latest_release} vset site_offline 1 -y"
            run "#{drush_command_path} -r #{latest_release} vset maintenance_mode 1 -y"
          end

          desc "Set the site online"
          task :site_online, :on_error => :continue do
            run "#{drush_command_path} -r #{latest_release} vset site_offline 0 -y"
            run "#{drush_command_path} -r #{latest_release}} vset maintenance_mode 0 -y"
          end

        end

        namespace :php do

          # WARNING! This task must be executed AFTER deploy:create_symlink, because it
          # depends on the newly-created docroot being web-accessible.
          # NOTE: This method of clearing the cache was inspired by: http://stackoverflow.com/a/3580939
          task :apc_clear do
            puts 'Clearing APC Cache to prevent memory allocation errors.'

            apc_clear_basename = 'apc_clear.php'
            apc_clear_path = latest_release + '/' + apc_clear_basename
            apc_clear_uri = application_uri + '/' + apc_clear_basename

            apc_clear_code = <<-CODE
<?php
apc_clear_cache();
apc_clear_cache('user');
apc_clear_cache('opcode');
CODE
            put apc_clear_code, apc_clear_path

            puts 'Sending HTTP GET request to: ' + apc_clear_uri
            uri = URI.parse(apc_clear_uri)
            http = Net::HTTP.new(uri.host, uri.port)
            http = support_https(uri.scheme, http)
            request = Net::HTTP::Get.new(uri.request_uri)
            request = support_basic_auth(request)
            response = http.request(request)
            if response.code != '200'
              raise "Failed to clear APC cache. GET #{apc_clear_uri} returned #{response.code}."
            end

            run "rm #{apc_clear_path}"
          end

          def support_basic_auth(request)
            if defined? basic_auth
              request.basic_auth(basic_auth[0], basic_auth[1])
            end
            request
          end

          def support_https(scheme, http)
            if (scheme == 'https')
              http.use_ssl = true
              http.verify_mode = OpenSSL::SSL::VERIFY_NONE
            end
            http
          end
        end

      end


    end
  end
end

# may as well load it if we have it
if Capistrano::Configuration.instance
  Capistrano::Dapistrano.load_into(Capistrano::Configuration.instance)
end
