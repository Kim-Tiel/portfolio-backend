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

  self.throttled_responder = lambda do |_request|
    [429, { "Content-Type" => "application/json" }, [{ error: "Too many requests, please try again later." }.to_json]]
  end
end
