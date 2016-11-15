require 'yaml'

class Config
  def initialize
    @config = YAML.load_file('config.yml')
  end

  def method_missing(method_name, *args, &block)
    @config[method_name]
  end

  def access_token
    ENV['ACCESS_TOKEN'].tap do |access_token|
      raise 'missing ACCESS_TOKEN env' unless access_token
    end
  end

end
