# ls_sql_server

The Lunatic Scripter Sql Cookbook
=======================================================

Requirements
------------
#### Platforms
* Windows Server 2012 (R1, R2)

#### Chef
- Chef 12+

#### Cookbooks Dependencies
* windows - (Utilize windows_package to install SQL from alternate source location)
* ls_windows_cluster - (Used to help install clustering for DAGs)
* ls_windows_ad - (Used to create a service account for the SQL Service)

Usage
-----

### Purpose
This is a cookbook that installs SQL Server 2012 Enterprise.

Recipes
-------

### default.rb
Installs SQL and creates a cluster if the cluster attribute is set to cluster

### cluster.rb
Creates a Failover-Cluster and sets SQL Always-On feature

### install.rb
Installs SQL and sets max memory to 80% of total node memory

Resources
---------

### ls_sql_server_avail_group
Creates a SQL Database Availability Group (DAG)

#### Actions

#### Attributes
- 'ag_name' - Availability Group Name
- 'backup_share' - Folder share where the database backup goes
- 'db_name' - Name of the first database to be added to the DAG
- 'availability_mode' - Sets the DAG availability mode - valid options are "Asynchronous commit" and "Synchronous commit"
- 'failover_mode' - Set the DAG failover mode - Synchronous commit availability mode supports Autuomatic and Manuel while Asynchronous commit only supports Manuel
- 'primary_server' - Name of the SQL server being replicated from
- 'replica_server' - Name of the SQL server being replicated to
- 'fqdn' - Name of the domain the SQL servers are on.

#### Examples

# TODO Finish README

