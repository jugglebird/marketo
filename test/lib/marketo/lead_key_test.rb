require_relative '../../test_helper'

module Marketo

  describe LeadKeyType do
    it "should define the correct types" do
      LeadKeyType::IDNUM.must_equal 'IDNUM'
      LeadKeyType::COOKIE.must_equal 'COOKIE'
      LeadKeyType::EMAIL.must_equal 'EMAIL'
      LeadKeyType::LEADOWNEREMAIL.must_equal 'LEADOWNEREMAIL'
      LeadKeyType::SFDCACCOUNTID.must_equal 'SFDCACCOUNTID'
      LeadKeyType::SFDCCONTACTID.must_equal 'SFDCCONTACTID'
      LeadKeyType::SFDCLEADID.must_equal 'SFDCLEADID'
      LeadKeyType::SFDCLEADOWNERID.must_equal 'SFDCLEADOWNERID'
      LeadKeyType::SFDCOPPTYID.must_equal 'SFDCOPPTYID'
    end
  end

  describe LeadKey do
    it "should store type and value on construction" do
      value = 'a value'
      type = LeadKeyType::IDNUM
      lead_key = LeadKey.new(type, value)
      lead_key.key_type.must_equal type
      lead_key.key_value.must_equal value
    end

    it "should to_hash correctly" do
      value = 'a value'
      type = LeadKeyType::IDNUM
      lead_key = LeadKey.new(type, value)

      lead_key.to_hash.must_equal({
        :key_type => type,
        :key_value => value
      })
    end
  end

end
