require 'rspec'
require 'byebug'
require_relative '../lib/constrained'

describe Constrained do
  class User
    include Constrained

    def full_name(first, last)
      first + ' ' + last
    end
  end

  let(:user) { User.new }

  context 'User class' do
    describe '#full_name' do
      it 'returns the full name' do
        expect(user.full_name('Travis', 'Douce')).to eq('Travis Douce')
      end
    end
  end
end
