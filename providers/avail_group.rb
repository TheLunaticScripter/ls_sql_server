def load_current_resource
  @current_resource = Chef::Resource::LsSqlServerAvailGroup.new(@new_resource.name)
  @current_resource.ag_name(@new_resource.ag_name)
  @current_resource.backup_share(@new_resource.backup_share)
  @current_resource.db_name(@new_resource.db_name)
  @current_resource.availability_mode(@new_resource.availability_mode)
  @current_resource.failover_mode(@new_resource.failover_mode)
  @current_resource.primary_server(@new_resource.primary_server)
  @current_resource.replica_server(@new_resource.replica_server)
  @current_resource.fqdn(@new_resource.fqdn)
end

action :create do
  converge_by("Create database availability group #{@new_resource.ag_name}") do
    create_availability_group
  end
end

action :add_replica do
  converge_by("Add SQL server as replica to availability group#{@new_resource.ag_name}") do
    add_replica
  end 
end

action :add_db do
  converge_by("Add databse #{@new_resource.db_name} to availability group #{@new_resource.ag_name}") do
    add_db
  end
end

def whyrun_supported?
  true
end

private



def avail_exist?
  sqlps_module_path = ::File.join(ENV['programfiles(x86)'], 'Microsoft SQL Server\110\Tools\PowerShell\Modules\SQLPS')
  powershell_script "Test Availabilty Group #{@new_resource.ag_name} exists" do
    code <<-EOH
      $exists = $false
      try{
          Import-Module "#{sqlps_module_path}" -ErrorAction SilentlyContinue
          $ag = Invoke-Sqlcmd -Query "SELECT * FROM sys.availability_groups WHERE name = "#{new_resource.ag_name}""
          if($ag.name -eq "#{new_resource.ag_name}"){$exists = $true}
      }
      catch{}
      $exists
    EOH
  end
end

def create_availability_group
  # Create replica builder string for template
    
  time = Time.now.getutc
  
  sqlps_module_path = ::File.join(ENV['programfiles(x86)'], 'Microsoft SQL Server\110\Tools\PowerShell\Modules\SQLPS')
  # Create template files
  template 'c:\\chef\\cache\\set_endpoint.sql' do
    path 'c:\\chef\\cache\\set_endpoint.sql'
    source 'set_endpoint.sql.erb'
    cookbook 'ls_sql_server'
  end
  template 'c:\\chef\\cache\\set_event_session.sql' do
    path 'c:\\chef\\cache\\set_event_session.sql'
    source 'set_event_session.sql.erb'
    cookbook 'ls_sql_server'
  end
  template 'c:\\chef\\cache\\create_avail_group.sql' do
    path 'c:\\chef\\cache\\create_avail_group.sql'
    source 'create_avail_group.sql.erb'
    cookbook 'ls_sql_server'
    variables(
        avail_group_name: new_resource.ag_name,
        db_name: new_resource.db_name,
        primary_server: new_resource.primary_server,
        secondary_server: new_resource.replica_server,
        domain: new_resource.fqdn
    )
  end
  template 'c:\\chef\\cache\\join_avail_group.sql' do
    path 'c:\\chef\\cache\\join_avail_group.sql'
    source 'join_avail_group.sql.erb'
    cookbook 'ls_sql_server'
    variables(
        avail_group_name: new_resource.ag_name
    )
  end
  
  template 'c:\\chef\\cache\\join_db_replica.sql' do
    path 'c:\\chef\\cache\\join_db_replica.sql'
    source 'join_db_replica.sql.erb'
    cookbook 'ls_sql_server'
    variables(
        avail_group_name: new_resource.ag_name,
        db_name: new_resource.db_name
    )
  end
  
  # Create Database if it doesn't exists
  ls_sql_server_database 'Create database #{new_resource.db_name}' do
    action :create
    name new_resource.db_name
    server_instance new_resource.primary_server
  end
  
  ls_sql_server_database 'Backup #{new_resource.db_name}' do
    action :backup
    name new_resource.db_name
    backup_location new_resource.backup_share
    backup_name "#{new_resource.db_name}AGCreate.bak"
    server_instance new_resource.primary_server
  end
  
  time_string = time.strftime("%Y%m%d%H%M%S")
  
  log_backup_name = "#{new_resource.db_name}AGcreate_#{time_string}.trn"
  
  ls_sql_server_database 'Backup #{new_resource.db_name} log' do
    action :backup_log
    name new_resource.db_name
    backup_location new_resource.backup_share
    backup_name log_backup_name
    server_instance new_resource.primary_server
  end
  
  # Set endpoints
  powershell_script 'Configure endpoints on #{new_resource.primary_server}' do
    code <<-EOH
      Import-Module "#{sqlps_module_path}"
      Invoke-Sqlcmd -InputFile "c:\\chef\\cache\\set_endpoint.sql" -ServerInstance "#{new_resource.primary_server}"
      
    EOH
  end
  powershell_script 'Configure endpoints on #{new_resource.replica_server}' do
    code <<-EOH
      Import-Module "#{sqlps_module_path}"
      Invoke-Sqlcmd -InputFile "c:\\chef\\cache\\set_endpoint.sql" -ServerInstance "#{new_resource.replica_server}"
    EOH
  end
  
  # Set event sessions
  powershell_script 'Configure event sessions on #{new_resource.primary_server}' do
    code <<-EOH
      Import-Module "#{sqlps_module_path}"
      Invoke-Sqlcmd -InputFile "c:\\chef\\cache\\set_event_session.sql" -ServerInstance "#{new_resource.primary_server}"
    EOH
  end
  powershell_script 'Configure event sessions on #{new_resource.replica_server}' do
    code <<-EOH
      Import-Module "#{sqlps_module_path}"
      Invoke-Sqlcmd -InputFile "c:\\chef\\cache\\set_event_session.sql" -ServerInstance "#{new_resource.replica_server}"
    EOH
  end
  
  # Create availability group on Primary SQL server
  powershell_script 'Create availablity group #{new_resource.ag_name} on #{new_resource.primary_server}' do
    code <<-EOH
      Import-Module "#{sqlps_module_path}"
      Invoke-Sqlcmd -InputFile "c:\\chef\\cache\\create_avail_group.sql" -ServerInstance "#{new_resource.primary_server}"
    EOH
  end
  powershell_script 'Join replica server #{new_resource.replica_server} to availablity group #{new_resource.ag_name}' do
    code <<-EOH
      Import-Module "#{sqlps_module_path}"
      Invoke-Sqlcmd -InputFile "c:\\chef\\cache\\join_avail_group.sql" -ServerInstance "#{new_resource.replica_server}"
    EOH
  end
  
  # Backup Database on Primary and Restore on replica
  
  ls_sql_server_database 'Restore database #{new_resource.db_name} to server #{new_resource.replica_server}' do
    action :restore_backup
    name new_resource.db_name
    backup_location new_resource.backup_share
    backup_name "#{new_resource.db_name}AGCreate.bak"
    server_instance new_resource.replica_server
  end
  
  ls_sql_server_database 'Restore database #{new_resource.db_name} log to server #{new_resource.replica_server}' do
    action :restore_log
    name new_resource.db_name
    backup_location new_resource.backup_share
    backup_name log_backup_name
    server_instance new_resource.replica_server
  end
  
  # Join Database to AG on Replica server
  powershell_script 'Join Database #{new_resource.db_name} to #{new_resource.name} availability group' do
    code <<-EOH
      Import-Module "#{sqlps_module_path}"
      Invoke-Sqlcmd -InputFile "c:\\chef\\cache\\join_db_replica.sql" -ServerInstance "#{new_resource.replica_server}"
    EOH
  end
