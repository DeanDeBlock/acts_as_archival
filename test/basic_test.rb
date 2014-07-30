require_relative "test_helper"

class BasicTest < ActiveSupport::TestCase
  test "archive archives the record" do
    archival = Archival.create!
    archival.archive
    assert archival.reload.archived?
  end

  test "unarchive unarchives archival records" do
    archival = Archival.create!(:archived => true)
    archival.unarchive
    assert_not archival.reload.archived?
  end

  test "archive returns true on success" do
    normal = Archival.create!
    assert_equal true, normal.archive
  end

  test "archive returns false on failure" do
    readonly = Archival.create!
    readonly.readonly!
    assert_equal false, readonly.archive
  end

  test "unarchive returns true on success" do
    normal = Archival.create!(:archived => true)
    assert_equal true, normal.unarchive
  end

  test "unarchive returns false on failure" do
    readonly = Archival.create!(:archived => true)
    readonly.readonly!
    assert_equal false, readonly.unarchive
  end

  test "archive sets archived to true" do
    archival = Archival.create!
    archival.archive
    assert_equal true, archival.archived
  end

  test "archive on archived object doesn't alter the archived boolean" do
    archived = Archival.create
    archived.archive
    initial_state = archived.archived
    archived.reload.archive
    second_state = archived.archived
    assert_equal initial_state, second_state
  end
end
