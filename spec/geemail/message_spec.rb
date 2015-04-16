require 'geemail'
require 'json'
require 'spec_helper'
require 'webmock/rspec'

describe Geemail::Message do
  let(:client) { double('Client') }

  let(:id) { '14c86fb63bf4e4eb' }

  let(:representation) do
    response = fixture('multi-part-html-message')
    response.gets("\r\n\r\n")
    JSON.parse(response.read)
  end

  subject(:message) { described_class.parse(representation, client: client) }

  describe '#id' do
    specify { expect(message.id).to eq(id) }
  end

  describe '#subject' do
    specify { expect(message.subject).to eq('This is a test email') }
  end

  describe '#from' do
    specify { expect(message.from).to eq(['zgstewart@gmail.com']) }
  end

  describe '#to' do
    specify { expect(message.to).to eq(['zgstewart@gmail.com']) }
  end

  describe '#body' do
    it 'is the text of the email body' do
      expect(message.body).to match(
        'Hi there. This is a test email for creating a fixture. Enjoy Geemail!')
    end
  end

  describe '#add_labels' do
    it 'tells the client to add the label to the message' do
      expect(client).to receive(:modify_message).with(
        id, add_labels: ['Open Source'])
      message.add_labels('Open Source')
    end
  end

end
