require 'spec_helper'

feature 'User invites a friend' do
  after { ActionMailer::Base.deliveries.clear }

  scenario 'User successfully invites a friend and invitation is accepted', js: true do
    alice = Fabricate(:user)
    sign_in(alice)
    sleep 2

    invite_a_friend

    friend_accepts_invitation

    friend_signs_in

    friend_should_follow(alice)

    inviter_should_follow_friend(alice)

    clear_email
  end

  def invite_a_friend
    visit new_invitation_path
    sleep 2

    fill_in "Friend's Name", with: 'Jon Doe'
    fill_in "Friend's Email Address", with: 'jon@example.com'
    fill_in 'Message', with: 'Please join this site.'
    click_on 'Send Invitation'


    sign_out
  end

  def friend_accepts_invitation
    sleep 5
    open_email 'jon@example.com'
    current_email.click_link 'Accept this invitation'

    fill_in 'Password', with: 'password'
    fill_in 'Full Name', with: 'Jon Doe'
    fill_in 'Credit Card Number', with: '4242424242424242'
    fill_in 'Security Code', with: '123'
    select '7 - July', from: 'date_month'
    select '2020', from: 'date_year'
    click_on 'Sign Up'

    sleep 2
  end

  def friend_signs_in
    fill_in 'Email Address', with: 'jon@example.com'
    fill_in 'Password', with: 'password'
    click_on 'Sign in'
  end

  def friend_should_follow(user)
    click_link 'People'
    expect(page).to have_content user.full_name
    sign_out
  end

  def inviter_should_follow_friend(user)
    sign_in(user)
    click_link 'People'
    expect(page).to have_content 'Jon Doe'
  end
end
