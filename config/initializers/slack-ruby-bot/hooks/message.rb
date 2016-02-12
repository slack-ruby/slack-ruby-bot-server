module SlackRubyBot
  module Hooks
    module Message
      alias_method :_message, :message

      def message(client, data)
        _message client, data
        GC::OOB.run
      end
    end
  end
end
