require 'ostruct'

class MyConfig < OpenStruct
    def self.for(config)
        new(YAML::load(File.read('config/config.yml'))[config])
    end

    def credentials
        [username, password]
    end
end
