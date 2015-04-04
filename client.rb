require 'faraday'

module Gmail
  class Client
    def initialize(token, username: 'me')
      @username = username
      @connection = Faraday.new('https://www.googleapis.com/gmail/v1/users/me') do |conn|
        conn.request :oauth2, token
        conn.request :json
        conn.response :json, :content_type => /\bjson$/
        conn.use :instrumentation
        conn.adapter Faraday.default_adapter
      end
    end

    def messages(query: '')
      return enum_for(__method__) unless block_given?

      response = @connection.get('messages', q: query)
      response.body.fetch('messages').lazy.each do |ref|
        yield Message.new(@connection.get("messages/#{ref['id']}").body)
      end
    end
  end
end
