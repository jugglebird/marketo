require File.expand_path('authentication_header', File.dirname(__FILE__))

module Marketo
    
  def self.new_client(access_key, secret_key, api_version = '2.0', endpoint = "https://na-q.marketo.com/soap/mktows/2_0")

    api_version = api_version.sub(".", "_")
    client = Savon::Client.new do
      wsdl.endpoint     = endpoint
      wsdl.document     = "http://app.marketo.com/soap/mktows/#{api_version}?WSDL"
      http.auth.ssl.verify_mode = :none
      http.read_timeout = 300
      http.open_timeout = 300
      http.headers      = { "Connection" => "Keep-Alive",
                            "Pragma" => "no-cache" }
    end

    Client.new(client, Marketo::AuthenticationHeader.new(access_key, secret_key))
  end

  # = The client for talking to marketo
  # based on the SOAP wsdl file: <i>http://app.marketo.com/soap/mktows/1_4?WSDL</i>
  #
  # Usage:
  #
  # client = Marketo.new_client(<access_key>, <secret_key>)
  #
  # == get_lead_by_email:
  #
  # lead_record = client.get_lead_by_email('sombody@examnple.com')
  #
  # puts lead_record.idnum
  #
  # puts lead_record.get_attribute('FirstName')
  #
  # puts lead_record.get_attribute('LastName')
  #
  # == sync_lead: (update)
  #
  # lead_record = client.sync_lead('example@rapleaf.com', 'Joe', 'Smith', 'Company 1', '415 911')
  #
  # == sync_lead_record: (update with custom fields)
  #
  # lead_record = Marketo::LeadRecord.new('harry@rapleaf.com')
  #
  # lead_record.set_attribute('FirstName', 'harry')
  #
  # lead_record.set_attribute('LastName', 'smith')
  #
  # lead_record.set_attribute('Email', 'harry@somesite.com')
  #
  # lead_record.set_attribute('Company', 'Rapleaf')
  #
  # lead_record.set_attribute('MobilePhone', '123 456')
  #
  # response = client.sync_lead_record(lead_record)
  class Client
    # This constructor is used internally, create your client with *Marketo.new_client(<access_key>, <secret_key>)*
    def initialize(savon_client, authentication_header)
      @client = savon_client
      @header = authentication_header
    end

    public

    def get_lead_by(name, id=nil)
      #name can be email, cookie, idnum... 
      klass = LeadKeyType.const_get(name.to_s.upcase)
      get_lead(LeadKey.new(klass, id))
    end

    def get_lead_by_idnum(idnum)
      get_lead_by(:idnum, idnum)
    end

    def get_lead_by_email(email)
      get_lead_by(:email, email)
    end

    def get_leads(options = {})
      begin
        @logger.debug "#get_leads(#{options})" if @logger
        response = send_request("ns1:paramsGetMultipleLeads", options)
        leads = []

        return leads if response[:success_get_multiple_leads][:result][:return_count] == '0'

        response[:success_get_multiple_leads][:result][:lead_record_list][:lead_record].each do |savon_hash|
          leads << LeadRecord.from_hash(savon_hash)
        end
        return leads
      rescue => e
        @logger.warn(e) if @logger
        raise e
      end
    end

    def get_lead_changes(options = {})
      begin
        @logger.debug "#get_leads(#{options})" if @logger
        response = send_request("ns1:paramsGetLeadChanges", options)
        leads = []

        return leads if response[:success_get_lead_changes][:result][:return_count] == '0'

        response[:success_get_lead_changes][:result][:lead_change_record_list][:lead_change_record].each do |savon_hash|
          leads << LeadChangeRecord.from_hash(savon_hash)
        end
        return leads
      rescue => e
        @logger.warn(e) if @logger
        raise e
      end
    end


    def set_logger(logger)
      @logger = logger
    end

    # create (if new) or update (if existing) a lead
    #
    # * email - email address of lead
    # * first - first name of lead
    # * last - surname/last name of lead
    # * company - company the lead is associated with
    # * mobile - mobile/cell phone number
    #
    # returns the LeadRecord instance on success otherwise nil
    def sync_lead(email, first, last, company, mobile, cookie=nil)
      lead_record = LeadRecord.new(email)
      lead_record.set_attribute('FirstName', first)
      lead_record.set_attribute('LastName', last)
      lead_record.set_attribute('Email', email)
      lead_record.set_attribute('Company', company)
      lead_record.set_attribute('MobilePhone', mobile)
      if cookie
        sync_lead_record_on_cookie(lead_record, cookie)
      else
        sync_lead_record(lead_record)
      end
    end

    def sync_lead_record(lead_record)
      begin
        attributes = []
        lead_record.each_attribute_pair do |name, value|
          attributes << {:attr_name => name, :attr_type => 'string', :attr_value => value}
        end

        response = send_request("ns1:paramsSyncLead", {
            :return_lead => true,
            :lead_record =>
                {:email               => lead_record.email,
                 :lead_attribute_list => {
                     :attribute => attributes}}})
        return LeadRecord.from_hash(response[:success_sync_lead][:result][:lead_record])
      rescue  => e
        @logger.warn(e) if @logger
        return nil
      end
    end

    def sync_lead_record_on_cookie(lead_record, cookie=nil)
      return sync_lead_record(lead_record) if cookie.nil?
      begin
        attributes = []
        lead_record.each_attribute_pair do |name, value|
          attributes << {:attr_name => name, :attr_type => 'string', :attr_value => value}
        end
        # attributes << {:attr_name => "MarketoCookie", :attr_type => 'string', :attr_value => cookie}

        response = send_request("ns1:paramsSyncLead", {
            :marketo_cookie => cookie,
            :return_lead => true,
            :lead_record =>
                {:email               => lead_record.email,
                 :lead_attribute_list => {:attribute => attributes}
                }})
        return LeadRecord.from_hash(response[:success_sync_lead][:result][:lead_record])
      rescue  => e
        @logger.warn(e) if @logger
        return nil
      end
    end
      
    def sync_multi_lead_records(lead_records)
      send_records = []
      begin
        lead_records.each do |lead_record|
          attributes = []
          lead_record.each_attribute_pair do |name, value|
            attributes << {:attr_name => name, :attr_type => 'string', :attr_value => value}
          end
            
          send_records << {:lead_record => 
            { "Email" => lead_record.email, 
              :lead_attribute_list => 
                { :attribute => attributes }
            }
          }
        end
          
        response = send_request("ns1:paramsSyncMultipleLeads", {
              :lead_record_list => send_records }) # an array of lead records
          
        return response
      rescue  => e
        @logger.warn(e) if @logger
        return @client.http
        #return nil
      end
    end

    def add_to_list(list_key, email)
      list_operation(list_key, ListOperationType::ADD_TO, email)
    end

    def remove_from_list(list_key, email)
      list_operation(list_key, ListOperationType::REMOVE_FROM, email)
    end

    def is_member_of_list?(list_key, email)
      list_operation(list_key, ListOperationType::IS_MEMBER_OF, email)
    end

    private

    def list_operation(list_key, list_operation_type, email)
      begin
        response = send_request("ns1:paramsListOperation", {
            :list_operation   => list_operation_type,
            :list_key         => list_key,
            :strict           => 'false',
            :list_member_list => {
                :lead_key => [
                    {:key_type => 'EMAIL', :key_value => email}
                ]
            }
        })
        return response
      rescue  => e
        @logger.warn(e) if @logger
        return nil
      end
    end

    def get_lead(lead_key)
      begin
        response = send_request("ns1:paramsGetLead", {:lead_key => lead_key.to_hash})
        lead_record = response[:success_get_lead][:result][:lead_record_list][:lead_record]

        # lead_record may be a hash or an array of hashes
        return LeadRecord.from_hash(lead_record) if lead_record.kind_of?(Hash)
          
        leads = []
        lead_record.each do |savon_hash|
          leads << LeadRecord.from_hash(savon_hash)
        end
        return leads
      rescue  => e
        @logger.warn(e) if @logger
        # raise e
        return nil
      end
    end

    def send_request(namespace, body)
      @header.set_time(DateTime.now)
      response = request(namespace, body, @header.to_hash)
      response.to_hash
    end

    def request(namespace, body, header)
      @client.request namespace do |soap|
        soap.namespaces["xmlns:ns1"]            = "http://www.marketo.com/mktows/"
        soap.body                               = body
        soap.header["ns1:AuthenticationHeader"] = header
      end
    end
  end
end
