module SSHKit
  class CommandMap
    class CommandHash
      def initialize(defaults = {})
        @storage = {}
        @defaults = defaults
      end

      def [](key)
        @storage[normalize_key(key)] ||= @defaults[key]
      end

      def []=(key, value)
        @storage[normalize_key(key)] = value
      end

      private

      def normalize_key(key)
        key.to_sym
      end
    end

    class PrefixProvider
      BUILTIN_COMMANDS = Set.new %w{if test time}

      def initialize(value = nil)
        @storage = CommandHash.new(value || defaults)
      end

      def [](command)
        @storage[command]
      end

      def defaults
        Hash.new do |hash, command|
          hash[command] = case command.to_s
            when ->(cmd) { BUILTIN_COMMANDS.include?(cmd) } then %w{}
            else %w{/usr/bin/env}
          end
        end
      end
    end

    TO_VALUE = ->(obj) { obj.respond_to?(:call) ? obj.call : obj }

    def initialize(value = nil)
      @map = CommandHash.new(value || defaults)
    end

    def [](command)
      prefixes = prefix[command].map(&TO_VALUE)
      cmd = TO_VALUE.(@map[command])

      [*prefixes, cmd].compact.join(' ')
    end

    def prefix
      @prefix ||= PrefixProvider.new
    end

    def []=(command, new_command)
      @map[command] = new_command
    end

    def clear
      @map = CommandHash.new(defaults)
    end

    def defaults
      Hash.new do |hash, command|
        hash[command] = command.to_s
      end
    end
  end
end
