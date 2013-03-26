# Marketo

TODO: Write a gem description

## Setup

Create a config/marketo.yml file:
access_key: "bigcorp1_461839624B16E06BA2D663"
secret_key: "899756834129871744AAEE88DDCC77CDEEDEC1AAAD66"

Be sure to substitute your Marketo access_key and secret_key for the values above.

## Installation

Add this line to your application's Gemfile:

    gem 'marketo'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install marketo

## Usage

Create anew Marketo Client passing your access_key and secret_key from your marketo.yml file.
client = Marketo.new_client(access_key, secret_key)

To get a user

    client.get_lead_by(:id, "123456")
    client.get_lead_by(:email, "example@email.com")
    client.get_lead_by(:cookie, cookies["_mkto_trk"])

To sync a lead with Marketo. Use the client created above. Call sync_lead passing: email_address, the Marketo Cookie, and a hash of attributes.
The Marketo cookie: request.cookies["_mkto_trk"]
client.sync_lead(USER[:email], COOKIE, {"FirstName"=>USER[:first_name],
                                        "LastName"=>USER[:last_name],
                                        "Company"=>"Backupify"})

To add a lead to a Marketo List. Use the client created above. Call add_lead_to_list passing: the lead records IDNUM and the list name.
client.add_lead_to_list(IDNUM, "Inbound Signups")

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


## Current Contributors
