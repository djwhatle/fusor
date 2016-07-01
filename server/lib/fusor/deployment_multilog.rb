require 'multilog'
require 'deployment_logger'

class DeploymentMultiLogger < MultiLogger

	# Creates and write to additional log file(s).
	# Aware of deployment, hides passwords in log files.
  def attach(name, deployment, secret_replacement)
    @logdev ||= {}
    if !name.nil? and !@logdev.key? name
      logger = DeploymentLogger.new(name, deployment, secret_replacement)
      logger.level = log_level
      @logdev[name] = logger
    end
    if !deployment.nil?
    	@password_set = extract_deployment_passwords(deployment)
    end
  end
end