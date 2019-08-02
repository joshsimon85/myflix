require 'spec_helper'

feature 'User interacts with relationships' do
  scenario 'user follows another user' do
    comedies = Fabricate(:category)
    monk = Fabricate(:video, title: 'Monk', category: comedies)
    alice = Fabricate(:user)
    bob = Fabricate(:user)
    review = Fabricate(:review, user: bob, video: monk)

    visit root_path

    click_link 'Sign In'

    fill_in 'Email Address', with: alice.email
    fill_in 'Password', with: alice.password
    click_button 'Sign in'

    click_on_video

    click_on_review

    follow_user
    page.should have_content bob.full_name

    visit user_path(alice)
    page.should have_no_content 'Follow'

    visit people_path
    unfollow(bob)
    page.should have_no_content bob.full_name

    visit user_path(alice)
    page.should have_no_content 'Follow'
  end

  def click_on_video
    find('.video a').click
  end

  def click_on_review
    find('.review a').click
  end

  def follow_user
    click_link 'Follow'
  end

  def unfollow(user)
    find('a[data-method="delete"]').click
  end
end
