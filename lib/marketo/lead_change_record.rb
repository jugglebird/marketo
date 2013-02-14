module Marketo
  # Represents a record of the data known about a lead within marketo
  class LeadChangeRecord
    attr_reader :idnum, :person_idnum, :attributes, :activity_type, :activity_date_time, :asset, :campaign

    def initialize(idnum, person_idnum = nil, activity_type, activity_date_time, asset, campaign)
      @idnum = idnum # id of the change record
      @person_idnum = person_idnum
      @activity_type = activity_type
      @activity_date_time = activity_date_time
      @attributes = {}
      @asset = asset
      @campaign = campaign
    end

    # hydrates an instance from a savon hash returned form the marketo API
    def self.from_hash(savon_hash)
      lead_change_record = LeadChangeRecord.new(
        savon_hash[:id].to_i, 
        savon_hash[:mkt_person_id].to_i, 
        savon_hash[:activity_type], 
        savon_hash[:activity_date_time], 
        savon_hash[:mktg_asset_name], 
        savon_hash[:campaign])
      savon_hash[:activity_attributes][:attribute].each do |attribute|
        lead_change_record.set_attribute(attribute[:attr_name], attribute[:attr_value])
      end
      lead_change_record
    end

    # update the value of the named attribute
    def set_attribute(name, value)
      @attributes[name] = value
    end

    # get the value for the named attribute
    def get_attribute(name)
      @attributes[name]
    end

    # will yield pairs of |attribute_name, attribute_value|
    def each_attribute_pair(&block)
      @attributes.each_pair do |name, value|
        block.call(name, value)
      end
    end

    def ==(other)
      @attributes == other.attributes &&
      @idnum == other.idnum &&
      @person_idnum == other.person_idnum
    end

    def to_s
      "idnum: #{idnum} mkt_person_idnum: #{@person_idnum} Type: #{@activity_type} Datetime: #{@activity_date_time} #{@asset} #{@campaign} #{@attributes}"
    end
  end
end
