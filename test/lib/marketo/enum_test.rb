require_relative '../../test_helper'

module Marketo

  describe ListOperationType do
    it 'should define the correct types' do
      ListOperationType::ADD_TO.must_equal 'ADDTOLIST'
      ListOperationType::IS_MEMBER_OF.must_equal 'ISMEMBEROFLIST'
      ListOperationType::REMOVE_FROM.must_equal 'REMOVEFROMLIST'
    end
  end

end
