actions :create, :backup, :remove, :delete_backup, :restore_backup, :backup_log, :restore_log
default_action :create

attribute :name, name_attribute: true, kind_of: String, required: true
attribute :recovery_model, kind_of: String, default: 'FULL'
attribute :server_instance, kind_of: String, required: true, default: '$env:COMPUTERNAME'
attribute :backup_action, kind_of: String
attribute :backup_name, kind_of: String
attribute :backup_location, kind_of: String
attribute :restore_action, kind_of: String

