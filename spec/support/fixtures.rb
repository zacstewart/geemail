module Fixtures
  def fixture(name)
    File.open("spec/fixtures/#{name}.txt")
  end
end
