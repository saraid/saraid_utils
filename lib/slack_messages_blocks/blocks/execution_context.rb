module Slack
  module Messages
    module Blocks
      # TO USE:
      # include Slack::Messages::Blocks::ExecutionContext
      # data = [ SectionBlock[text: Text[mrkdwn: 'wheeee']] ]
      # Slack::Messages::Blocks::ExecutionContext.test(data)
      # => [
      #      {
      #        "type": "section",
      #        "text": {
      #          "type": "mrkdwn",
      #          "text": "wheeee"
      #        }
      #      }
      #    ]
      module ExecutionContext
        SectionBlock = Block::SectionBlock
        ContextBlock = Block::ContextBlock
        DividerBlock = Block::DividerBlock
        Text = CompositionObjects::Text

        Bold = proc { |string| "*#{string}*" }
        Italic = proc { |string| "_#{string}_" }
        Strike = proc { |string| "~#{string}~" }
        Code = proc { |string| "`#{string}`" }
        Link = proc { |link, label = nil| (label.nil? || label.empty?) ? "<#{link}|#{label}>" : link }

        def self.test(data)
          require 'json'
          puts JSON.pretty_generate data.map(&:to_h)
        end
      end
    end
  end
end
