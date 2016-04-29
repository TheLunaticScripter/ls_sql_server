#
# Cookbook Name:: ls_sql_server
# Recipe:: cluster
#
# Copyright (c) 2016 The Authors, All Rights Reserved.


# Install and configure cluster
include_recipe 'ls_windows_cluster'

# Enable Alwayson
sqlps_module_path = ::File.join(ENV['programfiles(x86)'], 'Microsoft SQL Server\110\Tools\PowerShell\Modules\SQLPS')

powershell_script 'Enable-SQLAlwayson' do
  code <<-EOH
    Import-Module "#{sqlps_module_path}"
    Enable-SQLAlwaysOn -Path "SQLSERVER:\\SQL\\$env:COMPUTERNAME\\DEFAULT" -Force
  EOH
  guard_interpreter :powershell_script
  not_if <<-EOH
    Import-Module "#{sqlps_module_path}"
    cd \\sql\\$env:COMPUTERNAME\\DEFAULT
    (Get-Item .).IsHadrEnabled
  EOH
end

