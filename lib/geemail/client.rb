require 'faraday'
require 'faraday_middleware'

module Geemail
  class Client
    def initialize(token, username: 'me')
      @username = username
      @connection = Faraday.new('https://www.googleapis.com/gmail/v1/users/me') do |conn|
        conn.request :oauth2, token
        conn.request :json
        conn.response :json, :content_type => /\bjson$/
        conn.adapter Faraday.default_adapter
      end
    end

    def messages(query: '')
      return enum_for(__method__, query: query) unless block_given?

      response = @connection.get('messages', q: query)
      raise Unauthorized if response.status == 401
      response.body.fetch('messages').lazy.each do |ref|
        yield get_message(ref.fetch('id'))
      end
    end

    def get_message(id)
      Message.new(@connection.get("messages/#{id}").body)
    end
  end

  Unauthorized = Class.new(StandardError)
end
