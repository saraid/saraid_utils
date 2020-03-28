module Slack
  module Messages
    module Blocks
      module CompositionObjects
        class Text
          attr_reader :type, :text, :emoji, :verbatim

          PLAINTEXT = :plain_text
          MRKDWN = :mrkdwn

          def self.[](hash)
            new.tap do |object|
              object.type = hash.keys.find { |key| key == PLAINTEXT || key == MRKDWN }
              raise ArgumentError, 'type must be `plain_text` or `mrkdwn`' unless object.type
              object.text = hash[object.type]
            end
          end

          def empty?
            text&.empty?
          end

          def type=(type)
            raise ArgumentError, 'type must be `plain_text` or `mrkdwn`' unless %i( plain_text mrkdwn ).include?(type.to_sym)
            @type = type.to_sym
          end

          NEWLINE = "\n"

          def text=(text)
            text = text.join(NEWLINE) if text.kind_of?(Array)
            raise TypeError, 'text must be a string' unless text.respond_to?(:to_str)
            @text = text.to_s
          end

          def to_h
            { type: type,
              text: text
            }
          end
        end
      end
    end
  end
end
