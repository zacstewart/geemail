require 'geemail'
require 'json'
require 'spec_helper'
require 'webmock/rspec'

describe Geemail::Message do
  let(:representation) do
    response = fixture('multi-part-html-message')
    response.gets("\r\n\r\n")
    JSON.parse(response.read)
  end

  subject(:message) { described_class.new(representation) }

  describe '#subject' do
    specify { expect(message.subject).to eq('This is a test email') }
  end

  describe '#from' do
    specify { expect(message.from).to eq('Zac Stewart <zgstewart@gmail.com>') }
  end

  describe '#to' do
    specify { expect(message.to).to eq('"zgstewart@gmail.com" <zgstewart@gmail.com>') }
  end

  describe '#body' do
    it 'is the text of the email body' do
      expect(message.body).to eq(
        'Hi there. This is a test email for creating a fixture. Enjoy Geemail!')
    end
  end

end
