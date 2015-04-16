module Geemail
  class Label
    attr_reader :id, :name

    def self.parse(representation)
      new(representation)
    end

    def initialize(representation)
      @id = representation.fetch('id')
      @name = representation.fetch('name')
    end
  end
end
