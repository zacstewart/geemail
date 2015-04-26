require 'base64'
require 'mail'
require 'delegate'

module Geemail
  class Message < SimpleDelegator
    attr_reader :id

    def self.create(from:, to:, subject:, body:, client: nil)
      mail = Mail.new
      mail.from = from
      mail.to = to
      mail.subject = subject
      mail.body = body
      new(mail, client: client)
    end

    def self.parse(representation, client: nil)
      id = representation.fetch('id')
      mail = Mail.new(Base64.urlsafe_decode64(representation.fetch('raw')))
      new(mail, id: id, client: client)
    end

    def initialize(mail, id: nil, client: nil)
      super mail
      @id = id
      @client = client
    end

    def add_labels(*labels)
      client.modify_message(id, add_labels: labels)
    end

    def deliver
      client.send_message(Base64.urlsafe_encode64(to_s))
    end

    private

    def client
      return @client unless @client.nil?

      calling_method = caller_locations(1,1).first.label
      raise ArgumentError, "#{calling_method} requires Message to have a Client"
    end
  end
end
