##
# PasswordFilter
# ================
# Extracts passwords from deployment objects.
# Provides functionality for filtering sensitive data (passwords) from text.

class PasswordFilter
  def self.password_cache
    return @password_cache
  end

  def self.extract_deployment_passwords(deployment)
    # only filter passwords in the production environment
    if !Rails.env.production?
      return nil
    end
    extracted_passwords = Set.new

    main_deployment_passwords = [
      "rhev_engine_admin_password",
      "rhev_root_password",
      "rhev_gluster_root_password",
      "cfme_root_password",
      "cfme_admin_password",
      "cfme_db_password",
      "openshift_user_password",
      "openshift_root_password",
    ]
    osp_deployment_passwords = [
      "undercloud_admin_password",
      "undercloud_ssh_password",
      "overcloud_password",
    ]

    extracted_passwords += cautious_get_attrs(main_deployment_passwords, deployment)
    binding.pry
    if deployment.respond_to? :openstack_deployment
      osp_deployment = deployment.send(:openstack_deployment)
      extracted_passwords += cautious_get_attrs(osp_deployment_passwords, osp_deployment)
      binding.pry
    end
    # main_deployment_passwords.each do |password_identifier|
    #   if deployment.respond_to?(password_identifier)
    #     password = deployment.send(password_identifier)
    #     if !password.nil?
    #       extracted_passwords.add(password)
    #     end
    #   end
    # end
    # keep track of the last good password set in @password_cache
    if extracted_passwords.size > 0
      @password_cache = extracted_passwords.clone
    end
    return extracted_passwords
  end

  def self.cautious_get_attrs(attr_symbols, obj_to_search)
    extracted_attrs = Set.new
    attr_symbols.each do |attr_symbol|
      if obj_to_search.respond_to?(attr_symbol)
        attr_value = obj_to_search.send(attr_symbol)
        if !attr_value.nil?
          extracted_attrs.add(attr_value)
        end
      end
    end
    return extracted_attrs
  end

  def self.filter_passwords(text_to_filter, passwords = nil, replacement_text = "[SCRUBBED]")
    # only filter passwords in the production environment
    if !Rails.env.production?
      return text_to_filter
    end
    # convert arrays etc. to strings so that gsub! is possible
    if !text_to_filter.kind_of?(String)
      text_to_filter = text_to_filter.to_s
    end
    # read from the password_cache if passwords aren't passed in
    if passwords.nil? and !@password_cache.nil?
      passwords = @password_cache
    end
    # ensure that we have a set of passwords to filter out
    if !passwords.nil? and passwords.kind_of?(Set)
      passwords.each do |password|
        text_to_filter.gsub!(password, replacement_text)
      end
    end
    return text_to_filter
  end
end
