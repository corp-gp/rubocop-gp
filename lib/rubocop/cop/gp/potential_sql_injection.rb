module RuboCop
  module Cop
    module Gp
      class PotentialSqlInjection < Cop
        VULNERABLE_AR_METHODS = [
            :pluck,
            :exists?,
            :execute,
            :find_by_sql,
            :group,
            :having,
            :insert,
            :order,
            :reorder,
            :select_rows,
            :select_values,
            :select_all,
            :where,
            :query, # https://github.com/discourse/mini_sql/blob/master/lib/mini_sql/builder.rb
            :query_single,
            :query_hash,
            :exec
        ].freeze
        MSG = 'Passing a string computed by interpolation or addition to an ActiveRecord, MiniSql ' \
              'method is likely to lead to SQL injection. Use hash or parameterized syntax. For ' \
              'more information, see ' \
              'http://guides.rubyonrails.org/security.html#sql-injection-countermeasures and ' \
              'https://github.com/discourse/mini_sql/blob/master/test/mini_sql/connection_tests.rb. If you have confirmed with Security that this is a ' \
              'safe usage of this style, disable this alert with ' \
              '`# rubocop:disable Gp/PotentialSqlInjection`.'.freeze
        def on_send(node)
          receiver, method_name, *_args = *node

          return if receiver.nil?
          return unless vulnerable_ar_method?(method_name)
          if !includes_interpolation?(_args) && !includes_sum?(_args)
            return
          end

          add_offense(node)
        end

        def vulnerable_ar_method?(method)
          VULNERABLE_AR_METHODS.include?(method)
        end

        # Return true if the first arg is a :dstr that has non-:str components
        def includes_interpolation?(args)
          !args.first.nil? &&
              args.first.type == :dstr &&
              args.first.each_child_node.any? { |child| child.type != :str }
        end

        def includes_sum?(args)
          !args.first.nil? &&
              args.first.type == :send &&
              args.first.method_name == :+
        end
      end
    end
  end
end