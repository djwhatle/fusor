require 'fusor/multilog'
require 'fusor/deployment_logger'

class DeploymentMultiLogger < MultiLogger
	# Creates and write to additional log file(s).
	# Aware of deployment, hides passwords in log files.
  def attach(name, deployment)
    @logdev ||= {}
    if !name.nil? and !@logdev.key? name
      logger = DeploymentLogger.new(deployment, name)
      logger.secret
      logger.level = log_level
      @logdev[name] = logger
    end
  end
end
