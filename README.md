
RSpec `match_result`
====================

Feed input to a block and match result against expected value

Overview
--------

```ruby
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
```

Full documentation is available at [rubydoc.info](http://www.rubydoc.info/github/dadooda/rspec_match_result/RSpec/MatchResult/Helpers).


Setup
-----

This project is a *sub*. Sub setup example is available [here](https://github.com/dadooda/subs#setup).

For more info on subs, click [here](https://github.com/dadooda/subs).


Cheers!
-------

&mdash; Alex Fortuna, &copy; 2015
