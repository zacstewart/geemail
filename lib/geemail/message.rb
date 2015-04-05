require 'base64'

module Geemail
  class Message
    attr_reader :id, :subject, :from, :body

    def initialize(representation)
      @id = representation.fetch('id')
      @representation = representation
    end

    def body
      body = payload.fetch('body')
      if body.fetch('size') > 0
        Base64.decode64(body.fetch('data'))
      else
        part = payload.fetch('parts').find { |p| p['mimeType'] == 'text/plain' }
        Base64.decode64(part.fetch('body').fetch('data'))
      end.chomp
    end

    def from
      headers.fetch('From')
    end

    def headers
      @headers ||= payload.
        fetch('headers').
        map { |h| [h['name'], h['value']] }.
        to_h
    end

    def subject
      headers.fetch('Subject')
    end

    def to
      headers.fetch('To')
    end

    private

    def payload
      @representation.fetch('payload')
    end
  end
end
