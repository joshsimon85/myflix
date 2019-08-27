require 'spec_helper'

feature 'Signing In' do
  scenario 'Sign in with existing credentials' do
    alice = Fabricate(:user)
    sign_in(alice)
    expect(page).to have_content alice.full_name
  end

  scenario 'Sign in with deactivated user' do
    alice = Fabricate(:user, active: false)
    sign_in(alice)
    expect(page).not_to have_content alice.full_name
    expect(page).to have_content('Your account has been suspended, please contact customer service.')
  end
end
