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
    context 'successful user sign up' do
      it 'redirects to the sign in page' do
        result = double(:sign_up_result, successful?: true)
        UserSignup.any_instance.should_receive(:sign_up).and_return(result)
        post :create, user: Fabricate.attributes_for(:user)
        expect(response).to redirect_to sign_in_path
      end
    end

    context 'failed user sign up' do
      before do
        charge = double(:charge, successful?: false, error_message: 'Your card was declined')
        StripeWrapper::Charge.should_receive(:create).and_return(charge)
        post :create, user: Fabricate.attributes_for(:user)
      end

      it 'renders the new template' do
        expect(response).to render_template :new
      end

      it 'sets the flash error message' do
        expect(flash[:error]).to be_present
      end

      it 'does not create a new user record' do
        expect(User.count).to eq(0)
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
