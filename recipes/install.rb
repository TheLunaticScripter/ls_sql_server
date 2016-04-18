#
# Cookbook Name:: ls_sql_server
# Recipe:: install
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# Install .Net 3.5 Framework

windows_feature "NetFx3" do
  action :install
  all true
  source node['ls_sql_server']['netfx3_source']
end

# Install Active Directory PowerShell tools to validate accounts exist

windows_feature "RSAT-AD-PowerShell" do 
  action :install
  all true
  provider :windows_feature_powershell
end

# Create Service Account if it doesn't exist

ls_windows_ad_svcacct "#{node['ls_sql_server']['sql_svc_account']}" do
  action :create
  svcacct node['ls_sql_server']['sql_svc_account']
  domain_name node['ls_sql_server']['domain_name']
  pswd node['ls_sql_server']['sql_account_pwd']
  ou "OU=Service Accounts"
end

# Install SQL 2012 Enterprise

config_file_path = win_friendly_path(File.join(Chef::Config[:file_cache_path], 'ConfigurationFile.ini'))

sql_sys_admin_list = if node['ls_sql_server']['sysadmins'].is_a? Array
                       node['ls_sql_server']['sysadmins'].map { |account| %("#{account}") }.join(' ') # surround each in quotes, space delimit list
                     else
                       %("#{node['ls_sql_server']['sysadmins']}") # surround in quotes
                     end

template config_file_path do
  source 'ConfigurationFile.ini.erb'
  variables(
    sqlSysAdminList: sql_sys_admin_list
  )
end

# Build safe password command line options for the installer
# see http://technet.microsoft.com/library/ms144259
passwords_options = {
  AGTSVCPASSWORD: node['ls_sql_server']['agent_account_pwd'],
  SQLSVCPASSWORD: node['ls_sql_server']['sql_account_pwd']
}.map do |option, attribute|
  next unless attribute
  # Escape password double quotes and backslashes
  safe_password = attribute.gsub(/["\\]/, '\\\\\0')
  "/#{option}=\"#{safe_password}\""
end.compact.join ' '

windows_package 'Microsoft SQL Server 2012 (64-bit)' do
  source "#{node['ls_sql_server']['sql_source']}\\setup.exe"
  installer_type :custom
  timeout 1500
  options "#{passwords_options} /ConfigurationFile=#{config_file_path} "
  action :install
end 
