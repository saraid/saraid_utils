module DemonstratingSaraidUtils
  module Logger
    class Formatter
      KNOWN_PARAMETERS = %i(severity datetime progname message)

      def initialize(**hash)
        @data = {}
        hash.each { |k, v| self[k] = v }
      end

      def [](key)
        @data[key]
      end

      def []=(key, value)
        key = key.to_sym
        value = value.to_proc
        extract_needed_parameters(key, value)

        @data[key] = value
      end

      def extract_needed_parameters(key, value)
        value.parameters.each do |(type, name)|
          if KNOWN_PARAMETERS.include?(name) && %i(req opt).include?(type)
            ((@needed_parameters ||= {})[key] ||= []) << name
          else
            raise ArgumentError, "can't use this #{value.parameters}"
          end
        end
      end

      def needed_parameters_for(key)
        (@needed_parameters ||= {})[key] || []
      end
    end

    SEVERITY_LOG_SIZE = ::Logger::Severity.constants.map(&:to_s).max_by(&:size).size

    @out = STDOUT
    @prefixes = []
    @timestamp_format = '%Y-%m-%d %H:%M:%S,%L'

    @format = Formatter.new(
      prefixes: proc { @prefixes.join(' ') },
      timestamp: proc { |datetime| datetime.strftime(@timestamp_format) },
      severity: proc { |severity| "%#{SEVERITY_LOG_SIZE}s" % severity },
      sysdata: proc { "PID=#{Process.pid}" },
      message: proc { |message|
        case message
        when String then message
        when Hash then message.map { |(k, v)| "#{k}=#{v}" }.join(' ')
        end
      }
    )

    @format_as_string = ':prefixes [ :timestamp :sysdata ] [:severity] -- :message'

    def self.instance
      @instance ||=
        begin
          require 'logger'
          ::Logger.new(@out).tap(&apply_formatter)
        end
    end

    singleton_class.class_eval do
      attr_reader :format
      attr_accessor :format_as_string
    end

    def self.global_prefixes=(*prefixes)
      to_log = lambda { |obj| obj.respond_to?(:to_log) ? obj.to_log : obj.to_s }
      @prefixes = prefixes.map { |prefix| "[#{to_log.call(prefix)}]" }
    end

    def self.with_prefix(prefix)
      @prefixes << "[#{prefix}]"
      yield
      @prefixes.pop
    end

    private_class_method def self.apply_formatter
      proc do |logger|
        logger.formatter = proc do |severity, datetime, progname, message|
          @format_as_string.gsub(/:(?<part>\w+)/) do |match|
            format_part = match[1..-1].to_sym
            parameters = @format.needed_parameters_for(format_part).map do |name|
              binding.local_variable_get(name)
            end
            @format[format_part]&.call(*parameters)
          end.strip << $/
        end
      end
    end
  end
end
