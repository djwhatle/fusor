#
# Copyright 2015 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
require 'open3'
require 'yaml'
require 'set'
require 'pry'

module Utils
  module Fusor
    class CommandUtils
      @password_set = nil

      def self.run_command(cmd, deployment, log_on_success = false)
        binding.pry
        # cmd            - command to run
        # deployment     - deployment object associated with cmd.
        #                  passwords are pulled from deployment obj
        #                  pass nil if no password scrubbing needed             
        # log_on_success - display cmd and output on success

        # popen2e merges stdout and stderr, which we have put into
        # the the output variable
        stdin, stdout_err, wait_thr = Open3.popen2e(cmd)
        status = wait_thr.value.exitstatus

        # capture the output into a variable because once we close
        # it you can no longer read it.
        #
        # also need to capture it so that we can log any errors
        # that may have occurred otherwise we just log the class id
        # which is useless in a debugging scenario.
        #
        output = stdout_err.readlines

        secret_strings = nil

        if deployment != nil:
          secret_strings = extract_deployment_passwords(deployment)
        end

        # sanitize secret_strings existing in cmd and output
        if status > 0
          if secret_strings != nil
            cmd = self.replace_secret_strings(cmd, secret_strings)
            output = self.replace_secret_strings(output, secret_strings)
          end
          Rails.logger.error "Error running command: #{cmd}"
          Rails.logger.error "Status code: #{status}"
          Rails.logger.error "Command output: #{output}"
        elsif log_on_success
          if secret_strings != nil
            cmd = self.replace_secret_strings(cmd, secret_strings)
            output = self.replace_secret_strings(output, secret_strings)
          end
          Rails.logger.info "Command: #{cmd}"
          Rails.logger.info "Status code: #{status}"
          Rails.logger.info "Command output: #{output}"
        end

        # need to close these explicitly as per the docs
        stdin.close unless stdin.closed?
        stdout_err.close unless stdout_err.closed?

        return status, output
      end

      def self.replace_secret_strings(text_to_sanitize, secret_strings, secret_replacement)
        # replace all secret strings inside of text_to_sanitize
        # with secret_replacement.
        secret_strings.each do |secret_string|
          text_to_sanitize.sub!(secret_string, secret_replacement)
        end

        return text_to_sanitize
      end

      def self.extract_deployment_passwords(deployment)
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

        binding.pry
        return password_set
      end

      # def self.get_password_set
      #   # loop over all deployments and gather passwords in one set
      #   password_set = Set.new

      #   ::Fusor::Deployment.find_each do |deployment|
      #     @password_set.add(deployment.rhev_engine_admin_password)
      #     @password_set.add(deployment.rhev_root_password)
      #     @password_set.add(deployment.cfme_root_password)
      #     @password_set.add(deployment.cfme_admin_password)
      #     @password_set.add(deployment.openshift_user_password)
      #     @password_set.add(deployment.openshift_root_password)
      #     @password_set.add(deployment.cfme_db_password)
      #     @password_set.add(deployment.rhev_root_password)
      #     @password_set.add(deployment.rhev_gluster_root_password)
      #     @password_set.add(deployment.openstack_deployment.undercloud_admin_password)
      #     @password_set.add(deployment.openstack_deployment.undercloud_ssh_password)
      #     @password_set.add(deployment.openstack_deployment.overcloud_password)
      #   end
        
      #   return  password_set
      # end
    end
  end
end
