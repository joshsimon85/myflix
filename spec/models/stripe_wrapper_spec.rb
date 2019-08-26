require 'spec_helper'

describe StripeWrapper do
  describe StripeWrapper::Charge do
    describe '.create' do
      it 'successfull charge' do
        VCR.use_cassette('successful charge') do
          valid_token = Stripe::Token.create({
            card: {
              number: '4242424242424242',
              exp_month: 6,
              exp_year: 2020,
              cvc: 314
            }
          }).id

          response = StripeWrapper::Charge.create({
            amount: 999,
            card: valid_token,
            description: 'a valid charge'
          })
          expect(response).to be_successful
        end
      end

      it 'makes a card declined charge' do
        VCR.use_cassette('unsuccessful charge') do
          invalid_token = Stripe::Token.create({
            card: {
              number: '4000000000000002',
              exp_month: 6,
              exp_year: 2020,
              cvc: 314
            }
          }).id

          response = StripeWrapper::Charge.create({
            amount: 999,
            card: invalid_token,
            description: 'an ivalid charge'
          })
          expect(response).not_to be_successful
        end
      end

      it 'returns the error message for a declined charge' do
        VCR.use_cassette('declined card') do
          invalid_token = Stripe::Token.create({
            card: {
              number: '4000000000000002',
              exp_month: 6,
              exp_year: 2020,
              cvc: 314
            }
          }).id

          response = StripeWrapper::Charge.create({
            amount: 999,
            card: invalid_token,
            description: 'an ivalid charge'
          })
          expect(response.error_message).to eq('Your card was declined.')
        end
      end
    end

    describe StripeWrapper::Customer do
      describe ".create" do
        it 'creates a customer with a valid card' do
          VCR.use_cassette('create stripe user') do
            alice = Fabricate(:user)
            valid_token = Stripe::Token.create({
              card: {
                number: '4242424242424242',
                exp_month: 6,
                exp_year: 2020,
                cvc: 314
              }
            }).id

            response = StripeWrapper::Customer.create(
              user: alice,
              card: valid_token
            )
            expect(response).to be_successful
          end
        end

        it 'returns the customer token for a valid card' do
          VCR.use_cassette('customer token') do
            alice = Fabricate(:user)
            valid_token = Stripe::Token.create({
              card: {
                number: '4242424242424242',
                exp_month: 6,
                exp_year: 2020,
                cvc: 314
              }
            }).id

            response = StripeWrapper::Customer.create(
              user: alice,
              card: valid_token
            )
            expect(response.customer_token).to be_present
          end
        end

        it 'does not create a customer with a declined card' do
          VCR.use_cassette('does not create stripe user') do
            alice = Fabricate(:user)
            invalid_token = Stripe::Token.create({
              card: {
                number: '4000000000000002',
                exp_month: 6,
                exp_year: 2020,
                cvc: 314
              }
            }).id

            response = StripeWrapper::Customer.create(
              user: alice,
              card: invalid_token
            )
            expect(response).not_to be_successful
          end
        end

        it 'returns the error message for declined card' do
          VCR.use_cassette('does not create stripe user') do
            alice = Fabricate(:user)
            invalid_token = Stripe::Token.create({
              card: {
                number: '4000000000000002',
                exp_month: 6,
                exp_year: 2020,
                cvc: 314
              }
            }).id

            response = StripeWrapper::Customer.create(
              user: alice,
              card: invalid_token
            )
            expect(response.error_message).to eq('Your card was declined.')
          end
        end
      end
    end

    describe StripeWrapper::Subscription do
      it 'creates a subscription with a valid customer and card' do
        VCR.use_cassette('does create a subscription') do
          alice = Fabricate(:user)
          valid_token = Stripe::Token.create({
            card: {
              number: '4242424242424242',
              exp_month: 6,
              exp_year: 2020,
              cvc: 314
            }
          }).id

          customer = StripeWrapper::Customer.create(
            user: alice,
            card: valid_token
          )
          subscription = StripeWrapper::Subscription.create(customer)
          expect(subscription.status).to eq('succeeded')
        end
      end

      it 'does not create a subscription with an invalid card' do
        VCR.use_cassette('does not create a subscription') do
          alice = Fabricate(:user)
          invalid_token = Stripe::Token.create({
            card: {
              number: '4000000000000002',
              exp_month: 6,
              exp_year: 2020,
              cvc: 314
            }
          }).id

          customer = StripeWrapper::Customer.create(
            user: alice,
            card: invalid_token
          )

          subscription = StripeWrapper::Subscription.create(customer)
          expect(subscription.status).to eq('requires_payment_method')
        end
      end
    end
  end
end
