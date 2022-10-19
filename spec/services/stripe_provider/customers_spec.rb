require 'rails_helper'

RSpec.describe StripeProvider::Customers do
  describe 'create_csv_list' do
    subject { StripeProvider::Customers.new }
    context 'stripe returns a customer list and the csv is successfully created' do
      before do
        mock_stripe_customers_list

        allow(File).to receive(:exist?).and_return(false)
        allow(File).to receive(:write).and_return(98)
      end

      it 'creates file and returns number of caracters' do
        expect(subject.create_csv).to eql 98
      end
    end

    context 'stripe returns Stripe::RateLimitError 2 times and after 2nd retry the
      customer list was received and csv was successfully created' do

      before do
        allow(File).to receive(:exist?).and_return(false)
        allow(File).to receive(:write).and_return(107)
        allow(Stripe::Customer).to receive(:list).and_raise(Stripe::RateLimitError)
        allow(Stripe::Customer).to receive(:list).and_raise(Stripe::RateLimitError)
        allow(Stripe::Customer).to receive(:list).and_return(Stripe::ListObject.construct_from(
          data: [
            { id: 'id1', email: 'id1@email.com', name: '', currency: 'EUR' },
            { id: 'id2', email: 'id2@email.com', name: '', currency: 'EUR' },
            { id: 'id3', email: 'id3@email.com', name: '', currency: 'EUR' },
          ],
          has_more: false,
          url: '/v1/customers'
        ))
      end

      it 'creates file and returns number of caracters' do
        expect(subject.create_csv).to eql 107
      end
    end

    context 'stripe returns Stripe::RateLimitError, after 3 attempts
      false is returned and csv is not created'do

      before do
        allow(Stripe::Customer).to receive(:list).and_raise(Stripe::RateLimitError)
      end

      it 'returns false' do
        expect(subject.create_csv).to eql false
      end
    end

    context 'the file was not created with all the data so the last id will be sent and
      rest of the customers will be returned and added to the existing file' do
      let(:file) { double }
      before do
        allow(File).to receive(:exist?).and_return(true)
        allow(CSV).to receive(:read).and_return(file)
        allow(file).to receive(:last).and_return('id2')
        allow(File).to receive(:write).and_return(25)
        allow(Stripe::Customer).to receive(:list).and_return(Stripe::ListObject.construct_from(
          data: [
            { id: 'id3', email: 'id3@email.com', name: '', currency: 'EUR' },
          ],
          has_more: false,
          url: '/v1/customers'
        ))
      end

      it 'creates file and returns number of caracters' do
        expect(subject.create_csv).to eql 25
      end
    end

    context 'the file exists and it is replaced with new file' do
      let(:file) { double }
      before do
        allow(File).to receive(:exist?).and_return(true)
        allow(CSV).to receive(:read).and_return(file)
        allow(file).to receive(:last).and_return('id2')
        allow(File).to receive(:write).and_return(107)
        allow(Stripe::Customer).to receive(:list).and_return(Stripe::ListObject.construct_from(
          data: [
          ],
          has_more: false,
          url: '/v1/customers'
        ))
        allow(Stripe::Customer).to receive(:list).and_return(Stripe::ListObject.construct_from(
          data: [
            { id: 'id1', email: 'id1@email.com', name: '', currency: 'EUR' },
            { id: 'id2', email: 'id2@email.com', name: '', currency: 'EUR' },
            { id: 'id3', email: 'id3@email.com', name: '', currency: 'EUR' },
          ],
          has_more: false,
          url: '/v1/customers'
        ))
      end

      it 'creates file and returns number of caracters' do
        expect(subject.create_csv).to eql 107
      end
    end
  end
end
