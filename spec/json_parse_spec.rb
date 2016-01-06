
require "json"

require "rspec/match_result"

describe "JSON.parse" do
  it "generally works" do
    [
      ["", [JSON::ParserError, /two octets/]],
      ["xyz", [JSON::ParserError, /unexpected token/]],
      ['{"x":"y"}', {"x" => "y"}],
      ['{"ar":[1.2,3.4]}', {"ar" => [1.2, 3.4]}],
    ].each do |input, expected|
      match_result(input, expected) {JSON.parse(input)}
    end
  end
end
