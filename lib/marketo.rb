require 'savon'

Savon.configure do |config|
  # config.log = true            # disable logging
  # config.log_level = :info      # changing the log level
  # config.logger = Rails.logger  # using the Rails logger
  config.pretty_print_xml = true
end

require "marketo/client"
require "marketo/authentication_header"
require "marketo/enums"
require "marketo/lead_change_record"
require "marketo/lead_key"
require "marketo/lead_record"
require "marketo/version"

module Marketo
  # Your code goes here...
end
