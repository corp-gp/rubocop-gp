# frozen_string_literal: true

module RuboCop
  module Cop
    module Gp
      # This cop checks for nested module definitions that can be inlined into a single
      # declaration. It triggers when a series of modules each contain only the next,
      # and the innermost module contains a single class or module definition.
      #
      # @example
      #
      #   # bad
      #   module A
      #     module B
      #       class C
      #         # ...
      #       end
      #     end
      #   end
      #
      #   # good
      #   module A::B
      #     class C
      #       # ...
      #     end
      #   end
      #
      class InlineNestedModules < Base
        extend AutoCorrector

        MSG = 'Inline nested modules unless the last one contains a class or module body.'

        def on_module(node)
          # Start check from the outermost module, skipping already-namespaced ones.
          return if part_of_nesting?(node) || namespaced?(node)

          chain, last_body = find_nestable_chain(node)

          # An offense requires at least one level of nesting.
          return if chain.nil? || chain.size < 2

          add_offense(node) do |corrector|
            autocorrect(corrector, chain, last_body)
          end
        end

        private

        def autocorrect(corrector, chain, last_body)
          first_module = chain.first

          # 1. Determine indentation settings from config or use a default.
          indent_width = cop_config.fetch('IndentationWidth', 2)
          base_indent_col = first_module.loc.keyword.column
          base_indent = ' ' * base_indent_col

          # 2. Build the new `module A::B::C` header.
          module_names = chain.map { |m| m.children.first.const_name }.join('::')
          new_module_header = "#{base_indent}module #{module_names}"

          # 3. Calculate the change in indentation needed for the moved body.
          new_body_indent_col = base_indent_col + indent_width
          old_body_indent_col = last_body.loc.keyword.column
          indent_delta = new_body_indent_col - old_body_indent_col

          # 4. Re-indent the body's source code line by line.
          reindented_body_indent = base_indent + (' ' * indent_width)
          body_source = last_body.source
          reindented_body = body_source.lines.map do |line|
            next line if line.strip.empty?

            current_indent = line[/^\s*/].length
            new_indent_size = [0, current_indent + indent_delta].max

            (' ' * new_indent_size) + line.lstrip
          end.join

          # 5. Assemble the final, corrected code block.
          final_code = "#{new_module_header}\n#{reindented_body_indent}#{reindented_body}\n#{base_indent}end"

          # 6. Replace the original nested block.
          corrector.replace(first_module.source_range, final_code)
        end

        def part_of_nesting?(node)
          node.parent&.module_type?
        end

        def find_nestable_chain(node)
          chain = []
          current_node = node

          while valid_nesting_link?(current_node)
            chain << current_node
            current_node = current_node.body
          end

          return [nil, nil] unless current_node&.module_type? && !namespaced?(current_node)

          last_body = current_node.body
          if last_body && (last_body.class_type? || last_body.module_type?)
            chain << current_node
            [chain, last_body]
          else
            [nil, nil]
          end
        end

        def valid_nesting_link?(node)
          node&.module_type? &&
            !namespaced?(node) &&
            node.body&.module_type?
        end

        def namespaced?(module_node)
          # `module A::B`'s name node is `(const (const nil, :A), :B)`.
          # Its first child is another const node, not nil.
          !module_node.children.first.children.first.nil?
        end
      end
    end
  end
end
