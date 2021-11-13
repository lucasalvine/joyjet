class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token

  def log_info(message, body)
    Rails.logger.info("[data][log]#{message}, #{body}")
  end

  def log_error
    Rails.logger.error("[data][log]#{message}, #{body}")
  end
end
