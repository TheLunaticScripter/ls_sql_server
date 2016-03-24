#
# Cookbook Name:: ls_sql_server
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.


# Install SQL 2012 Enterprise

include_recipe 'sql-server::install'

# install cluster
if node['sql-server']['cluster'] == 'cluster'
  include_recipe 'sql-server::cluster'
end
