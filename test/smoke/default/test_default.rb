# SQL Installed

control 'j6x_sql_installation' do
  impact 1.0
  title 'Ensure SQL is installed on the Server'
  desc 'This is the first control to test that SQL is installed.'
  describe package('Microsoft SQL Server 2012 (64-bit)') do
    it { should be_installed }
  end
end

# Services are Running

control 'j6x_sql_services' do
  impact 1.0
  title 'Ensure SQL Server Service and SQL Agent Service are started.'
  desc 'This control validated the SQL Service are set to Automatic and running.'
  describe service('MSSQLSERVER') do
    it { should be_installed }
    it { should be_running }
  end
  describe service('SQLSERVERAGENT') do
    it { should be_installed }
    it { should be_running }
  end
end

# SQL Ports responding

control 'j6x_sql_port' do
  impact 1.0
  title 'Ensure SQL ports are open for traffic.'
  desc 'This control validates that the default SQL port is listening'
  describe port(1433) do
    it { should be_listening }
  end
end
