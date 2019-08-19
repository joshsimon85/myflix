require 'spec_helper'

describe UsersController do
  after { Sidekiq::Worker.clear_all }

  describe 'GET new' do
    it 'sets @user' do
      get :new
      expect(assigns(:user)).to be_instance_of(User)
    end
  end

  describe 'POST create' do
    context 'valid personal info and valid card' do
      let(:charge) { double('charge', successful?: true) }

      before do
        allow(StripeWrapper::Charge).to receive(:create).and_return(charge)
        post :create, user: Fabricate.attributes_for(:user)
      end

      it 'create the user' do
        expect(User.count).to eq(1)
      end

      it 'redirects to the sign in page' do
        expect(response).to redirect_to sign_in_path
      end

      it 'makes the user follow the inviter' do
        alice = Fabricate(:user)
        invitation = Fabricate(:invitation, inviter: alice, recipient_email: 'joe@example.com')
        post :create, user: { email: 'joe@example.com', password: 'password', full_name: 'Joe Doe' }, invitation_token: invitation.token
        joe = User.where(email: 'joe@example.com').first
        expect(joe.follows?(alice)).to be_truthy
      end

      it 'makes the inviter follow the user' do
        alice = Fabricate(:user)
        invitation = Fabricate(:invitation, inviter: alice, recipient_email: 'joe@example.com')
        post :create, user: { email: 'joe@example.com', password: 'password', full_name: 'Joe Doe' }, invitation_token: invitation.token
        joe = User.where(email: 'joe@example.com').first
        expect(alice.follows?(joe)).to be_truthy
      end

      it 'expires the invitation upon acceptance' do
        alice = Fabricate(:user)
        invitation = Fabricate(:invitation, inviter: alice, recipient_email: 'joe@example.com')
        post :create, user: { email: 'joe@example.com', password: 'password', full_name: 'Joe Doe' }, invitation_token: invitation.token
        expect(Invitation.first.token).to be_nil
      end
    end

    context 'valid personal info and declined card' do
      let(:charge) { double('charge', successful?: false, error_message: 'Your card was declined') }

      before do
        allow(StripeWrapper::Charge).to receive(:create).and_return(charge)
        post :create, user: Fabricate.attributes_for(:user), stripeToken: '1231241'
      end

      it 'does not create a new user record' do
        expect(User.count).to eq(0)
      end

      it 'renders the new template' do
        charge = double('charge', successful?: false)
      end

      it 'sets the flash error message' do
        expect(flash[:error]).to be_present
      end
    end

    context 'with invalid personal info' do
      before do
        allow(StripeWrapper::Charge).to receive(:create)
        post :create, user: { password: 'password', full_name: 'Jon Doe' }
      end

      it 'does not create the user' do
        expect(User.count).to eq(0)
      end

      it 'renders the :new template' do
        expect(response).to  render_template :new
      end

      it 'sets @user' do
        expect(assigns(:user)).to be_instance_of(User)
      end

      it 'does not charge the card' do
        StripeWrapper::Charge.should_not_receive(:create)
        post :create, user: { email: 'joe@example.com' }
      end
    end

    context 'sending emails' do
      let(:charge) { double('charge', successful?: true) }

      before do
        ActionMailer::Base.deliveries.clear
        allow(StripeWrapper::Charge).to receive(:create).and_return(charge)
      end

      it 'sends out email to the user with valid inputs' do
        post :create, user: { email: 'jon@doe.com', password: 'password', full_name: 'Jon Doe'}
        expect(ActionMailer::Base.deliveries.last.to).to eq(['jon@doe.com'])
      end

      it 'sends out email containing the users name with valid inputs' do
        post :create, user: { email: 'jon@doe.com', password: 'password', full_name: 'Jon Doe'}
        expect(ActionMailer::Base.deliveries.last.body).to include('Welcome to MyFlix')
      end

      it 'does not send out email with invalid inputs' do
        post :create, user: { email: 'jon@doe.com' }
        expect(ActionMailer::Base.deliveries.count).to eq(0)
      end
    end
  end

  describe 'GET show' do
    it_behaves_like 'requires sign in' do
      let(:action) { get :show, id: 3 }
    end

    it 'sets @user' do
      set_current_user
      jon = Fabricate(:user)
      get :show, id: jon.id
      expect(assigns(:user)).to eq(jon)
    end
  end

  describe 'GET new_with_invitation_token' do
    it 'renders the :new view template' do
      invitation = Fabricate(:invitation)
      get :new_with_invitation_token, token: invitation.token
      expect(response).to render_template :new
    end

    it "sets @user with recipient's email" do
      invitation = Fabricate(:invitation)
      get :new_with_invitation_token, token: invitation.token
      expect(assigns(:user).email).to eq(invitation.recipient_email)
    end

    it 'redirects to expired token page for invalid tokens' do
      invitation = Fabricate(:invitation)
      get :new_with_invitation_token, token: '12345'
      expect(response).to redirect_to expired_token_path
    end

    it 'sets @invitation_token' do
      invitation = Fabricate(:invitation)
      get :new_with_invitation_token, token: invitation.token
      expect(assigns(:invitation_token)).to eq(invitation.token)
    end
  end
end
