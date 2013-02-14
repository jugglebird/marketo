require_relative '../../test_helper'

module Marketo
  describe Client do
    include Mocha::Integration::MiniTest

    EMAIL   = "some@email.com"
    IDNUM   = 29
    FIRST   = 'Joe'
    LAST    = 'Smith'
    COMPANY = 'Rapleaf'
    MOBILE  = '415 123 456'
    API_KEY = 'API123KEY'

    describe 'Exception handling' do
      before do
        savon_client = mock('savon_client')
        savon_client.expects(:request).raises("Failed request")
        authentication_header = mock('authentication_header')
        authentication_header.expects(:set_time).returns([])
        authentication_header.expects(:to_hash).returns({})
        @client = Marketo::Client.new(savon_client, authentication_header)      
      end

      it "should return nil if any exception is raised on get_lead request" do
        @client.get_lead_by_email(EMAIL).must_be_nil
      end

      it "should return nil if any exception is raised on sync_lead request" do
        @client.sync_lead(EMAIL, FIRST, LAST, COMPANY, MOBILE).must_be_nil
      end
    end

    describe 'Client interaction' do
      before do
        @savon_client = mock('savon_client')
        @authentication_header = mock('authentication_header')
        @client = Marketo::Client.new(@savon_client, @authentication_header)
      end

      it "should have the correct body format on get_lead_by_idnum" do
        response_hash         = {
            :success_get_lead => {
                :result => {
                    :count            => 1,
                    :lead_record_list => {
                        :lead_record => {
                            :email                 => EMAIL,
                            :lead_attribute_list   => {
                                :attribute => [
                                    {:attr_name => 'name1', :attr_type => 'string', :attr_value => 'val1'},
                                    {:attr_name => 'name2', :attr_type => 'string', :attr_value => 'val2'},
                                    {:attr_name => 'name3', :attr_type => 'string', :attr_value => 'val3'},
                                    {:attr_name => 'name4', :attr_type => 'string', :attr_value => 'val4'}
                                ]
                            },
                            :foreign_sys_type      => nil,
                            :foreign_sys_person_id => nil,
                            :id                    => IDNUM.to_s
                        }
                    }
                }
            }
        }
        expect_request(@savon_client,
                       @authentication_header,
                       equals_matcher(:lead_key => {
                           :key_value => IDNUM,
                           :key_type  => LeadKeyType::IDNUM
                       }),
                       'ns1:paramsGetLead',
                       response_hash)

        @client.get_lead_by_idnum(IDNUM).must_equal expected_lead_record(EMAIL, IDNUM)
      end

      it "should have the correct body format on get_lead_by_email" do
        response_hash         = {
            :success_get_lead => {
                :result => {
                    :count            => 1,
                    :lead_record_list => {
                        :lead_record => {
                            :email                 => EMAIL,
                            :lead_attribute_list   => {
                                :attribute => [
                                    {:attr_name => 'name1', :attr_type => 'string', :attr_value => 'val1'},
                                    {:attr_name => 'name2', :attr_type => 'string', :attr_value => 'val2'},
                                    {:attr_name => 'name3', :attr_type => 'string', :attr_value => 'val3'},
                                    {:attr_name => 'name4', :attr_type => 'string', :attr_value => 'val4'}
                                ]
                            },
                            :foreign_sys_type      => nil,
                            :foreign_sys_person_id => nil,
                            :id                    => IDNUM.to_s
                        }
                    }
                }
            }
        }
        expect_request(@savon_client,
                       @authentication_header,
                       equals_matcher({:lead_key => {
                           :key_value => EMAIL,
                           :key_type  => LeadKeyType::EMAIL}}),
                       'ns1:paramsGetLead',
                       response_hash)

        @client.get_lead_by_email(EMAIL).must_equal expected_lead_record(EMAIL, IDNUM)
      end

    
      it "should have the correct body format on sync_lead_record" do
        response_hash         = {
            :success_sync_lead => {
                :result => {
                    :lead_id     => IDNUM,
                    :sync_status => {
                        :error   => nil,
                        :status  => 'UPDATED',
                        :lead_id => IDNUM
                    },
                    :lead_record => {
                        :email                 => EMAIL,
                        :lead_attribute_list   => {
                            :attribute => [
                                {:attr_name => 'name1', :attr_type => 'string', :attr_value => 'val1'},
                                {:attr_name => 'name2', :attr_type => 'string', :attr_value => 'val2'},
                                {:attr_name => 'name3', :attr_type => 'string', :attr_value => 'val3'},
                                {:attr_name => 'name4', :attr_type => 'string', :attr_value => 'val4'}
                            ]
                        },
                        :foreign_sys_type      => nil,
                        :foreign_sys_person_id => nil,
                        :id                    => IDNUM.to_s
                    }
                }
            }
        }
        expect_request(@savon_client,
                       @authentication_header,
                       equals_matcher({
                                          :return_lead => true,
                                          :lead_record => {
                                              :email               => EMAIL,
                                              :lead_attribute_list =>
                                                  {
                                                      :attribute => [
                                                          {:attr_value => "val1",
                                                           :attr_name  => "name1",
                                                           :attr_type  => "string"},
                                                          {:attr_value => "val2",
                                                           :attr_name  => "name2",
                                                           :attr_type  => "string"},
                                                          {:attr_value => EMAIL,
                                                           :attr_name  => "Email",
                                                           :attr_type  => "string"}
                                                      ]}}}),
                       'ns1:paramsSyncLead',
                       response_hash)
        lead_record = LeadRecord.new(EMAIL)
        lead_record.set_attribute('name1', 'val1')
        lead_record.set_attribute('name2', 'val2')
    
        @client.sync_lead_record(lead_record).must_equal expected_lead_record(EMAIL, IDNUM)
      end
    
      it "should have the correct body format on sync_lead" do
        response_hash         = {
            :success_sync_lead => {
                :result => {
                    :lead_id     => IDNUM,
                    :sync_status => {
                        :error   => nil,
                        :status  => 'UPDATED',
                        :lead_id => IDNUM
                    },
                    :lead_record => {
                        :email                 => EMAIL,
                        :lead_attribute_list   => {
                            :attribute => [
                                {:attr_name => 'name1', :attr_type => 'string', :attr_value => 'val1'},
                                {:attr_name => 'name2', :attr_type => 'string', :attr_value => 'val2'},
                                {:attr_name => 'name3', :attr_type => 'string', :attr_value => 'val3'},
                                {:attr_name => 'name4', :attr_type => 'string', :attr_value => 'val4'}
                            ]
                        },
                        :foreign_sys_type      => nil,
                        :foreign_sys_person_id => nil,
                        :id                    => IDNUM.to_s
                    }
                }
            }
        }
    
        expect_request(@savon_client,
                       @authentication_header,
                       Proc.new { |actual|
                         actual_attribute_list                                  = actual[:lead_record][:lead_attribute_list][:attribute]
                         actual[:lead_record][:lead_attribute_list][:attribute] = nil
                         expected                                               = {
                             :return_lead => true,
                             :lead_record => {
                                 :email               => "some@email.com",
                                 :lead_attribute_list =>
                                     {
                                         :attribute => nil}}
                         }
                         actual.must_equal expected
                         actual_attribute_list.should =~ [
                             {:attr_value => FIRST,
                              :attr_name  => "FirstName",
                              :attr_type  => "string"},
                             {:attr_value => LAST,
                              :attr_name  => "LastName",
                              :attr_type  => "string"},
                             {:attr_value => EMAIL,
                              :attr_name  =>"Email",
                              :attr_type  => "string"},
                             {:attr_value => COMPANY,
                              :attr_name  => "Company",
                              :attr_type  => "string"},
                             {:attr_value => MOBILE,
                              :attr_name  => "MobilePhone",
                              :attr_type  => "string"}
                         ]
                       },
                       'ns1:paramsSyncLead',
                       response_hash)

        @client.sync_lead(EMAIL, FIRST, LAST, COMPANY, MOBILE).must_equal expected_lead_record(EMAIL, IDNUM)
      end
    end
    
    describe "List operations" do
      LIST_KEY = 'awesome leads list'

      before do
        @savon_client = mock('savon_client')
        @authentication_header = mock('authentication_header')
        @client = Marketo::Client.new(@savon_client, @authentication_header)
      end

      it "should have the correct body format on add_to_list" do
        response_hash = {} # TODO
        expect_request(@savon_client,
                       @authentication_header,
                       equals_matcher({
                                          :list_operation   => ListOperationType::ADD_TO,
                                          :list_key         => LIST_KEY,
                                          :strict           => 'false',
                                          :list_member_list => {
                                              :lead_key => [
                                                  {
                                                      :key_type  => 'EMAIL',
                                                      :key_value => EMAIL
                                                  }
                                              ]
                                          }
                                      }),
                       'ns1:paramsListOperation',
                       response_hash)
    
        @client.add_to_list(LIST_KEY, EMAIL).must_equal response_hash
      end

      it "should have the correct body format on remove_from_list" do
        response_hash = {} # TODO
        expect_request(@savon_client,
                       @authentication_header,
                       equals_matcher({
                                          :list_operation   => ListOperationType::REMOVE_FROM,
                                          :list_key         => LIST_KEY,
                                          :strict           => 'false',
                                          :list_member_list => {
                                              :lead_key => [
                                                  {
                                                      :key_type  => 'EMAIL',
                                                      :key_value => EMAIL
                                                  }
                                              ]
                                          }
                                      }),
                       'ns1:paramsListOperation',
                       response_hash)
    
        @client.remove_from_list(LIST_KEY, EMAIL).must_equal response_hash
      end

      it "should have the correct body format on is_member_of_list?" do
        response_hash = {} # TODO
        expect_request(@savon_client,
                       @authentication_header,
                       equals_matcher({
                                          :list_operation   => ListOperationType::IS_MEMBER_OF,
                                          :list_key         => LIST_KEY,
                                          :strict           => 'false',
                                          :list_member_list => {
                                              :lead_key => [
                                                  {
                                                      :key_type  => 'EMAIL',
                                                      :key_value => EMAIL
                                                  }
                                              ]
                                          }
                                      }),
                       'ns1:paramsListOperation',
                       response_hash)
    
        @client.is_member_of_list?(LIST_KEY, EMAIL).must_equal response_hash
      end

    end

    private

    def basic_client
      savon_client = mock('savon_client')
      authentication_header = mock('authentication_header')
      return Marketo::Client.new(savon_client, authentication_header)
    end

    def client_with_failed_request
      savon_client = mock('savon_client')
      savon_client.expects(:request).raises("Failed request")
      authentication_header = mock('authentication_header')
      authentication_header.expects(:set_time).returns([])
      authentication_header.expects(:to_hash).returns({})
      return Marketo::Client.new(savon_client, authentication_header)      
    end

    def expected_lead_record(email, id)
      lead_record = LeadRecord.new(email, id)
      lead_record.set_attribute('name1', 'val1')
      lead_record.set_attribute('name2', 'val2')
      lead_record.set_attribute('name3', 'val3')
      lead_record.set_attribute('name4', 'val4')
      return lead_record
    end

    def equals_matcher(expected)
      Proc.new { |actual|
        actual.must_equal expected
      }
    end

    def expect_request(savon_client, authentication_header, expected_body_matcher, expected_namespace, response_hash)
      header_hash       = stub('header_hash')
      soap_response     = stub('soap_response')
      request_namespace = mock('namespace')
      request_header    = mock('request_header')
      soap_request      = mock('soap_request')
      authentication_header.expects(:set_time)
      authentication_header.expects(:to_hash).returns(header_hash)
      request_namespace.expects(:[]=).with("xmlns:ns1", "http://www.marketo.com/mktows/")
      request_header.expects(:[]=).with("ns1:AuthenticationHeader", header_hash)
      soap_request.expects(:namespaces).returns(request_namespace)
      soap_request.expects(:header).returns(request_header)
      soap_request.expects(:body=) do |actual_body|
        expected_body_matcher.call(actual_body)
      end
      soap_response.expects(:to_hash).returns(response_hash)
      savon_client.expects(:request).with(expected_namespace).yields(soap_request).returns(soap_response)
    end
  end

end
