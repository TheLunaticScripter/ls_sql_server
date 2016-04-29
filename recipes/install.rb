#
# Cookbook Name:: ls_sql_server
# Recipe:: install
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

<<<<<<< HEAD
# Install .Net 3.5 Framework

windows_feature "NetFx3" do
=======

# Install .Net 3.5 Framework

windows_feature 'NetFx3' do
>>>>>>> 3f3bb35d191a3c4847bf30fe78ee4186d98d9b12
  action :install
  all true
  source node['ls_sql_server']['netfx3_source']
end

<<<<<<< HEAD
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

=======
>>>>>>> 3f3bb35d191a3c4847bf30fe78ee4186d98d9b12
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
<<<<<<< HEAD
end 

sqlps_module_path = ::File.join(ENV['programfiles(x86)'], 'Microsoft SQL Server\110\Tools\PowerShell\Modules\SQLPS')

# TODO: Set SQL Memory on based on server memeory
sql_memory = node[:kernel][:cs_info][:total_physical_memory].to_f * 0.8
sql_memory_kb = sql_memory / 1_000_000
sql_memory_mb = sql_memory_kb.floor

log 'memory' do
  message "SQl Memory #{sql_memory_mb}"
  level :info
end

powershell_script 'Configure SQL Memory to 80 percent physical memory' do
  code <<-EOH
    Import-Module "#{sqlps_module_path}"
    cd \\sql\\$env:COMPUTERNAME
    $server = Get-Item default
    $server.Configuration.MaxServerMemory.ConfigValue = #{sql_memory_mb}
    $server.Configuration.Alter()
  EOH
  guard_interpreter :powershell_script
  not_if <<-EOH
    $set = $false
    try{
        Import-Module "#{sqlps_module_path}"
        cd \\sql\\$env:COMPUTERNAME
        $server = Get-Item default
        if($server.Configuration.MaxServerMemory.ConfigValue -eq #{sql_memory_mb}){$set = $true}
    }
    catch{}
    $set
  EOH
end
=======
end

>>>>>>> 3f3bb35d191a3c4847bf30fe78ee4186d98d9b12
