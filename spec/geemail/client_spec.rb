require 'geemail'
require 'spec_helper'
require 'webmock/rspec'
require 'mail'

describe Geemail::Client do
  let(:token) { 'a_token' }
  subject(:client) { described_class.new(token) }

  let!(:list_request) do
    stub_request(
      :get,
      'https://www.googleapis.com/gmail/v1/users/me/messages?access_token=a_token&q='
    ).to_return(fixture('messages'))
  end

  let!(:get_request) do
    stub_request(
      :get,
      /https:\/\/www.googleapis.com\/gmail\/v1\/users\/me\/messages\/\h+\?access_token=a_token/
    ).to_return(fixture('multi-part-html-message'))
  end

  describe '#messages' do
    it 'is an enumerator' do
      expect(client.messages).to be_a(Enumerator)
    end

    it 'requests the messages list' do
      client.messages.first
      expect(list_request).to have_been_made
    end

    it 'requests each message lazily' do
      client.messages.take(2)
      expect(get_request).to have_been_made.times(2)
    end

    it 'passes the query string in the list request' do
      search_request = stub_request(
        :get,
        'https://www.googleapis.com/gmail/v1/users/me/messages?access_token=a_token&q=Geemail'
      ).to_return(fixture('messages'))
      client.messages(query: 'Geemail').first
      expect(search_request).to have_been_made
    end

    it 'yields the messages' do
      expect { |b| client.messages(&b) }.to yield_control.exactly(100).times
    end
  end

  describe '#get_message' do
    it 'requests the message' do
      client.get_message('14c86db7a27b8ff5')
      expect(get_request).to have_been_made
    end

    it 'returns a Message' do
      expect(client.get_message('14c86db7a27b8ff5')).to be_a(Geemail::Message)
    end
  end
end
