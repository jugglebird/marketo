require_relative '../../test_helper'

describe Marketo do
  it "must be defined" do
    Marketo::VERSION.wont_be_nil
  end
end
