actions :create, :add_replica
default_action :create

attribute :name, name_attribute: true, kind_of: String, required: true
attribute :backup_share, kind_of: String, default: 'C:\\Backup'
attribute :db_name, kind_of: String
attribute :availability_mode, kind_of: String
attribute :failover_mode, kind_of: String
