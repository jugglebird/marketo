require_relative '../../test_helper'

module Marketo
  describe LeadRecord do
    EMAIL = 'some@email.com'
    IDNUM    = 93480938

    it "should store the idnum" do
      lead_record = LeadRecord.new(EMAIL, IDNUM)
      lead_record.idnum.must_equal IDNUM
    end

    it "should store the email" do
      LeadRecord.new(EMAIL, IDNUM).email.must_equal EMAIL
    end

    it "should implement == sensibly" do
      lead_record1 = LeadRecord.new(EMAIL, IDNUM)
      lead_record1.set_attribute('favourite color', 'red')
      lead_record1.set_attribute('age', '100')

      lead_record2 = LeadRecord.new(EMAIL, IDNUM)
      lead_record2.set_attribute('favourite color', 'red')
      lead_record2.set_attribute('age', '100')

      lead_record1.must_equal lead_record2
    end

    it "should store when attributes are set" do
      lead_record = LeadRecord.new(EMAIL, IDNUM)
      lead_record.set_attribute('favourite color', 'red')
      lead_record.get_attribute('favourite color').must_equal 'red'
    end

    it "should store when attributes are updated" do
      lead_record = LeadRecord.new(EMAIL, IDNUM)
      lead_record.set_attribute('favourite color', 'red')
      lead_record.set_attribute('favourite color', 'green')
      lead_record.get_attribute('favourite color').must_equal 'green'
    end

    it "should yield all attributes through each_attribute_pair" do
      lead_record = LeadRecord.new(EMAIL, IDNUM)
      lead_record.set_attribute('favourite color', 'red')
      lead_record.set_attribute('favourite color', 'green')
      lead_record.set_attribute('age', '99')

      pairs       = []
      lead_record.each_attribute_pair do |attribute_name, attribute_value|
        pairs << [attribute_name, attribute_value]
      end

      pairs.size.must_equal 3
      pairs.must_include(['favourite color', 'green'])
      pairs.must_include(['age', '99'])
      pairs.must_include(['Email', EMAIL])
    end

    it "should be instantiable from a savon hash" do
      savon_hash = {
          :email => EMAIL,
          :foreign_sys_type => nil,
          :lead_attribute_list => {
              :attribute => [
                { :attr_name => 'Company', :attr_type => 'string', :attr_value => 'Rapleaf'},
                { :attr_name => 'FirstName', :attr_type => 'string', :attr_value => 'James'},
                { :attr_name => 'LastName', :attr_type => 'string', :attr_value => 'O\'Brien'}
              ]
          },
          :foreign_sys_person_id => nil,
          :id => IDNUM
      }

      actual = LeadRecord.from_hash(savon_hash)

      expected = LeadRecord.new(EMAIL, IDNUM)
      expected.set_attribute('Company', 'Rapleaf')
      expected.set_attribute('FirstName', 'James')
      expected.set_attribute('LastName', 'O\'Brien')

      actual.must_equal expected
    end

  end
end
