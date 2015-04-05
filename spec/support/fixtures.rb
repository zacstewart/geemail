module Fixtures
  def fixture(name)
    File.read("spec/fixtures/#{name}.txt")
  end
end
