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
  end
end
