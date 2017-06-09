actions :create, :add_ip
default_action :create

attribute :listner_name, kind_of: String, required: true
attribute :dag_name, kind_of: String, required: true
attribute :ip_address, kind_of: String, required: true
attribute :subnet, kind_of: String, required: true
attribute :port, kind_of: Integer, default: 1433
