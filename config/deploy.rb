require "bundler/capistrano"

set :application, "chloroform"
set :user, "dave"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :use_sudo, false

set :scm, "git"
set :repository, "git@github.com:codebiff/#{application}.git"

set :bundle_flags, "--deployment --quiet --binstubs --shebang ruby-local-exec"
# set (:bundle_cmd) { "#{release_path}/bin/bundle" }
set :default_environment, { 'PATH' => "$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH" }

server "codebiff.com", :app, :web, :db, :primary => true

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

after "deploy", "deploy:cleanup" # keep only the last 5 releases

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end