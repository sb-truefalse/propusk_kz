# frozen_string_literal: true

# Check IIN
class Telegram::Bot::Propusks::IinService < Service
  def initialize(payload)
    @payload = payload
  end

  def call(params)
    json_service(params.first).check_iin
  end

  private

  def json_service(iin)
    Telegram::Bot::Propusks::JsonService.new(iin: iin)
  end
end
