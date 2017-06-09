#
# Cookbook Name:: ls_sql_server
# Recipe:: cluster
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# This recipe previously installed a Windows Failover cluster
# using the ls_window_cluster cookbook. It is prefered to use
# the win_cluster cookbook which is a resource cookbook that
# will provide a better options to install a cluster.

# Enable Alwayson
ls_sql_server_cluster 'Enable SQL Always On'
