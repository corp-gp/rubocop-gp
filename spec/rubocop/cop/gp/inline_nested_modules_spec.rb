# frozen_string_literal: true

require "spec_helper"

RSpec.describe RuboCop::Cop::Gp::InlineNestedModules, :config do
  let(:config) { RuboCop::Config.new }

  it "registers and corrects nested module namespaces" do
    expect_offense(<<~RUBY)
      module A
      ^^^^^^^^ Gp/InlineNestedModules: Inline nested modules unless the last one contains a class or module body.
        module B
          module C
            class Component < ApplicationComponent
              def foo
                1
              end

              class Bar; end
            end
          end
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      module A::B::C
        class Component < ApplicationComponent
          def foo
            1
          end

          class Bar; end
        end
      end
    RUBY
  end

  it "does not register offense for already inlined module" do
    expect_no_offenses(<<~RUBY)
      module A::B::C
        class Component < ApplicationComponent
        end
      end
    RUBY
  end

  it "does not register offense if not followed by class/module" do
    expect_no_offenses(<<~RUBY)
      module A
        module B
          def method
          end
        end
      end
    RUBY
  end
end
