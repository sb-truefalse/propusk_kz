# frozen_string_literal: true

# Base
class Service
  protected

  def success!(data = nil, code: nil)
    result(true, data, code)
  end

  def error!(data = nil, code: nil)
    result(false, data, code)
  end

  def result(status, data, code)
    Result.new(status, data, code)
  end
end
