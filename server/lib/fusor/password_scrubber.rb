##
# PasswordScrubber
# ================
# Extracts passwords from a deployment object.
# Provides functionality for removing sensitive data (passwords) from text.

class PasswordScrubber
  def self.extract_deployment_passwords(deployment)
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

  def self.replace_secret_strings(text_to_sanitize, secret_strings, secret_replacement = "[FILTERED]")
    secret_strings.each do |secret_string|
      text_to_sanitize.gsub!(secret_string, secret_replacement)
    end
    return text_to_sanitize
  end
end
