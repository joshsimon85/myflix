require 'spec_helper'

describe 'Create payment on successful charge' do
  def bypasss_event_signature(payload)
    event = Stripe::Event.construct_from(JSON.parse(payload, symbolize_names: true))
    expect(Stripe::Webhook).to receive(:construct_event).and_return(event)
  end

  let(:payload) { File.read('spec/support/fixtures/event_customer_created.json')}
  before(:each) { bypasss_event_signature payload }

  it 'creates a payment with the webhook from stripe for charge succeeded' do
    post '/stripe_events', body: payload
    expect(Payment.count).to eq(1)
  end

  it 'creates the payment associated with the user' do
    alice = Fabricate(:user, customer_token: 'cus_00000000000000')
    post '/stripe_events', body: payload
    expect(Payment.first.user).to eq(alice)
  end

  it 'creates the payment with the amount' do
    alice = Fabricate(:user, customer_token: 'cus_00000000000000')
    post '/stripe_events', body: payload
    expect(Payment.first.amount).to eq(999)
  end

  it 'creates the payment with reference id' do
    alice = Fabricate(:user, customer_token: 'cus_00000000000000')
    post '/stripe_events', body: payload
    expect(Payment.first.reference_id).to eq('ch_00000000000000')
  end
end
