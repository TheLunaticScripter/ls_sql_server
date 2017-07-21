property :name, kind_of: String, name_property: true

default_action :enable_always_on

def whyrun_supported?
  true
end

def load_current_resource
  @current_resource = Chef::Resource::LsSqlServerCluster.new(@new_resource.name)
end

action :enable_always_on do
  if exists?
    @new_resource.updated_by_last_action(false)
  else
    sqlps_module_path = ::File.join(ENV['programfiles(x86)'], 'Microsoft SQL Server\110\Tools\PowerShell\Modules\SQLPS')
    cmd = ''
    cmd << "Import-Module \'#{sqlps_module_path}\';"
    cmd << 'Enable-SQLAlwaysOn '
    cmd << ' -Path "SQLSERVER:\\SQL\\$env:COMPUTERNAME\\DEFAULT"'
    cmd << ' -Force'
    powershell_script 'Enable SQL Always On' do
      code cmd
    end
    @new_resource.updated_by_last_action(true)
  end
end

def exists?
  sqlps_module_path = ::File.join(ENV['programfiles(x86)'], 'Microsoft SQL Server\110\Tools\PowerShell\Modules\SQLPS')
  cmd = ''
  cmd << "Import-Module #{sqlps_module_path};"
  cmd << 'cd \\sql\\$env:COMPUTERNAME\\DEFAULT;'
  cmd << '(Get-Item .).IsHadrEnabled'
  check = Mixlib::ShellOut.new("powershell.exe -command \"& {#{cmd}}\"").run_command
  check.stdout.match('True')
end
