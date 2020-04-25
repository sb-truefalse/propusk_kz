# frozen_string_literal: true

# Check GRNZ
class Telegram::Bot::Propusks::GrnzService < Service
  def initialize(payload)
    @payload = payload
  end

  def call(params)
    json_service(params.first).check_grnz
  end

  private

  def json_service(grnz)
    Telegram::Bot::Propusks::JsonService.new(grnz: grnz)
  end
end
