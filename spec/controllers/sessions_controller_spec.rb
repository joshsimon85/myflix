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

      it 'pust the signed in user into the session' do
        alice = Fabricate(:user)
        post :create, email: alice.email, password: alice.password
        expect(session[:user_id]).to eq(alice.id)
      end

      it 'redirects to the home path' do
        alice = Fabricate(:user)
        post :create, email: alice.email, password: alice.password
        expect(response).to redirect_to home_path
      end

      it 'sets the notice' do
        alice = Fabricate(:user)
        post :create, email: alice.email, password: alice.password
        expect(flash[:notice]).not_to be_blank
      end
    end

    context 'with invalid credentials' do
      it 'does not put a user in the session' do
        alice = Fabricate(:user)
        post :create, email: alice.email, password: alice.password + '123'
        expect(session[:user_id]).to be_nil
      end

      it 'redirects to sign in path' do
        alice = Fabricate(:user)
        post :create, email: alice.email, password: alice.password + '123'
        expect(response).to redirect_to sign_in_path
      end

      it 'sets the error' do
        alice = Fabricate(:user)
        post :create, email: alice.email, password: alice.password + '123'
        expect(flash[:error]).not_to be_blank
      end
    end
  end

  describe 'GET destoy' do
    it 'clears the session for the user' do
      session[:user_id] = Fabricate(:user).id
      get :destroy
      expect(session[:user_id]).to be_nil
    end

    it 'redirects the the root path' do
      session[:user_id] = Fabricate(:user).id
      get  :destroy
      expect(response).to redirect_to root_path
    end
  end
end
