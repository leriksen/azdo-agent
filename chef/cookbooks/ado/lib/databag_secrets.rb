# frozen_string_literal: true

require 'json'

class DatabagSecrets
  def initialize(secret_file)
    @data = JSON.parse File.read(secret_file)

    if !@data.key?('pat')          ||
       !@data.key?('organization') ||
       !@data.key?('pool')         ||
       !@data.key?('user')         ||
       !@data.key?('password')
      raise DatabagSecrets::BadSecrets, "#{secret_file} is missing required fields"
    end
  end

  def [](key)
    @data[key]
  end

  class BadSecrets < StandardError
    def initialize(message = 'Bad secret config json file')
      super
    end
  end
end
