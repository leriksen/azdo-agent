require 'json'

class DatabagSecrets
  def initialize(secret_file)
    @data = JSON.parse File.read(secret_file)

    if !@data.key?('pat')          ||
       !@data.key?('organization') ||
       !@data.key?('pool')         ||
       !@data.key?('agentName')
      raise DatabagSecrets::BadSecrets, "#{secret_file} is missing required fields"
    end
  end

  def pat
    @data['pat']
  end

  def organization
    @data['organization']
  end

  def pool
    @data['pool']
  end

  def agentName
    @data['agentName']
  end

  class BadSecrets < StandardError
    def initialize(message = "Bad secret config json file")
      super
    end
  end
end