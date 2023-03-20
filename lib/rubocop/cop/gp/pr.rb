module RuboCop
  module Cop
    module Gp
      # Checks for the use of `pr`
      #
      # @example
      #   # bad
      #   pr 'A debug message'
      #
      #   # good
      #   Rails.logger.debug 'A debug message'
      class Pr < Cop
        MSG = 'Remove `pr` call or use `Rails.logger.debug` instead.'

        def on_send(node)
          return unless node.command?(:pr)

          add_offense(node)
        end
      end
    end
  end
end
