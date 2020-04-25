# frozen_string_literal: true

# Base result
class Result
  attr_reader :status, :data, :code

  def initialize(status, data, code)
    @status = status
    @data = data
    @code = code
  end

  def success?
    @status == true
  end

  def error?
    !success?
  end
end
