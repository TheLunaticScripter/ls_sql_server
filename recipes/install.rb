#
# Cookbook Name:: ls_sql_server
# Recipe:: install
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

ls_sql_server_install 'Install SQL Server 2012' do
  netfx3_source node['ls_sql_server']['netfx3_source']
  sys_admin_group node['ls_sql_server']['sysadmins']
  sql_svc_account node['ls_sql_server']['sql_account']
  sql_svc_acct_pswd node['ls_sql_server']['sql_account_pwd']
  install_source node['ls_sql_server']['sql_source']
end

ls_sql_server_memory 'Set SQL memory to 80%'
