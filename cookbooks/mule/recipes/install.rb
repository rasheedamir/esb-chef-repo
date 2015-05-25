#
# Cookbook Name:: mule
# Recipe:: install
#
# Copyright 2015, Rasheed Amir
#
# All rights reserved - Do Not Redistribute
#

include_recipe "java"

ZIP_FILE = "mule-standalone-#{node['mule']['version']}.zip"
MULE_URL = "https://repository-master.mulesoft.org/nexus/content/repositories/releases/org/mule/distributions/mule-standalone/#{node['mule']['version']}/#{ZIP_FILE}"

#download mule zip file
remote_file "#{node['mule']['install_dir']}/#{ZIP_FILE}" do
  source MULE_URL
  action :nothing
end

#only if it has changed
http_request "HEAD #{MULE_URL}" do
  message ""
  url MULE_URL
  action :head
  if File.exists?("#{node['mule']['install_dir']}/#{ZIP_FILE}")
    headers "If-Modified-Since" => File.mtime("#{node['mule']['install_dir']}/#{ZIP_FILE}").httpdate
  end
  notifies :create, resources(:remote_file => "#{node['mule']['install_dir']}/#{ZIP_FILE}"), :immediately
end

package "unzip" do
  action :install
end

#unzip mule
execute "unzip" do
  command "unzip #{node['mule']['install_dir']}/#{ZIP_FILE} -d #{node['mule']['install_dir']}"
  creates "#{node['mule']['install_dir']}/#{ZIP_FILE.gsub('.zip', '')}"
  action :run
  notifies :run, "execute[run_mule]", :immediately
end

execute "run_mule"  do
  command "#{node['mule']['install_dir']}/#{ZIP_FILE.gsub('.zip', '')}/bin/mule > #{node['mule']['log_dir']}/mule.log &"
  creates "#{node['mule']['log_dir']}/mule.log"
  action :nothing
end

mule_home = node['mule']['install_dir'] + "/" + ZIP_FILE.gsub('.zip', '')

ruby_block  "set-env-mule-home" do
   block do
       ENV["MULE_HOME"] = mule_home
    end
       not_if { ENV["MULE_HOME"] == mule_home }
end

file "/etc/profile.d/MULE_HOME.sh" do
   content <<-EOS
      export MULE_HOME=#{node['mule']['install_dir']}/#{ZIP_FILE.gsub('.zip', '')}
   EOS
   mode 0755
end
