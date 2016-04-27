actions :create, :backup, :remove, :delete_backup
default_action :create

attribute :name, name_attribute: true, kind_of: String, required: true
attribute :recovery_model, kind_of: String, default: 'FULL'
attribute :backup_type, kind_of: String
attribute :backup_name, kind_of: String
attribute :backup_location, kind_of: String
