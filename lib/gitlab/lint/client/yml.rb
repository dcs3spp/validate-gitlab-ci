require "yaml"
require "json"

module Gitlab
  module Lint
    module Client

      class YamlFile
        attr_reader :file

        def initialize(file)
          @file = file
          validate!
        end

        def validate!
          raise NameError unless @file
          raise ArgumentError unless @file.chars.last(4).join == ".yml" or @file.chars.last(5).join == ".yaml"
          raise IOError unless ::File.exist?(@file)
          raise RuntimeError unless ::File.readable?(@file)
        end

        def get_content
          begin
            return YAML.load_file(@file)
          rescue Psych::SyntaxError => error
            puts "Failed to parse the YAML File: #{error.message}"
          end
        end

        def get_json_content
          content = JSON.generate(get_content())
          return json_ok?(content) ? content : nil
        end

        private

        def json_ok? json
          begin
            JSON.parse(json)
            return true
          rescue
            return false
          end
        end

      end
    end
  end
end