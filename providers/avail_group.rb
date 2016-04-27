def load_current_resource
  @current_resource = Chef::Resource::LsSqlServerAvailGroup.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.backup_share(@new_resource.backup_share)
  @current_resource.db_name(@new_resource.db_name)
  @current_resource.availability_mode(@new_resource.availability_mode)
  @current_resource.failover_mode(@new_resource.failover_mode)
end

action :create do
  converge_by("Create database availability group #{@new_resource.name}") do
    create_availability_group
  end
end

action :add_replica do
  converge_by("Add SQL server as replica to availability group#{@new_resource.name}") do
    add_replica
  end 
end

def whyrun_supported?
  true
end

private

def create_availability_group
  # TODO: Create availability group method
end

def add_replica
  # TODO: Add SQL server as replica to Availability Group
end