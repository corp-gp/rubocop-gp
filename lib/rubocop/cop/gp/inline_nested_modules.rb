# frozen_string_literal: true

module RuboCop
  module Cop
    module Gp
      # This cop checks for nested module definitions that can be collapsed into a
      # namespace declaration. When modules are nested two or more levels deep, every
      # level except the innermost declaration is joined into a single `module A::B`
      # line, and the innermost declaration keeps a line of its own.
      #
      # Keeping the innermost declaration separate means turning a `module` into a
      # `class` (or back) never re-indents the whole file.
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
      #   # bad
      #   module A
      #     module B
      #       module C
      #         module_function
      #
      #         def call
      #         end
      #       end
      #     end
      #   end
      #
      #   # good
      #   module A::B
      #     module C
      #       module_function
      #
      #       def call
      #       end
      #     end
      #   end
      #
      class InlineNestedModules < Base
        extend AutoCorrector

        MSG = 'Inline nested modules into a namespace, keeping the innermost declaration on its own line.'

        def on_module(node)
          # Start check from the outermost module, skipping already-namespaced ones.
          return if part_of_nesting?(node) || namespaced?(node)

          chain = find_nestable_chain(node)
          return if chain.nil?

          namespace_chain, kept = split_namespace(chain)

          # Nothing to join if only one module would be left in the namespace.
          return if namespace_chain.size < 2

          add_offense(node) do |corrector|
            autocorrect(corrector, namespace_chain, kept)
          end
        end

        private

        # The innermost module holding a lone class/module declaration is itself part
        # of the namespace, because that declaration already occupies its own line.
        # Otherwise the innermost module is the declaration and has to stay separate.
        def split_namespace(chain)
          body = chain.last.body

          if body.class_type? || body.module_type?
            [chain, body]
          else
            [chain[0..-2], chain.last]
          end
        end

        def autocorrect(corrector, namespace_chain, kept)
          first_module = namespace_chain.first

          indent_width = cop_config.fetch('IndentationWidth', 2)
          base_indent_col = first_module.loc.keyword.column
          base_indent = ' ' * base_indent_col

          namespace = namespace_chain.map { |m| m.children.first.const_name }.join('::')
          new_module_header = "#{base_indent}module #{namespace}"

          new_body_indent_col = base_indent_col + indent_width
          indent_delta = new_body_indent_col - kept.loc.keyword.column

          reindented_body_indent = base_indent + (' ' * indent_width)
          reindented_body = kept.source.lines.map do |line|
            next line if line.strip.empty?

            current_indent = line[/^\s*/].length
            new_indent_size = [0, current_indent + indent_delta].max

            (' ' * new_indent_size) + line.lstrip
          end.join

          final_code = "#{new_module_header}\n#{reindented_body_indent}#{reindented_body}\n#{base_indent}end"

          corrector.replace(first_module.source_range, final_code)
        end

        def part_of_nesting?(node)
          node.parent&.module_type?
        end

        # Walks down while each module wraps exactly one more module, and returns the
        # whole chain. The last element is the declaration that keeps its own line.
        def find_nestable_chain(node)
          chain = []
          current_node = node

          while valid_nesting_link?(current_node)
            chain << current_node
            current_node = current_node.body
          end

          return unless current_node&.module_type? && !namespaced?(current_node)
          # An empty innermost module has nothing to namespace.
          return if current_node.body.nil?

          chain << current_node
          chain
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
