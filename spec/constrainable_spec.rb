require 'rspec'
require_relative '../lib/constrainable'

describe Constrainable do
  include Constrainable

  def deposit(amount)
    constrain(constraint_options) do
      balance + amount
    end
  end

  let(:balance) { 10 }

  subject do
    deposit(amount)
  end

  before do
    Constrainable::Configure.config do |config|
      config.enabled = true
    end
  end

  describe '#constrain' do
    context 'no constraints' do
      let(:amount) { 10 }
      let(:constraint_options) { {} }

      it 'returns new balance' do
        expect(subject).to eq(20)
      end
    end

    context 'with constraints' do
      context "'pre' hook" do
        let(:amount) { -10 }
        let(:constraint_options) do
          { pre: [-> { amount > 0 }] }
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
        let(:constraint_options) do
          { post: [-> (return_val) { return_val > balance }] }
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
      let(:constraint_options) do
        { pre: [-> { amount > 0 }] }
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
            let(:constraint_options) do
              {
                enable_local: true,
                pre: [-> { amount > 0 }]
              }
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
          let(:constraint_options) do
            {
              enable_local: true,
              post: [-> (return_val) { return_val > balance }]
            }
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
