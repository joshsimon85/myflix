require 'spec_helper'

feature 'Signing In' do
  scenario 'Sign in with existing credentials' do
    alice = Fabricate(:user)
    sign_in(alice)
    expect(page).to have_content alice.full_name
  end
end
