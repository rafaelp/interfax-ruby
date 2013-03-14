# Ruby Gem for Interfax SOAP API

This is a ruby wrapper to send fax using [Interfax](http://www.interfax.net/)

API Reference: [Outbound Fax SOAP API](http://www.interfax.net/en/dev/webservice/reference)

## Install

    gem install interfax-ruby

### Usage

```ruby
require 'interfax'

interfax = Interfax.new(username: 'myuser', password: 'mypassword')
source_path = "/tmp/myfile.pdf"
if interfax.upload_file_chunk(source_path)
  result = interfax.sendfax_ex_2(
    fax_numbers: '+55-21-99999999',
    postpone: '2000-01-01T10:00:00.000000-03:00',
    retries_to_perform: 1,
    csid: 'YOURAPP',
    page_header: '{Datedd/MM/yy} {TimeHHmmss} - https://www.webfax.me',
    subject: "whatever",
  )
  if result > 0
    puts "Success :)"
  else
    puts "Error :("
  end
end

```

## Contributing
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## License

This code is released under the [MIT License](http://www.opensource.org/licenses/mit-license.php).

## Bugs, Issues, Thanks, etc

Comments and feedbacks are welcome through project's [issue tracker](http://github.com/rafaelp/interfax-ruby/issues)

## Author

[**Rafael Lima**](http://github.com/rafaelp) working for [BielSystems](http://bielsystems.com.br)

Blog: [http://rafael.adm.br](http://rafael.adm.br)

Twitter: [http://twitter.com/rafaelp](http://twitter.com/rafaelp)

### Did you like it?

[Recommend me on Working With Rails](http://workingwithrails.com/recommendation/new/person/14248-rafael-lima)