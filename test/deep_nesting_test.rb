require_relative "test_helper"

class DeepNestingTest < ActiveSupport::TestCase
  test "archiving deeply nested items" do
    archival   = Archival.create!
    child      = archival.archivals.create!
    grandchild = child.archivals.create!
    archival.archive
    assert archival.reload.archived?
    assert child.reload.archived?
    assert grandchild.reload.archived?
    assert_equal archival.archived, child.archived
    assert_equal archival.archived, grandchild.archived
  end

  test "unarchiving deeply nested items doesn't blow up" do
    archival_attributes = {
      :archived => true
    }
    archival   = Archival.create!(archival_attributes)
    child      = archival.archivals.create!(archival_attributes)
    grandchild = child.archivals.create!(archival_attributes)
    archival.unarchive
    assert_not archival.reload.archived?
    assert_not child.reload.archived?
    assert_not grandchild.reload.archived?
  end
end
