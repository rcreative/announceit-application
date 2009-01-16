default_run_options[:pty] = true

set :application, "announce"
set :repository,  "git@recursivecreative.unfuddle.com:recursivecreative/announce.git"

set :deploy_to, "/home/deploy/#{application}"
set :user, "deploy"
set :use_sudo, false
set :port, "42832"

set :scm, :git

role :app, "173.45.235.36"
role :web, "173.45.235.36"
role :db,  "173.45.235.36", :primary => true

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
  ServerName ai.recursivecreative.net
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