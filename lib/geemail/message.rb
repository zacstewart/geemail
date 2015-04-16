require 'base64'
require 'mail'
require 'delegate'

module Geemail
  class Message < SimpleDelegator
    attr_reader :id

    def self.parse(representation, client: nil)
      new(representation, client: client)
    end

    def initialize(representation, client: nil)
      @id = representation.fetch('id')
      @client = client
      mail = Mail.new(Base64.urlsafe_decode64(representation.fetch('raw')))
      super mail
    end

    def add_labels(*labels)
      unless client
        raise ArgumentError, "#{__method__} require Message to have a Client"
      end

      client.modify_message(id, add_labels: labels)
    end

    private

    attr_reader :client
  end
end
