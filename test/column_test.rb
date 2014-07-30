require_relative "test_helper"

class ColumnTest < ActiveSupport::TestCase
  test "acts_as_archival raises during create if missing archived column" do
    assert_raises(ExpectedBehavior::ActsAsArchival::MissingArchivalColumnError) {
      MissingArchived.create!(:name => "foo-foo")
    }
  end
end
