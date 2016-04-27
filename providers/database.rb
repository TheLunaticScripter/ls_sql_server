def load_current_resource
  @current_resource = Chef::Resource::LsSqlServerDatabase.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.recovery_model(@new_resource.recovery_model)
  @current_resource.backup_type(@new_resource.backup_type)
  @current_resource.backup_name(@new_resource.backup_name)
  @current_resource.backup_location(@new_resource.backup_location)  
end

action :create do
  converge_by("Create database #{@new_resource.name}") do
    create_database
  end
end

action :backup do
  converge_by("Backup database #{@new_resource.name}") do
    backup_database
  end
end

action :remove do
  converge_by("Remove database #{@new_resource.name}") do
    remove_database
  end
end

action :delete_backup do
  converge_by("Delete backup #{@new_resource.backup_name}") do
    delete_backup
  end
end

def whyrun_supported?
  true
end

private

def create_database
  # create_db_path = win_friendly_path(File.join(Chef::Config[:file_cache_path], 'create_db.sql'))
  sqlps_module_path = ::File.join(ENV['programfiles(x86)'], 'Microsoft SQL Server\110\Tools\PowerShell\Modules\SQLPS')
  template 'c:\\chef\\cache\\create_db.sql' do
    path 'c:\\chef\\cache\\create_db.sql'
    source 'create_db.sql.erb'
    cookbook 'ls_sql_server'
    variables(
        db_name: new_resource.name,
        recovery_model: new_resource.recovery_model
    )
  end
  powershell_script 'Create Database #{new_resource.name}' do
    code <<-EOH
      Import-Module "#{sqlps_module_path}"
      Invoke-Sqlcmd -InputFile "c:\\chef\\cache\\create_db.sql"
    EOH
    guard_interpreter :powershell_script
    only_if <<-EOH
      Import-Module "#{sqlps_module_path}"
      (Invoke-Sqlcmd -Query "SELECT COUNT(*) AS Count FROM sys.databases WHERE name = '#{new_resource.name}'").Count -eq 0
    EOH
  end
end

def backup_database
  # TODO: Create method to backup database in SQL
end

def remove_database
  # TODO: Create method to remove database in SQL
end

def delete_backup
  # TODO: Create method to delete backup
end
