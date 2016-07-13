require 'test_plugin_helper'
require 'fusor/password_filter'

class PasswordFilterTest < ActiveSupport::TestCase
  def assert_passwords_match_expections(expected_passwords, passwords, passwords_cached)
    assert passwords.size == expected_passwords.size,
      "passwords.size (#{passwords.size}) was different from expected_passwords.size (#{expected_passwords.size})"
    assert passwords_cached.size == expected_passwords.size,
      "passwords_cached.size (#{passwords.size}) was different from expected_passwords.size (#{expected_passwords.size})"

    expected_passwords.each do |expected_password|
      assert password_set.include?(expected_password), "#{expected_password} not found in password_set: #{password_set}."
      assert passwords_cached.include?(expected_password), "#{expected_password} not found in passwords_cached: #{passwords_cached}"
    end
  end

  test "In production env, PasswordFilter should extract all RHEV passwords and cache them." do
    # Extracting: rhev_engine_admin_password, rhev_root_password
    Rails.env = "production"

    # Testing a RHEV deployment with a single, shared password.
    deployment_rhev = fusor_deployments(:rhev)
    password_set = PasswordFilter.extract_deployment_passwords(deployment_rhev)

    assert password_set.size == 1
    assert password_set.include?("redhat1234")

    assert PasswordFilter.password_cache.size == 1
    assert PasswordFilter.password_cache.include?("redhat1234")

    # Testing a RHEV deployment with two different passwords.
    deployment_rhev = fusor_deployments(:rhev_different_passwords)
    password_set = PasswordFilter.extract_deployment_passwords(deployment_rhev)

    assert password_set.size == 2
    assert password_set.include?("redhat1234")
    assert password_set.include?("redhat4321")

    assert PasswordFilter.password_cache.size == 2
    assert PasswordFilter.password_cache.include?("redhat1234")
    assert PasswordFilter.password_cache.include?("redhat4321")
  end

  test "In production env, PasswordFilter should extract all RHEV+CFME passwords and cache them." do
    # Extracting: rhev_engine_admin_password, rhev_root_password
    #             cfme_root_password, cfme_admin_password, cfme_db_password
    Rails.env = "production"

    deployment_rhev_cfme = fusor_deployments(:rhev_and_cfme_different_passwords)
    password_set = PasswordFilter.extract_deployment_passwords(deployment_rhev_cfme)

    expected_passwords = [
      "redhat1234",
      "redhat4321"
    ]
    assert password_set.size == 2
    assert password_set.include?("redhat1234")
    assert password_set.include?("redhat4321")

    assert PasswordFilter.password_cache.size == 2
    assert PasswordFilter.password_cache.include?("redhat1234")
    assert PasswordFilter.password_cache.include?("redhat4321")
  end

  test "In production env, PasswordFilter should extract all RHEV+CFME+OSP passwords and cache them." do
    # Extracting: rhev_engine_admin_password, rhev_root_password
    #             cfme_root_password, cfme_admin_password, cfme_db_password
    #             undercloud_admin_password, undercloud_ssh_password, overcloud_password
    Rails.env = "production"

    # grab two stub deployments
    deployment_rhev_cfme_osp = fusor_deployments(:rhev_and_cfme_different_passwords)
    deployment_osp = fusor_openstack_deployments(:osp)

    # set the base deployment object to have child OSP deployment object
    deployment_rhev_cfme_osp.openstack_deployment = deployment_osp

    # set the list of expected passwords based on the deployment stubs being used
    expected_passwords = [
      "undercloudAdminPassword",
      "undercloudSshPassword1234",
      "overcloudAdminPassword",
      "redhat1234",
      "redhat4321"
    ]

    # run the extraction command
    password_set = PasswordFilter.extract_deployment_passwords(deployment_rhev_cfme_osp)

    # ensure that extraction results are as expected
    assert_passwords_match_expections(expected_passwords, password_set, PasswordFilter.password_cache)
  end

  # test "In production env, PasswordFilter should cache passwords and be able to use them for filtering." do
  # end
  #
  # test "In production env, PasswordFilter.filter_passwords should accept a custom password Set." do
  # end
  #
  # test "In devel env, PasswordFilter should not filter any passwords for debugging purposes." do
  # end


  after do
    Rails.env = "test"
  end
end
