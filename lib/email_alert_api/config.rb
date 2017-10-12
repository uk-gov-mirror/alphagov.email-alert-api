require "yaml"
require "erb"

module EmailAlertAPI
  class Config
    def initialize(environment)
      @environment = environment || "development"
    end

    def app_root
      Rails.root
    end

    def gov_delivery
      @gov_delivery ||= environment_config.symbolize_keys.freeze
    end

    def redis_config
      YAML.load(ERB.new(File.read(redis_config_path)).result).symbolize_keys
    end

  private

    def redis_config_path
      File.join(app_root, "config", "redis.yml")
    end

    def gov_delivery_config_path
      File.join(app_root, "config", "gov_delivery.yml")
    end

    def environment_config
      all_configs = YAML.load(File.open(gov_delivery_config_path))

      all_configs.fetch(@environment).tap do |env_config|
        env_config.merge!(environment_credentials)
      end
    end

    def environment_credentials
      return {} unless ENV["GOVDELIVERY_USERNAME"]

      {
        username: ENV.fetch("GOVDELIVERY_USERNAME"),
        password: ENV.fetch("GOVDELIVERY_PASSWORD"),
      }.stringify_keys
    end
  end
end
