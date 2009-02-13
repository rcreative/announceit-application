# Modified from request_routing plugin, Copyright (c) 2004 Dan Webb
#
ActionController::Routing::Route.module_eval do
  TESTABLE_REQUEST_METHODS = [:subdomain, :domain, :host, :method, :request_uri]
  
  def recognition_conditions
    result = ["(match = #{Regexp.new(recognition_pattern).inspect}.match(path))"]
    conditions.each do |method, value|
      if TESTABLE_REQUEST_METHODS.include?(method)
        case value
        when Regexp
          result << "conditions[#{method.inspect}] =~ env[#{method.inspect}]"
        when Array
          result << "conditions[#{method.inspect}].include?(env[#{method.inspect}])"
        else
          result << "conditions[#{method.inspect}] === env[#{method.inspect}]"
        end
      end
    end
    result
  end
end

ActionController::Routing::RouteSet.module_eval do
  def extract_request_environment(request)
    {
      :method => request.method,
      :subdomain => request.subdomains.first.to_s,
      :domain => request.domain,
      :host => request.host,
      :request_uri => request.request_uri,
    }
  end
end