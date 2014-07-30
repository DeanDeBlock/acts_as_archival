# name           - string
# archived_at    - datetime
class MissingArchived < ActiveRecord::Base
  acts_as_archival
end
