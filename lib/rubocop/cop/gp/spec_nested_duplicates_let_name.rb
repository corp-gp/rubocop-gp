# frozen_string_literal: true

require 'rubocop-rspec'

module RuboCop
  module Cop
    module Gp
      # Checks nested duplicates name `let` and `let!`
      #
      # @example
      #   # Bad
      #   let(:order) { create(:order) }
      #
      #   it 'check delivery cost' do
      #     expect(order.delivery_cost).to eq(100)
      #   end
      #
      #   context 'when courier order' do
      #     let!(:order) { create(:order, :courier) }
      #
      #     it 'check delivery cost' do
      #       expect(order.delivery_cost).to eq(222)
      #     end
      #   end
      #
      #   # Good
      #   let(:order) { create(:order) }
      #
      #   it 'check delivery cost' do
      #     expect(order.delivery_cost).to eq(100)
      #   end
      #
      #   context 'when courier order' do
      #     let!(:order_courier) { create(:order, :courier) }
      #
      #     it 'check delivery cost' do
      #       expect(order_courier.delivery_cost).to eq(222)
      #     end
      #   end

      class SpecNestedDuplicatesLetName < RuboCop::Cop::RSpec::Base
        include RuboCop::Cop::RSpec::TopLevelGroup
        MSG = 'Let name already used on up level (context, describe)'

        def on_top_level_group(node)
          nesting_by_let_name = {}
          find_nested_example_groups(node) do |example_group, nesting|
            RuboCop::RSpec::ExampleGroup.new(example_group).lets.each do |let|
              let_name = let.children[0].first_argument.value

              nesting_by_let_name[let_name] ||= []

              if nesting_by_let_name[let_name].any? { |n| n < nesting }
                add_offense(let)
              end

              nesting_by_let_name[let_name] << nesting
            end
          end
        end

        private

        def find_nested_example_groups(node, nesting: 1, &block)
          example_group = example_group?(node)
          yield node, nesting if example_group

          next_nesting = example_group ? nesting + 1 : nesting

          node.each_child_node(:block, :begin) do |child|
            find_nested_example_groups(child, nesting: next_nesting, &block)
          end
        end

      end
    end
  end
end