end

def add_replica
  # TODO: Add SQL server as replica to Availability Group
end

def add_db
  time = Time.now.getutc
  sqlps_module_path = ::File.join(ENV['programfiles(x86)'], 'Microsoft SQL Server\110\Tools\PowerShell\Modules\SQLPS')
  
  template 'c:\\chef\\cache\\join_db_replica.sql' do
    path 'c:\\chef\\cache\\join_db_replica.sql'
    source 'join_db_replica.sql.erb'
    cookbook 'ls_sql_server'
    variables(
        avail_group_name: new_resource.ag_name,
        db_name: new_resource.db_name
    )
  end
  
  template 'c:\\chef\\cache\\alter_dag_add_db.sql' do
    path 'c:\\chef\\cache\\alter_dag_add_db.sql'
    source 'alter_dag_add_db.sql.erb'
    cookbook 'ls_sql_server'
    variables(
        avail_group: new_resource.ag_name,
        db_name: new_resource.db_name
    )
  end
  
  ls_sql_server_database 'Backup #{new_resource.db_name}' do
    action :backup
    name new_resource.db_name
    backup_location new_resource.backup_share
    backup_name "#{new_resource.db_name}AgDbAdd.bak"
    server_instance new_resource.primary_server
  end
  
  time_string = time.strftime("%Y%m%d%H%M%S")
  
  log_backup_name = "#{new_resource.db_name}AgDbAdd_#{time_string}.trn"
  
  ls_sql_server_database 'Backup #{new_resource.db_name} log' do
    action :backup_log
    name new_resource.db_name
    backup_location new_resource.backup_share
    backup_name log_backup_name
    server_instance new_resource.primary_server
  end
  
  powershell_script 'Alter DAG add db #{new_resource.db_name}' do
    code <<-EOH
      Import-Module "#{sqlps_module_path}"
      Invoke-Sqlcmd -InputFile "c:\\chef\\cache\\alter_dag_add_db.sql" -ServerInstance "#{new_resource.primary_server}"
    EOH
  end
  
  ls_sql_server_database 'Restore database #{new_resource.db_name} to server #{new_resource.replica_server}' do
    action :restore_backup
    name new_resource.db_name
    backup_location new_resource.backup_share
    backup_name "#{new_resource.db_name}AgDbAdd.bak"
    server_instance new_resource.replica_server
  end
  
  ls_sql_server_database 'Restore database #{new_resource.db_name} log to server #{new_resource.replica_server}' do
    action :restore_log
    name new_resource.db_name
    backup_location new_resource.backup_share
    backup_name log_backup_name
    server_instance new_resource.replica_server
  end
  
  powershell_script 'Join Database #{new_resource.db_name} to #{new_resource.name} availability group' do
    code <<-EOH
      Import-Module "#{sqlps_module_path}"
      Invoke-Sqlcmd -InputFile "c:\\chef\\cache\\join_db_replica.sql" -ServerInstance "#{new_resource.replica_server}"
    EOH
  end
end
