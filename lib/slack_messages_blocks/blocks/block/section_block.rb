module Slack
  module Messages
    module Blocks
      class Block
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
            raise TypeError, 'accessory must be a block element' unless elem.kind_of?(Element)
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
    end
  end
end
