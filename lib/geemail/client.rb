require 'faraday'
require 'faraday_middleware'
require 'json'
require 'mail'

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

    def create_label(name)
      Label.parse(@connection.post('labels', name: name).body)
    end

    def labels
      return enum_for(__method__) unless block_given?

      response = @connection.get('labels')
      response.body.fetch('labels').each do |label|
        yield Label.parse(label)
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
      Message.parse(@connection.get("messages/#{id}", format: 'RAW').body, client: self)
    end

    def modify_message(id, add_labels: [], remove_labels: [])
      all_labels = labels.to_a

      new_labels = add_labels - all_labels.map(&:name)
      new_label_ids = new_labels.map { |label| create_label(label).id }

      add_label_ids = all_labels.
        select { |l| add_labels.include?(l.name) }.
        map(&:id)

      remove_label_ids = all_labels.
        select { |l| remove_labels.include?(l.name) }.
        map(&:id)

      @connection.post(
        "messages/#{id}/modify",
        'addLabelIds' => (add_label_ids + new_label_ids),
        'removeLabelIds' => remove_label_ids
      )
    end

    def send_message(raw, thread_id: nil)
      body = {'raw' => raw}
      body['threadId'] = thread_id if thread_id
      @connection.post do |request|
        request.url 'https://www.googleapis.com/upload/gmail/v1/users/me/messages/send?uploadType=media'
        request.headers['Content-Type'] = 'message/rfc822'
        request.body = JSON.generate(body)
      end
    end
  end

  Unauthorized = Class.new(StandardError)
end
