property :name, kind_of: String, name_property: true
property :netfx3_source, kind_of: String, required: true
property :sys_admin_group, kind_of: String, required: true
property :sql_svc_account, kind_of: String, required: true
property :sql_svc_acct_pswd, kind_of: String, required: true
property :install_source, kind_of: String, required: true
property :package_name, kind_of: String, default: 'Microsoft SQL Server 2014 (64-bit)'
property :instance_name, kind_of: String
property :install_dir, kind_of: String, default: 'C:\\Program Files\\Microsoft SQL Server'

default_action :install

def whyrun_supported?
  true
end

def load_current_resource
  @current_resource = Chef::Resource::LsSqlServerInstall.new(@new_resource.name)
end

action :install do
  # Install .Net 3.5 Framework
  dsc_script 'NET-Framework-Features' do
    code <<-EOH
      WindowsFeature NET-Framework-Features
      {
          Name = "NET-Framework-Features"
          Ensure = "Present"
          Source = "#{netfx3_source}"
      }
    EOH
  end

  if instance_name.nil?
    instance_name = 'MSSQLSERVER'
  else
    "MSSQL$#{instance_name}"
  end

  if instance_name.nil?
    'SQLSERVERAGENT'
  else
    'SQLAgent$#{instance_name}'
  end

  config_file_path = ::File.join(Chef::Config[:file_cache_path], 'ConfigurationFile.ini')
  # config_file_path = ConfigurationFile.ini

  sql_sys_admin_list = # if sys_admin_list.count? == 1
    %("#{sys_admin_group}")
  # else
  #  sys_admin_list.map { |account| %("#{account}")}.join(' ')
  # end

  template config_file_path do
    source 'ConfigurationFile.ini.erb'
    cookbook 'ls_sql_server'
    variables(
      sqlSysAdminList: sql_sys_admin_list,
      sql_account: sql_svc_account,
      instance_name: instance_name,
      instance_dir: install_dir
    )
  end

  password_options = {
    AGTSVCPASSWORD: sql_svc_acct_pswd,
    SQLSVCPASSWORD: sql_svc_acct_pswd,
  }.map do |option, attribute|
    next unless attribute
    safe_password = attribute.gsub(/["\\]/, '\\\\\0')
    enclosing_escape = safe_password.count('"').odd? ? '^' : ''
    "/#{option}=\"#{safe_password}#{enclosing_escape}\""
  end.compact.join ' '

  windows_package new_resource.package_name do
    source install_source
    timeout 1500
    installer_type :custom
    options "/q /ConfigurationFile=#{config_file_path} #{password_options}"
    action :install
    returns [0, 42, 127, 3010]
  end
end
