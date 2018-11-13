require 'rspec'
require 'byebug'
require_relative '../lib/constrainable'

describe Constrainable do
  include Constrainable

  subject do
    deposit(amount)
  end

  describe '#deposit' do
    context 'when globally enabled' do
      before do
        Constrainable::Configure.config do |config|
          config.enabled = true
        end
      end

      context 'no constraints' do
        let(:amount) { 10 }

        def deposit(amount)
          balance = 10
          constrain do
            balance + amount
          end
        end

        it 'returns new balance' do
          expect(subject).to eq(20)
        end
      end

      context "'pre' hook" do
        let(:amount) { -10 }

        def deposit(amount)
          balance = 10
          constrain(pre: [-> { amount > 0 }]) do
            balance + amount
          end
        end

        context "when 'pre' hook fails" do
          context "when amount is less than zero" do
            it 'raises an error' do
              expect { subject }.to raise_error(Constrainable::PreHookFailure)
            end
          end
        end
      end

      context "'post' hook" do
        let(:amount) { -10 }

        def deposit(amount)
          balance = 10
          constrain(post: [-> (return_val) { return_val > balance }]) do
            balance + amount
          end
        end

        context "when 'post' hook fails" do
          context "when amount is less than zero" do
            it 'raises an error' do
              expect { subject }.to raise_error(Constrainable::PostHookFailure)
            end
          end
        end
      end
    end

    context 'when globally disabled' do
      let(:amount) { -10 }

      def deposit(amount)
        balance = 10
        constrain(pre: [-> { amount > 0 }]) do
          balance + amount
        end
      end

      before do
        Constrainable::Configure.config do |config|
          config.enabled = false
        end
      end

      after do
        Constrainable::Configure.config do |config|
          config.enabled = true
        end
      end

      it 'returns the new balance' do
        expect(subject).to eq(0)
      end

      context 'with local enable override' do
        context "'pre' hook" do
          context "when 'pre' hook fails" do

            def deposit(amount)
              balance = 10
              constrain(enable_local: true, pre: [-> { amount > 0 }]) do
                balance + amount
              end
            end
            context "when amount is less than zero" do
              it 'raises an error' do
                expect { subject }.to raise_error(Constrainable::PreHookFailure)
              end
            end
          end
        end

        context "'post' hook" do
          let(:amount) { -10 }

          def deposit(amount)
            balance = 10
            constrain(enable_local: true, post: [-> (return_val) { return_val > balance }]) do
              balance + amount
            end
          end

          context "when 'post' hook fails" do
            context "when amount is less than zero" do
              it 'raises an error' do
                expect { subject }.to raise_error(Constrainable::PostHookFailure)
              end
            end
          end
        end
      end
    end
  end
end
