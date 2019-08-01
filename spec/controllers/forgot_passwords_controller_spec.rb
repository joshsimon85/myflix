require 'spec_helper'

describe ForgotPasswordsController do
  describe 'POST create' do
    context 'with blank inputs' do
      it 'redirect to the forgot password page' do
        post :create, email: ''
        expect(response).to redirect_to forgot_passwords_path
      end

      it 'show an error message' do
        post :create, email: ''
        expect(flash[:error]).to eq("Email can't be blank")
      end
    end

    context 'with existing email' do
      let!(:jon) { Fabricate(:user, email: 'jon@doe.com') }

      it 'redirects to the forgot password confirmation page' do
        post :create, email: 'jon@doe.com'
        expect(response).to redirect_to forgot_password_confirmation_path
      end

      it 'sends out an email to the email address' do
        post :create, email: 'jon@doe.com'
        expect(ActionMailer::Base.deliveries.last.to).to eq(['jon@doe.com'])
      end
    end

    context 'with nonexisting email' do

    end
  end
end
