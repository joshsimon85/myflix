require 'spec_helper'

feature 'User invites a friend' do
  scenario 'User successfully invites a friend and invitation is accepted' do
    alice = Fabricate(:user)
    sign_in(alice)

    invite_a_friend

    friend_accepts_invitation

    friend_signs_in

    friend_should_follow(alice)

    inviter_should_follow_friend(alice)
  
    clear_email
  end

  def invite_a_friend
    visit new_invitation_path
    fill_in "Friend's Name", with: 'Jon Doe'
    fill_in "Friend's Email Address", with: 'jon@example.com'
    fill_in 'Message', with: 'Please join this site.'
    click_on 'Send Invitation'
    sign_out
  end

  def friend_accepts_invitation
    open_email 'jon@example.com'
    current_email.click_link 'Accept this invitation'

    fill_in 'Password', with: 'password'
    fill_in 'Full Name', with: 'Jon Doe'
    click_on 'Sign Up'
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
