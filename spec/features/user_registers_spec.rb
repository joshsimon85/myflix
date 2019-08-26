require 'spec_helper'
EMAIL = 'jon@testing.com'
PASSWORD = 'password'
FULL_NAME = 'Jon Doe'

DECLINED_CARD = '4000000000000002'
INVALID_CARD = '4242424242424241'
VALID_CARD = '4242424242424242'

feature 'User registers', js: true do
  background do
    visit register_path
  end

  scenario 'with valid user info and valid card' do
    fill_in_user_info
    fill_in_payment_info
    click_button 'Sign Up'
    sleep 2

    expect(page).to have_content 'You have registered'
  end

  scenario 'with valid user info and invalid card' do
    fill_in_user_info
    fill_in_payment_info(card_number: INVALID_CARD)
    click_button 'Sign Up'
    sleep 2

    expect(page).to have_content 'Your card number is incorrect.'
  end

  scenario 'with valid user info and declined card' do
    fill_in_user_info
    fill_in_payment_info({card_number: DECLINED_CARD})
    click_button 'Sign Up'
    sleep 2

    expect(page).to have_content 'There was a problem processing your payment, please try another payment method'
  end

  scenario 'with invalid user info and valid card' do
    fill_in_user_info({valid: false})
    fill_in_payment_info
    click_button 'Sign Up'
    sleep 2

    expect(page).to have_content "can't be blank"
  end

  scenario 'with invalid user info and invalid card' do
    fill_in_user_info({valid: false})
    fill_in_payment_info({card_number: INVALID_CARD})
    click_button 'Sign Up'
    sleep 2

    expect(page).to have_content "Your card number is incorrect"
    expect(User.count).to eq(0)
  end

  scenario 'with invalid user info and declined card' do
    fill_in_user_info({valid: false})
    fill_in_payment_info({card_number: DECLINED_CARD})
    click_button 'Sign Up'
    sleep 2

    expect(page).to have_content "can't be blank"
    expect(User.count).to eq(0)
  end
end

def default_year
  String(Time.now.next_year.year)
end

def fill_in_user_info(type={valid: true})
  if type[:valid]
    fill_in 'Email Address', with: EMAIL
    fill_in 'Password', with: PASSWORD
    fill_in 'Full Name', with: FULL_NAME
  else
    fill_in 'Email Address', with: EMAIL
    fill_in 'Password', with: ''
    fill_in 'Full Name', with: ''
  end
end

def fill_in_payment_info(card ={ ccv: '123', month: '7 - July'})
  fill_in 'Credit Card Number', with: card[:card_number] || VALID_CARD
  fill_in 'Security Code', with: card[:ccv] || '123'
  select (card[:month] ? card[:month] : '7 - July'), from: 'date_month'
  select (card[:year] ? card[:year] : default_year), from: 'date_year'
end
