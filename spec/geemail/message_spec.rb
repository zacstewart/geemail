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

  subject(:message) { described_class.parse(representation) }

  describe '#id' do
    specify { expect(message.id).to eq('14c86fb63bf4e4eb') }
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

end
