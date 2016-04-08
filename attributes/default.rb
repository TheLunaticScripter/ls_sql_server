default['ls_sql_server']['netfx3_source'] = 'c:\Sources\sxs'
default['ls_sql_server']['sql_svc_account'] = 'sql.service'
default['ls_sql_server']['domain_name'] = "thewall.local"
default['ls_sql_server']['create_sql_admins_group'] = false
default['ls_sql_server']['sql_admin_group_member'] = "$env:USERNAME"
default['ls_sql_server']['sql_admin_group_ou'] = "OU=TheWall,DC=thewall,DC=local"
default['ls_sql_server']['sql_account'] = 'THEWALL.LOCAL\\sql.service'
default['ls_sql_server']['sql_source'] = 'c:\\Sources\\SQL2012SP3'
default['ls_sql_server']['sysadmins'] = "THEWALL.LOCAL\\SQL Administrators"
default['ls_sql_server']['agent_account_pwd'] = '!QAZSE$1qazse4'
default['ls_sql_server']['sql_account_pwd'] = '!QAZSE$1qazse4'
default['ls_sql_server']['cluster'] = "standalone"
default['ls_windows_cluster']['cluster_name'] = "SQLtestCluster"
default['ls_windows_cluster']['cluster_ip_address'] = '10.0.3.232'