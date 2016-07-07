require 'logger'

class DeploymentLogger < Logger

  def initialize(*args, deployment)
    super(*args)
    if !deployment.nil?
        @password_set = extract_deployment_passwords(deployment)
    end
  end

  def add(severity, message = nil, progname = nil)
    if !@password_set.nil?
      if !message.nil?
        message = replace_secret_strings(message, @password_set)
      end
      if !progname.nil?
        progname = replace_secret_strings(progname, @password_set)
      end
    end
    super(severity, message, progname)
  end

  def replace_secret_strings(text_to_sanitize, secret_strings, secret_replacement = "[FILTERED]")
    secret_strings.each do |secret_string|
      text_to_sanitize.gsub!(secret_string, secret_replacement)
    end
    return text_to_sanitize
  end

  def extract_deployment_passwords(deployment)
    extracted_passwords = Set.new
    password_identifiers = [
      "rhev_engine_admin_password",
      "rhev_root_password",
      "rhev_gluster_root_password",
      "cfme_root_password",
      "cfme_admin_password",
      "cfme_db_password",
      "openshift_user_password",
      "openshift_root_password",
      "openstack_deployment.undercloud_admin_password",
      "openstack_deployment.undercloud_ssh_password",
      "openstack_deployment.overcloud_password"
      ]
    password_identifiers.each do |password_identifier|
      if deployment.respond_to?(password_identifier)
        extracted_passwords.add(deployment.send(password_identifier))
      end
    end
    return extracted_passwords
  end
end
