default_run_options[:pty] = true

set :application, "announce"
set :repository,  "git@recursivecreative.unfuddle.com:recursivecreative/announce.git"

set :deploy_to, "/home/deploy/#{application}"
set :user, "deploy"
set :use_sudo, false
set :port, "42832"

set :scm, :git

# DNS records pointing to this server
# teaserapp.com
# myteaserpage.com
# announceapp.com
# announceitapp.com

role :app, "173.45.235.36"
role :web, "173.45.235.36"
role :db,  "173.45.235.36", :primary => true

namespace :db do
  task :backup_name, :roles => :db, :only => { :primary => true } do
    now = Time.now
    run "mkdir -p #{shared_path}/db_backups"
    backup_time = [now.year,now.month,now.day,now.hour,now.min,now.sec].join('-')
    set :backup_file, "#{shared_path}/db_backups/announce_production-snapshot-#{backup_time}.sql"
  end

  desc "Backup your database to shared_path+/db_backups"
  task :dump, :roles => :db, :only => {:primary => true} do
    backup_name
    database_info = YAML.load_file('config/database.yml')['production']
    run "mysqldump --add-drop-table -u #{database_info['username']} -p#{database_info['password']} announce_production | bzip2 -c > #{backup_file}.bz2"
  end
  
  desc "Sync your production database to your local workstation"
  task :clone_to_local, :roles => :db, :only => {:primary => true} do
    backup_name
    dump
    get "#{backup_file}.bz2", "/tmp/#{application}.sql.gz"
    development_info = YAML.load_file("config/database.yml")['development']
    run_str = "bzcat /tmp/#{application}.sql.gz | mysql -u #{development_info['username']} -p#{development_info['password']}  #{development_info['database']}"
    %x!#{run_str}!
  end
end

namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end
  
  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
end

namespace :slicehost do
  desc "Configure VHost"
  task :config_vhost do
    vhost_config =<<-EOF
<VirtualHost *:80>
  ServerName announceitapp.com
  DocumentRoot #{current_path}/public
</VirtualHost>
    EOF
    put vhost_config, "src/vhost_config"
    sudo "mv src/vhost_config /etc/apache2/sites-available/#{application}"
    sudo "a2ensite #{application}"
  end
  
  desc "Reload Apache"
  task :apache_reload do
    sudo "/etc/init.d/apache2 reload"
  end
end