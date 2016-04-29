#
# Cookbook Name:: ls_sql_server
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

<<<<<<< HEAD
=======

>>>>>>> 3f3bb35d191a3c4847bf30fe78ee4186d98d9b12
# Install SQL 2012 Enterprise

include_recipe 'ls_sql_server::install'

# install cluster
if node['ls_sql_server']['cluster'] == 'cluster'
  include_recipe 'ls_sql_server::cluster'
end
