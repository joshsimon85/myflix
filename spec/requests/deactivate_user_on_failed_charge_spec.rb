require 'spec_helper'

describe 'Deactivate user on failed charge' do
  def bypasss_event_signature(payload)
    event = Stripe::Event.construct_from(JSON.parse(payload, symbolize_names: true))
    expect(Stripe::Webhook).to receive(:construct_event).and_return(event)
  end

  let(:payload) { File.read('spec/support/fixtures/event_card_declined.json')}
  before(:each) { bypasss_event_signature payload }

  it 'deactivates a user with the web hook data from stripe for charge failed' do
    alice = Fabricate(:user, customer_token: 'cus_00000000000000')
    post '/stripe_events', body: payload
    expect(alice.reload).not_to be_active
  end
end
