# Helpers for making JSON requests
module JsonRequestHelper

  DEFAULT_HEADERS = { 'Content-Type' => 'application/json' }

  # takes care of a bit of the performs a json rquest
  def make_json_request(route:, payload:, method: :post, headers: DEFAULT_HEADERS)
    headers['Content-Type'] ||= DEFAULT_HEADERS['Content-Type']
    self.send method, route, payload.to_json, headers
    [response.status, JSON.parse(response.body)]
  end

end
