require 'geemail'
require 'json'
require 'spec_helper'
require 'webmock/rspec'

describe Geemail::Message do
  let(:client) { double('Client') }

  let(:id) { '14c86fb63bf4e4eb' }

  let(:mail) { Mail.new(representation.fetch('raw')) }

  let(:representation) do
    response = fixture('multi-part-html-message')
    response.gets("\r\n\r\n")
    JSON.parse(response.read)
  end

  subject(:message) { described_class.new(mail, id: id, client: client) }

  describe '::create' do
    subject(:message) do
      described_class.create(
        from: 'alice@example.com',
        to: 'bob@example.com',
        subject: 'Eve is up to it again',
        body: 'I caught her reading our emails'
      )
    end

    it 'creates a new Message from fields' do
      expect(message.from).to eq(['alice@example.com'])
      expect(message.to).to eq(['bob@example.com'])
      expect(message.subject).to eq('Eve is up to it again')
      expect(message.body).to eq('I caught her reading our emails')
    end
  end

  describe '::parse' do
    subject(:message) { described_class.parse(representation, client: client) }

    it 'parses a message representation from the Gmail API' do
      expect(message.id).to eq(id)
      expect(message.subject).to eq('This is a test email')
      expect(message.from).to eq(['zgstewart@gmail.com'])
      expect(message.to).to eq(['zgstewart@gmail.com'])
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

  describe '#deliver' do
    it 'tells the client to send the message' do
      expect(client).to receive(:send_message).with(mail.to_s)
      message.deliver
    end
  end

end
