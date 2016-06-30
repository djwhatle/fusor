require 'yaml'
require 'pry'
require 'set'

yaml_settings = YAML.load_file('fusor.yaml')
log_passwords = yaml_settings[:fusor][:system][:logging][:log_passwords]

passwords_to_scrub = new Set
passwords +=

# ::Fusor::Deployment.last.rhev_engine_admin_password
# ::Fusor::Deployment.last.rhev_root_password
# ::Fusor::Deployment.last.cfme_root_password
# ::Fusor::Deployment.last.cfme_admin_password
# ::Fusor::Deployment.last.openshift_user_password
# ::Fusor::Deployment.last.openshift_root_password
# ::Fusor::Deployment.last.cfme_db_password
# ::Fusor::Deployment.last.rhev_root_password

# ::Fusor::Deployment.last.openstack_deployment.undercloud_admin_password
# ::Fusor::Deployment.last.openstack_deployment.undercloud_ssh_password
# ::Fusor::Deployment.last.openstack_deployment.overcloud_password

# rhev_gluster_root_password


# move the above over whenever the deploy button gets hit.

# puts yaml_settings.inspect
# pry

# class YamlReader
#   @sanitize = true

#   def self.print_yaml

#   end

