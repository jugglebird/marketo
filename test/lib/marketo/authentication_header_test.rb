require_relative '../../test_helper'

module Marketo
  ACCESS_KEY = 'ACCESS_KEY'
  SECRET_KEY = 'SECRET_KEY'

  describe AuthenticationHeader do
    it "should set mktowsUserId to access key" do
      header = Marketo::AuthenticationHeader.new(ACCESS_KEY, SECRET_KEY)
      header.get_mktows_user_id.must_equal ACCESS_KEY
    end

    it "should set requestSignature" do
      header = Marketo::AuthenticationHeader.new(ACCESS_KEY, SECRET_KEY)
      header.get_request_signature.wont_be_nil
      header.get_request_signature.wont_equal ''
    end
  
    it "should set requestTimestamp in correct format" do
      header = Marketo::AuthenticationHeader.new(ACCESS_KEY, SECRET_KEY)
      time   = DateTime.new(1998, 1, 17, 20, 15, 1)
      header.set_time(time)
      header.get_request_timestamp().must_equal '1998-01-17T20:15:01+00:00'
    end
  
    it "should cope if no date is given" do
      header   = Marketo::AuthenticationHeader.new(ACCESS_KEY, SECRET_KEY)
      expected = DateTime.now
      actual   = DateTime.parse(header.get_request_timestamp)
  
      expected.year.must_equal actual.year
      expected.hour.must_equal actual.hour
    end
  
    # From the Marketo API docs
    it "should calculate encrypted signature" do
      access_key = 'bigcorp1_461839624B16E06BA2D663'
      secret_key = '899756834129871744AAEE88DDCC77CDEEDEC1AAAD66'
  
      header     = Marketo::AuthenticationHeader.new(access_key, secret_key)
      header.set_time(DateTime.new(2010, 4, 9, 14, 4, 55, -7/24.0))
  
      header.get_request_timestamp.must_equal '2010-04-09T14:04:55-07:00'
      header.get_request_signature.must_equal '22482bf9379da438ec9f4e274a38e96d5f2509d0'
    end
  
    # From the Marketo API docs
    it "should to_hash correctly" do
      access_key = 'bigcorp1_461839624B16E06BA2D663'
      secret_key = '899756834129871744AAEE88DDCC77CDEEDEC1AAAD66'
  
      header     = Marketo::AuthenticationHeader.new(access_key, secret_key)
      header.set_time(DateTime.new(2010, 4, 9, 14, 4, 55, -7/24.0))
      expected_hash = {
        'mktowsUserId'     => header.get_mktows_user_id,
        'requestSignature' => header.get_request_signature,
        'requestTimestamp' => header.get_request_timestamp
      }
  
      header.to_hash.must_equal expected_hash
    end

  end
end
