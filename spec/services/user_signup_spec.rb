require 'spec_helper'

describe UserSignup do
  describe '#sign_up' do
    after do
      Sidekiq::Worker.clear_all
      ActionMailer::Base.deliveries.clear
    end

    context 'valid personal info and valid card' do
      let(:customer) { double(:customer, successful?: true, customer_token: 'abcdefg') }

      before do
        allow(StripeWrapper::Customer).to receive(:create).and_return(customer)
      end

      it 'create the user' do
        VCR.use_cassette('create user') do
          UserSignup.new(Fabricate.build(:user)).sign_up('some_stripe_token', nil)
          expect(User.count).to eq(1)
        end
      end

      it 'stores the customer token from stripe' do
        VCR.use_cassette('save customer token') do
          UserSignup.new(Fabricate.build(:user)).sign_up('some_stripe_token', nil)
          expect(User.first.customer_token).to eq('abcdefg')
        end
      end

      it 'makes the user follow the inviter' do
        VCR.use_cassette('user follows inviter') do
          alice = Fabricate(:user)
          invitation = Fabricate(:invitation, inviter: alice, recipient_email: 'joe@example.com')
          UserSignup.new(Fabricate.build(:user, email: 'joe@example.com', password: 'password', full_name: 'Jon Doe')).sign_up('some_stripe_token', invitation.token)
          joe = User.where(email: 'joe@example.com').first
          expect(joe.follows?(alice)).to be_truthy
        end
      end

      it 'makes the inviter follow the user' do
        VCR.use_cassette('invitor follows user') do
          alice = Fabricate(:user)
          invitation = Fabricate(:invitation, inviter: alice, recipient_email: 'joe@example.com')
          UserSignup.new(Fabricate.build(:user, email: 'joe@example.com', password: 'password', full_name: 'Jon Doe')).sign_up('some_stripe_token', invitation.token)
          joe = User.where(email: 'joe@example.com').first
          expect(alice.follows?(joe)).to be_truthy
        end
      end

      it 'expires the invitation upon acceptance' do
        VCR.use_cassette('expires invitation token') do
          alice = Fabricate(:user)
          invitation = Fabricate(:invitation, inviter: alice, recipient_email: 'joe@example.com')
          UserSignup.new(Fabricate.build(:user, email: 'joe@example.com', password: 'password', full_name: 'Jon Doe')).sign_up('some_stripe_token', invitation.token)
          expect(Invitation.first.token).to be_nil
        end
      end

      it 'sends out email to the user with valid inputs' do
        VCR.use_cassette('sends out an email with valid inputs') do
          UserSignup.new(Fabricate.build(:user, email: 'joe@example.com', password: 'password', full_name: 'Jon Doe')).sign_up('some_stripe_token', nil)
          expect(ActionMailer::Base.deliveries.last.to).to eq(['joe@example.com'])
        end
      end

      it 'sends out email containing the users name with valid inputs' do
        VCR.use_cassette('sends out email containing users name') do
          UserSignup.new(Fabricate.build(:user, email: 'joe@example.com', password: 'password', full_name: 'Jon Doe')).sign_up('some_stripe_token', nil)
          expect(ActionMailer::Base.deliveries.last.body).to include('Jon Doe')
        end
      end
    end

    context 'valid personal info and declined card' do
      it 'does not create a new user record' do
        VCR.use_cassette('does not create a new user') do
          customer = double(:customer, successful?: false, error_message: 'Your card was declined.')
          allow(StripeWrapper::Customer).to receive(:create).and_return(customer)
          UserSignup.new(Fabricate.build(:user)).sign_up('1231241', nil)
          expect(User.count).to eq(0)
        end
      end
    end

    context 'with invalid personal info' do
      it 'does not create the user' do
        VCR.use_cassette('does not create the user') do
          UserSignup.new(User.new(email: 'test@test.com')).sign_up('1231241', nil)
          expect(User.count).to eq(0)
        end
      end

      it 'does not charge the card' do
        VCR.use_cassette('does not charge card') do
          StripeWrapper::Customer.should_not_receive(:create)
          UserSignup.new(User.new(email: 'test@test.com')).sign_up('1231241', nil)
        end
      end

      it 'does not send out email' do
        VCR.use_cassette('does not send out email') do
          UserSignup.new(User.new(email: 'test@test.com')).sign_up('1231241', nil)
          expect(ActionMailer::Base.deliveries).to be_empty
        end
      end
    end
  end
end
