require 'spec_helper'

feature 'Reseting password' do
  let(:alice) { Fabricate(:user, password: 'password') }

  scenario 'Existing user resets password' do
    visit sign_in_path
    click_link 'Forgot Password'

    fill_in 'Email Address', with: alice.email
    click_on 'Send Email'

    expect(page).to have_content 'We have sent an'

    open_email(alice.email)

    expect(current_email).to have_content 'Please click on the link'
    current_email.click_on('Reset My Password')

    fill_in 'New Password', with: 'new_password'
    click_on 'Reset Password'

    fill_in 'Email Address', with: alice.email
    fill_in 'Password', with: 'new_password'
    click_on 'Sign in'

    expect(page).to have_content "Welcome, #{alice.full_name}"
    clear_email
  end
end
