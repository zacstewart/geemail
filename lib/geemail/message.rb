require 'base64'
require 'mail'

module Geemail
  class Message
    def self.parse(representation)
      raw = Base64.urlsafe_decode64(representation.fetch('raw'))
      Mail.new(raw)
    end
  end
end
