module Slack
  module Messages
    class Payload < Hash
    end

    class TypeRestrictedArray < Array
      undef_method :concat, :[]= # Surely never necessary lol

      def initialize(*classes)
        @classes = classes
      end

      def <<(item)
        raise TypeError, "#{self.class} only accepts #{@classes}" unless @classes.any? { |cls| item.kind_of?(cls) }
        super(item)
      end
    end

    module CompositionObjects
      class Text
        attr_reader :type, :text, :emoji, :verbatim
        attr_writer :text

        PLAINTEXT = :plain_text
        MARKDOWN = :mrkdwn

        def type=(type)
          raise ArgumentError, 'type must be `plain_text` or `mrkdwn`' unless %i( plain_text mrkdwn ).include?(type.to_sym)
          @type = type.to_sym
        end

        def to_h
          { type: type,
            text: text
          }
        end
      end
    end

    module Blocks
      class Block
        attr_reader :block_id

        def block_id=(obj)
          #raise TypeError unless obj.kind_of?(Block::Id)
          raise TypeError, 'block_id must be a string' unless block_id.respond_to?(:to_str)
          @block_id = obj.to_str
        end

        def to_h
          @type ||= self.class.split('::').last.chop('Block').downcase
          { type: @type,
            block_id: @block_id
          }
        end
      end

      class ActionsBlock < Block; end
      class ContextBlock < Block
        attr_accessor :block_id
        attr_accessor :elements

        def initialize
          @elements = TypeRestrictedArray.new(BlockElements::Element, CompositionObjects::Text)
        end

        def valid?
          !@elements.empty?
        end

        def to_h
          super.merge({
            elements: elements.map(&:to_h)
          }).reject { |_, v| v.nil? || v.empty? }
        end
      end
      class DividerBlock < Block; end
      class FileBlock < Block; end
      class ImageBlock < Block; end
      class InputBlock < Block; end
      class SectionBlock < Block
        attr_reader :text, :fields, :accessory

        def initialize
          @fields = TypeRestrictedArray.new(CompositionObjects::Text)
        end

        # Either text or fields must exist and be non-empty.
        def valid?
          if @text.nil? || @text.empty? then !@fields.empty?
          else !@text&.empty?
          end
        end

        def text=(obj)
          raise TypeError, "text must be a #{CompositionObjects::Text}" unless obj.kind_of?(CompositionObjects::Text)
          @text = obj
        end

        def accessory=(elem)
          raise TypeError, 'accessory must be a block element' unless elem.kind_of?(BlockElements::Element)
          @accessory = elem
        end

        def to_h
          raise RangeError, 'text in a SectionBlock may only have 3000 characters' unless text.text.size <= 3000
          super.merge({
            block_id: block_id,
            text: text.to_h,
            fields: fields.map(&:to_h),
            accessory: accessory&.to_h
          }).reject { |_, v| v.nil? || v.empty? }
        end
      end
    end

    module BlockElements
      class Element
      end
    end
  end
end

if __FILE__ == $0
  require 'irb'
  require 'irb/completion'
  IRB.start
end
