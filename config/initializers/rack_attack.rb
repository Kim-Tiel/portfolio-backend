class Rack::Attack
  # Throttle POSTs to the web and API login endpoints by IP address.
  throttle("logins/ip", limit: 5, period: 20.seconds) do |req|
    req.ip if req.post? && ["/login", "/api/v1/login"].include?(req.path)
  end

  # Throttle POSTs to the login endpoints by email param, to slow down
  # credential-stuffing attempts that rotate IPs but reuse an email.
  throttle("logins/email", limit: 5, period: 20.seconds) do |req|
    req.params["email"].to_s.downcase.presence if req.post? && ["/login", "/api/v1/login"].include?(req.path)
  end

  def self.forgot_password_post?(req)
    req.post? && req.path == "/forgot_password"
  end

  throttle("forgot_password/ip", limit: 5, period: 15.minutes) do |req|
    req.ip if forgot_password_post?(req)
  end

  throttle("forgot_password/email", limit: 3, period: 15.minutes) do |req|
    req.params["email"].to_s.downcase.presence if forgot_password_post?(req)
  end

  MEMORY_LOG_PATH = "/api/v1/memory_log_entries".freeze

  def self.memory_log_post?(req)
    req.post? && req.path == MEMORY_LOG_PATH
  end

  throttle("memory_log/ip/burst", limit: 3, period: 10.minutes) do |req|
    req.ip if memory_log_post?(req)
  end

  throttle("memory_log/ip/day", limit: 10, period: 1.day) do |req|
    req.ip if memory_log_post?(req)
  end

  throttle("memory_log/global", limit: 60, period: 1.hour) do |req|
    "memory_log_global" if memory_log_post?(req)
  end

  CONTACT_MESSAGE_PATH = "/api/v1/contact_messages".freeze

  def self.contact_message_post?(req)
    req.post? && req.path == CONTACT_MESSAGE_PATH
  end

  throttle("contact_message/ip/burst", limit: 3, period: 10.minutes) do |req|
    req.ip if contact_message_post?(req)
  end

  throttle("contact_message/ip/day", limit: 10, period: 1.day) do |req|
    req.ip if contact_message_post?(req)
  end

  throttle("contact_message/global", limit: 60, period: 1.hour) do |req|
    "contact_message_global" if contact_message_post?(req)
  end

  self.throttled_responder = lambda do |_request|
    [429, { "Content-Type" => "application/json" }, [{ error: "Too many requests, please try again later." }.to_json]]
  end
end
