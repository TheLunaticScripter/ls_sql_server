actions :create, :add_replica, :add_db
default_action :create

attribute :ag_name, kind_of: String, required: true
attribute :backup_share, kind_of: String, default: 'C:\\Backup'
attribute :db_name, kind_of: String
attribute :availability_mode, kind_of: String, default: 'Synchronous commit'
attribute :failover_mode, kind_of: String, default: 'Automatic'
attribute :primary_server, kind_of: String
attribute :replica_server, kind_of: String
attribute :fqdn, kind_of: String
