# ActsAsArchival

Atomically archive object trees in your activerecord models.

We had the problem that acts_as_paranoid and similar plugins/gems
always work on a record-by-record basis and made it very difficult to
restore records atomically (or archive them, for that matter).

Because the archive and unarchive methods are in transactions you can easily restore or remove an entire set of records
without having to worry about partial deletion or restoration.

Additionally, other plugins generally screw with how
`destroy`/`delete` work.  We don't because we actually want to be able
to destroy records.

## Install

Gemfile:

`gem "acts_as_archival"`

Any models you want to be archival should have the column `archived` (Boolean).

i.e. `rails g migration AddAAAToPost archived:boolean`

Any dependent-destroy AAA model associated to an AAA model will be archived with its parent.

_If you're stuck on Rails 3.0x/2, check out the available branches, which are no longer in active development._

## Example

``` ruby
class Hole < ActiveRecord::Base
  acts_as_archival
  has_many :rats, :dependent => :destroy
end

class Rat < ActiveRecord::Base
  acts_as_archival
end
```

### Simple interactions & scopes

``` ruby
h = Hole.create                  #
h.archived?                      # => false
h.archive                        # => true
h.archived?                      # => true
h.unarchive                      # => true
h.archived?                      # => false
h.archive_number                 # => nil
h.archived_at                    # => nil
```

### Associations

``` ruby
h = Hole.create                  #
r = h.rats.create                #
h.archive                        # => true
h.archived?                      # => true
r.archived?                      # => true
h.unarchive                      # => true
h.archived?                      # => false
r.archived?                      # => false
r.archived?                      # => false
```

### Scopes

``` ruby
h = Hole.create
Hole.archived.size               # => 0
Hole.unarchived.size             # => 1
h.archive
Hole.archived.size               # => 1
Hole.unarchived.size             # => 0
```

### Utility methods

``` ruby
h = Hole.create                  #
h.is_archival?                   # => true
Hole.is_archival?                # => true
```

### Options

When defining an AAA model, it is is possible to make it unmodifiable
when it is archived by passing `:readonly_when_archived => true` to the
`acts_as_archival` call in your model.

``` ruby
class CantTouchThis < ActiveRecord::Base
  acts_as_archival :readonly_when_archived => true
end

record = CantTouchThis.create(:foo => "bar")
record.archive                               # => true
record.foo = "I want this to work"
record.save                                  # => false
record.errors.full_messages.first            # => "Cannot modify an archived record."
```

## Caveats

1. This will only work on associations that are dependent destroy. It
should be trival to change that or make it optional.
1. It will only work for Rails 2.2 and up, because we are using
`named_scope`/`scope`. You can check out [permanent records](http://github.com/fastestforward/permanent_records) for a way
to conditionally add the functionality to older Rails installations.
1. If you would like to work on this, you will need to setup sqlite, postgres, and mysql on your development machine. Alternately, you can disable specific dev dependencies in the gemspec and test_helper and ask for help.

## Testing

Running the tests should be as easy as:

```  bash
script/setup                 # bundles, makes databases with permissions
rake                         # run tests on latest Rails
appraisal rake               # run tests on all versions of Rails
```

## Help Wanted

We'd love to have your help making this better! If you have ideas for features this should implement or you think the code sucks, let us know. And PRs are greatly appreciated. :+1:

## Thanks

ActsAsParanoid and PermanentRecords were both inspirations for this:

* http://github.com/technoweenie/acts_as_paranoid
* http://github.com/fastestforward/permanent_records

## Contributors

* Joel Meador
* Michael Kuehl
* Matthew Gordon
* Vojtech Salbaba
* David Jones
* Dave Woodward
* Miles Sterrett
* James Hill
* Maarten Claes

Thanks!

*Copyright (c) 2009-2014 Expected Behavior, LLC, released under the MIT license*
