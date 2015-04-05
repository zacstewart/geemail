module Geemail
  class Message
    attr_reader :id, :subject, :from, :body

    def initialize(representation)
      @id = representation.fetch('id')
      @representation = representation
    end

    def subject
      header = @representation.
        fetch('payload').
        fetch('headers').
        find { |h| h['name'] == 'Subject' } and
        header.fetch('value')
    rescue KeyError
      ''
    end

    def from
      header = @representation.
        fetch('payload').
        fetch('headers').
        find { |h| h['name'] == 'From' } and
        header.fetch('value')
    rescue KeyError
      ''
    end

    def body
      @representation.
        fetch('payload').
        fetch('body')
    rescue KeyError
      ''
    end
  end
end
