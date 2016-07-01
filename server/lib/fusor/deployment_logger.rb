require 'logger'

class DeploymentLogger < Logger

  def initialize(logdev, deployment, shift_age = 0, shift_size = 1048576, level: DEBUG,
                 progname: nil, formatter: nil, datetime_format: nil,
                 shift_period_suffix: '%Y%m%d')
    if !deployment.nil?
        @password_set = extract_deployment_passwords(deployment)
    end
    super(logdev, shift_age, shift_size, level,
                 progname, formatter, datetime_format,
                 shift_period_suffix)
  end

  def add(severity, message = nil, progname = nil)
    if !password_set.nil? and !message.nil?
      message = replace_secret_strings(message, @password_set)
    end
    super(severity, message, progname)
  end

  def replace_secret_strings(text_to_sanitize, secret_strings, secret_replacement = "hidden")
    secret_strings.each do |secret_string|
      text_to_sanitize.sub!(secret_string, secret_replacement)
    end

    return text_to_sanitize
  end

  def extract_deployment_passwords(deployment)
    password_set = Set.new
    password_set.add(deployment.rhev_engine_admin_password)
    password_set.add(deployment.rhev_root_password)
    password_set.add(deployment.cfme_root_password)
    password_set.add(deployment.cfme_admin_password)
    password_set.add(deployment.openshift_user_password)
    password_set.add(deployment.openshift_root_password)
    password_set.add(deployment.cfme_db_password)
    password_set.add(deployment.rhev_root_password)
    password_set.add(deployment.rhev_gluster_root_password)
    password_set.add(deployment.openstack_deployment.undercloud_admin_password)
    password_set.add(deployment.openstack_deployment.undercloud_ssh_password)
    password_set.add(deployment.openstack_deployment.overcloud_password)

    return password_set
  end
  
end