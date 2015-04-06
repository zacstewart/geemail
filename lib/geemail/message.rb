require 'base64'
require 'mail'
require 'delegate'

module Geemail
  class Message < SimpleDelegator
    attr_reader :id

    def self.parse(representation)
      new(representation)
    end

    def initialize(representation)
      @id = representation.fetch('id')
      mail = Mail.new(Base64.urlsafe_decode64(representation.fetch('raw')))
      super mail
    end
  end
end
