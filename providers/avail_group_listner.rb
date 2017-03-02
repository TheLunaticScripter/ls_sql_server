# Provider for avail_group_listener LWRP

use_inline_resources

def load_current_resource
  @current_resource = Chef::Resource::LsSqlServerAvailGroupListner.new(@new_resource)
  @current_resource.listner_name(@new_resource.listner_name)
  @current_resource.dag_name(@new_resource.dag_name)
  @current_resource.ip_address(@new_resource.ip_address)
  @current_resource.subnet(@new_resource.subnet)
  @current_resource.port(@new_resource.port)
end

action :create do
  converge_by("Create availability group listner #{@new_resource.listner_name}") do
    create_avail_group_listner
  end
end

action :add_ip do
  converge_by("Add ip address to listner #{@new_resource.listner_name}") do
    add_ip_listner
  end
end

def whyrun_supported?
  true
end

private

def create_avail_group_listner
  sqlps_module_path = ::File.join(ENV['programfiles(x86)'], 'Microsoft SQL Server\110\Tools\PowerShell\Modules\SQLPS')
  template 'c:\\chef\\cache\\create_dag_listner.sql' do
    path 'c:\\chef\\cache\\create_dag_listner.sql'
    source 'create_dag_listner.sql.erb'
    cookbook 'ls_sql_server'
    variables(
      dag_name: new_resource.dag_name,
      listner_name: new_resource.listner_name,
      ip_address: new_resource.ip_address,
      subnet: new_resource.subnet,
      port: new_resource.port
    )
  end
  powershell_script "Create DAG listner #{new_resource.listner_name}" do
    code <<-EOH
      Import-Module "#{sqlps_module_path}"
      Invoke-Sqlcmd -InputFile "c:\\chef\\cache\\create_dag_listner.sql"
    EOH
    guard_interpreter :powershell_script
    not_if <<-EOH
      Import-Module "#{sqlps_module_path}"
      (Invoke-Sqlcmd -Query "SELECT * FROM sys.availability_group_listeners WHERE dns_name = '#{new_resource.listner_name}'").dns_name -eq "#{new_resource.listner_name}"
    EOH
  end
end

def add_ip_listner
  # sqlps_module_path = ::File.join(ENV['programfiles(x86)'], 'Microsoft SQL Server\110\Tools\PowerShell\Modules\SQLPS')
  # TODO: Create method to add ip to listner
end
