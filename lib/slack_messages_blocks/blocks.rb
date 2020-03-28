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

    module Blocks
      class Block
        attr_reader :block_id

        def block_id=(obj)
          #raise TypeError unless obj.kind_of?(Block::Id)
          raise TypeError, 'block_id must be a string' unless block_id.respond_to?(:to_str)
          @block_id = obj.to_str
        end

        def to_h
          @type ||= self.class.name.split('::').last.chomp('Block').downcase
          { type: @type,
            block_id: @block_id
          }
        end
      end

      class ActionsBlock < Block; end
      class ContextBlock < Block
        attr_accessor :block_id
        attr_accessor :elements

        def self.[](hash)
          new.tap do |object|
            hash[:elements].each(&object.elements.method(:<<))
          end.tap do |object|
            raise ArgumentError, 'invalid ContextBlock' unless object.valid?
          end
        end

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
      class DividerBlock < Block
        def self.[](hash = nil)
          new.tap do |object|
            object.block_id = hash[:block_id] if hash&.key?(:block_id)
          end
        end

        def to_h
          super.reject { |_, v| v.nil? || v.empty? }
        end
      end
      class FileBlock < Block; end
      class ImageBlock < Block; end
      class InputBlock < Block; end
      class SectionBlock < Block
        attr_reader :text, :fields, :accessory

        def self.[](hash)
          new.tap do |object|
            object.accessory = hash[:accessory] if hash.key?(:accessory) 
            if hash.key?(:text) then object.text = hash[:text]
            elsif hash.key?(:fields) then hash[:fields].each(&object.fields.method(:<<))
            end
            object.block_id = hash[:block_id] if hash.key?(:block_id)
          end.tap do |object|
            raise ArgumentError, 'invalid SectionBlock' unless object.valid?
          end
        end

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
          if text
            raise RangeError, 'text in a SectionBlock may only have 3000 characters' unless text.text.size <= 3000
          end
          super.merge({
            block_id: block_id,
            text: text&.to_h,
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

    module ExecutionContext
      SectionBlock = Blocks::SectionBlock
      ContextBlock = Blocks::ContextBlock
      DividerBlock = Blocks::DividerBlock
      Text = CompositionObjects::Text

      Bold = proc { |string| "*#{string}*" }
      Italic = proc { |string| "_#{string}_" }
      Strike = proc { |string| "~#{string}~" }
      Code = proc { |string| "`#{string}`" }
      Link = proc { |link, label = nil| (label.nil? || label.empty?) ? "<#{link}|#{label}>" : link }

      def self.test(*data)
        require 'json'
        puts JSON.pretty_generate data.map(&:to_h)
      end
    end
  end
end
