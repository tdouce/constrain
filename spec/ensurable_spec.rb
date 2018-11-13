require 'rspec'
require 'byebug'
require_relative '../lib/ensurable'

describe Ensurable do
  let(:amount) { 10 }
  subject do
    BankAccount.new.deposit(amount)
  end

  context 'BankAccount' do
    class BankAccount
      include Ensurable

      def initialize
        @balance = 100
      end

      def deposit(amount)
        @balance + amount
      end
    end

    describe '#deposit' do
      it 'returns new balance' do
        expect(subject).to eq(110)
      end
    end
  end

  context "'pre' hook" do
    it 'does something different' do
      expect(subject).to eq(110)
    end
  end
end
