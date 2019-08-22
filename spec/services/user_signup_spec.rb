require 'spec_helper'

describe UserSignup do
  describe '#sign_up' do
    after do
      Sidekiq::Worker.clear_all
      ActionMailer::Base.deliveries.clear
    end
    
    context 'valid personal info and valid card' do
      let(:charge) { double('charge', successful?: true) }

      before do
        allow(StripeWrapper::Charge).to receive(:create).and_return(charge)
      end

      it 'create the user' do
        UserSignup.new(Fabricate.build(:user)).sign_up('some_stripe_token', nil)
        expect(User.count).to eq(1)
      end

      it 'makes the user follow the inviter' do
        alice = Fabricate(:user)
        invitation = Fabricate(:invitation, inviter: alice, recipient_email: 'joe@example.com')
        UserSignup.new(Fabricate.build(:user, email: 'joe@example.com', password: 'password', full_name: 'Jon Doe')).sign_up('some_stripe_token', invitation.token)
        joe = User.where(email: 'joe@example.com').first
        expect(joe.follows?(alice)).to be_truthy
      end

      it 'makes the inviter follow the user' do
        alice = Fabricate(:user)
        invitation = Fabricate(:invitation, inviter: alice, recipient_email: 'joe@example.com')
        UserSignup.new(Fabricate.build(:user, email: 'joe@example.com', password: 'password', full_name: 'Jon Doe')).sign_up('some_stripe_token', invitation.token)
        joe = User.where(email: 'joe@example.com').first
        expect(alice.follows?(joe)).to be_truthy
      end

      it 'expires the invitation upon acceptance' do
        alice = Fabricate(:user)
        invitation = Fabricate(:invitation, inviter: alice, recipient_email: 'joe@example.com')
        UserSignup.new(Fabricate.build(:user, email: 'joe@example.com', password: 'password', full_name: 'Jon Doe')).sign_up('some_stripe_token', invitation.token)
        expect(Invitation.first.token).to be_nil
      end

      it 'sends out email to the user with valid inputs' do
        UserSignup.new(Fabricate.build(:user, email: 'joe@example.com', password: 'password', full_name: 'Jon Doe')).sign_up('some_stripe_token', nil)
        expect(ActionMailer::Base.deliveries.last.to).to eq(['joe@example.com'])
      end

      it 'sends out email containing the users name with valid inputs' do
        UserSignup.new(Fabricate.build(:user, email: 'joe@example.com', password: 'password', full_name: 'Jon Doe')).sign_up('some_stripe_token', nil)
        expect(ActionMailer::Base.deliveries.last.body).to include('Jon Doe')
      end
    end

    context 'valid personal info and declined card' do
      it 'does not create a new user record' do
        charge = double(:charge, successful?: false, error_message: 'Your card was declined.')
        allow(StripeWrapper::Charge).to receive(:create).and_return(charge)
        UserSignup.new(Fabricate.build(:user)).sign_up('1231241', nil)
        expect(User.count).to eq(0)
      end
    end

    context 'with invalid personal info' do
      it 'does not create the user' do
        UserSignup.new(User.new(email: 'test@test.com')).sign_up('1231241', nil)
        expect(User.count).to eq(0)
      end

      it 'does not charge the card' do
        StripeWrapper::Charge.should_not_receive(:create)
        UserSignup.new(User.new(email: 'test@test.com')).sign_up('1231241', nil)
      end

      it 'does not send out email' do
        UserSignup.new(User.new(email: 'test@test.com')).sign_up('1231241', nil)
        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end
  end
end
