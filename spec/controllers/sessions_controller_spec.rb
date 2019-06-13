require 'spec_helper'

describe SessionsController do
  describe 'GET new' do
    it 'should render new template if unathenticated' do
      get :new
      expect(response).to render_template :new
    end

    it 'should redirect to videos index if authenticated' do
      session[:user_id] = Fabricate(:user).id
      get :new
      expect(response).to redirect_to home_path
    end
  end

  describe 'POST create' do
    context 'with valid credentials' do
      let(:alice) { Fabricate(:user) }
      before do
        post :create, email: alice.email, password: alice.password
      end

      it 'puts the signed in user into the session' do
        expect(session[:user_id]).to eq(alice.id)
      end

      it 'redirects to the home path' do
        expect(response).to redirect_to home_path
      end

      it 'sets the notice' do
        expect(flash[:notice]).not_to be_blank
      end
    end

    context 'with invalid credentials' do
      before do
        alice = Fabricate(:user)
        post :create, email: alice.email, password: alice.password + '123'
      end

      it 'does not put a user in the session' do
        expect(session[:user_id]).to be_nil
      end

      it 'redirects to sign in path' do
        expect(response).to redirect_to sign_in_path
      end

      it 'sets the error' do
        expect(flash[:error]).not_to be_blank
      end
    end
  end

  describe 'GET destoy' do
    before do
      session[:user_id] = Fabricate(:user).id
      get :destroy
    end

    it 'clears the session for the user' do
      expect(session[:user_id]).to be_nil
    end

    it 'redirects the the root path' do
      expect(response).to redirect_to root_path
    end

    it 'sets the notice' do
      expect(flash[:notice]).to_not be_blank
    end
  end
end
