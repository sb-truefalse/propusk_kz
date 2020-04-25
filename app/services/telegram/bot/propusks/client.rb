# frozen_string_literal: true

# Client for propusks-request
class Telegram::Bot::Propusks::Client
  BASE_URL = 'https://check-rubezh.egsv.kz'

  def post(uri, **body)
    connection.post uri do |req|
      req.headers[:content_type] = 'application/json'
      req.body = JSON.generate(body)
    end
  end

  private

  def connection
    @connection ||= Faraday.new(BASE_URL) do |connection|
      connection.request :url_encoded
      connection.request :json
      connection.response :json, parser_options: { symbolize_names: true }
      connection.adapter :net_http
    end
  end
end
