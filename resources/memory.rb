property :name, kind_of: String, name_property: true
property :memory_percentage, kind_of: Float, default: 0.8

default_action :set

def whyrun_supported?
  true
end

def load_current_resource
  @current_resource = Chef::Resource::J6xSqlMemory.new(@new_resource.name)
end

action :set do
  sqlps_module_path = ::File.join(ENV['programFiles(x86)'], 'Microsoft SQL Server\110\Tools\PowerShell\Modules\SQLPS')
  if exists?
    @new_resource.updated_by_last_action(false)
  else
    cmd = ''
    cmd << "Import-Module \'#{sqlps_module_path}\';"
    cmd << 'cd \\sql\\$env:COMPUTERNAME;'
    cmd << '$server = Get-Item default;'
    cmd << "$server.Configuration.MaxServerMemory.ConfigValue = #{get_sql_memory_mb};"
    cmd << '$server.Configuration.Alter();'
    powershell_script "Set SQL Max Memory to #{get_sql_memory_mb}" do
      code cmd
    end
    @new_resource.updated_by_last_action(true)
  end
end

def sql_memory_mb
  sql_memory = node['kernel']['cs_info']['total_physical_memory'].to_f * memory_percentage
  sql_memory_kb = sql_memory / 1_000_000
  sql_memory_kb.floor
end

def exists?
  sqlps_module_path = ::File.join(ENV['programFiles(x86)'], 'Microsoft SQL Server\110\Tools\PowerShell\Modules\SQLPS')
  cmd = ''
  cmd << "Import-Module \'#{sqlps_module_path}\';"
  cmd << 'cd \\sql\\$env:COMPUTERNAME;'
  cmd << '$server = Get-Item default;'
  cmd << "$server.Configuration.MaxServerMemory.ConfigValue -eq #{get_sql_memory_mb}"
  check = Mixlib::ShellOut.new("powershell.exe -command \"& {#{cmd}}\"").run_command
  check.stdout.match('True')
end
