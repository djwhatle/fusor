require 'logger'
require 'fusor/password_scrubber'

##
# DeploymentLogger
# ================
# Child of Ruby base logging class. Scrubs passwords from logs using context
# provided by a Deployment object.
#
class DeploymentLogger < Logger
  attr_reader :password_set

  def initialize(*args, deployment)
    super(*args)
    @log_passwords = SETTINGS[:fusor][:system][:logging][:log_passwords]
    if !deployment.nil?
        @password_set = PasswordScrubber.extract_deployment_passwords(deployment)
    end
  end

  def add(severity, message = nil, progname = nil)
    if @log_passwords == false and !@password_set.nil?
      if !message.nil?
        message = PasswordScrubber.replace_secret_strings(message.clone, @password_set)
      end
      if !progname.nil?
        progname = PasswordScrubber.replace_secret_strings(progname.clone, @password_set)
      end
    end
    super(severity, message, progname)
  end
end
