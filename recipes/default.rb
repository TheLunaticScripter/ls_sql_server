#
# Cookbook Name:: ls_sql_server
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# Install SQL 2012 Enterprise

include_recipe 'ls_sql_server::install'

# install cluster
if node['ls_sql_server']['cluster'] == 'cluster'
  include_recipe 'ls_sql_server::cluster'
end
