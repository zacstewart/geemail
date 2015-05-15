require 'base64'
require 'geemail'
require 'mail'
require 'spec_helper'
require 'webmock/rspec'

describe Geemail::Client do
  let(:token) { 'a_token' }
  subject(:client) { described_class.new(token) }

  let!(:create_label_request) do
    stub_request(
      :post,
      'https://www.googleapis.com/gmail/v1/users/me/labels?access_token=a_token',
    ).to_return(fixture('label-create'))
  end

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

  let!(:list_labels_request) do
    stub_request(
      :get,
      'https://www.googleapis.com/gmail/v1/users/me/labels?access_token=a_token'
    ).to_return(fixture('labels-list'))
  end

  let!(:modify_message_request) do
    stub_request(
      :post,
      /https:\/\/www.googleapis.com\/gmail\/v1\/users\/me\/messages\/\h+\/modify\?access_token=a_token/
    )
  end

  let!(:send_email_request) do
    stub_request(
      :post,
      'https://www.googleapis.com/upload/gmail/v1/users/me/messages/send?access_token=a_token&uploadType=media'
    )
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
      expect { |b| client.messages(&b) }.to yield_control.exactly(10).times
    end

    context 'when the messages response is empty' do
      let!(:list_request) do
        stub_request(
          :get,
          'https://www.googleapis.com/gmail/v1/users/me/messages?access_token=a_token&q='
        ).to_return(fixture('messages-empty'))
      end

      it 'yields no messages' do
        expect { |b| client.messages(&b) }.not_to yield_control
      end
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

  describe '#modify_message' do
    it 'finds the labels' do
      client.modify_message('14c86db7a27b8ff5', add_labels: ['Open Source'])
      expect(list_labels_request).to have_been_made
    end

    context 'with a pre-existing label' do
      it 'adds labels by id' do
        client.modify_message('14c86db7a27b8ff5', add_labels: ['Open Source'])
        expect(modify_message_request.with(
          body: {addLabelIds: ['Label_18'], removeLabelIds: []}
        )).to have_been_made
      end

      it 'removes labels by id' do
        client.modify_message('14c86db7a27b8ff5', remove_labels: ['Open Source'])
        expect(modify_message_request.with(
          body: {addLabelIds: [], removeLabelIds: ['Label_18']}
        )).to have_been_made
      end
    end

    context 'with a new label' do
      it 'creates the label' do
        client.modify_message('14c86db7a27b8ff5', add_labels: ['New Label'])

        expect(create_label_request.with(
          body: {name: 'New Label'}
        )).to have_been_made
      end

      it 'adds the new label by id' do
        client.modify_message('14c86db7a27b8ff5', add_labels: ['New Label'])

        expect(modify_message_request.with(
          body: {addLabelIds: ['Label_37'], removeLabelIds: []}
        )).to have_been_made
      end
    end
  end

  describe '#send_message' do
    let(:raw) { fixture('raw-email').read }

    it 'sends a raw email message' do
      client.send_message(raw)
      expect(send_email_request.with(body: raw)).to have_been_made
    end

    context 'in a particular thread' do
      xit 'sends a raw message with a thread id'
    end
  end
end
