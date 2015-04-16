# Geemail

[![Build Status](https://travis-ci.org/zacstewart/geemail.svg?branch=master)](https://travis-ci.org/zacstewart/geemail)

A gem for using [Google's Gmail REST API][gmail-rest-api].

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'geemail'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install geemail

## Usage

Very early, so probably not useful yet:

```ruby
client = Geemail::Client.new('my_oauth2_access_token')
client.messages(query: 'tacos').each do |message|
  # do something with message
end
```

## Development

### Recording an HTTP response fixture

Get an access token and supply it to cURL:

    $ curl -i -H "Authorization: Bearer A_VALID_ACCESS_TOKEN" https://www.googleapis.com/gmail/v1/users/me/labels

## Contributing

1. Fork it ( https://github.com/zacstewart/geemail/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

[gmail-rest-api]: https://developers.google.com/gmail/api/
