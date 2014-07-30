module ExpectedBehavior
  module ActsAsArchival
    require 'digest/md5'

    MissingArchivalColumnError = Class.new(ActiveRecord::ActiveRecordError) unless defined?(MissingArchivalColumnError) == 'constant' && MissingArchivalColumnError.class == Class
    CouldNotArchiveError = Class.new(ActiveRecord::ActiveRecordError) unless defined?(CouldNotArchiveError) == 'constant' && CouldNotArchiveError.class == Class
    CouldNotUnarchiveError = Class.new(ActiveRecord::ActiveRecordError) unless defined?(CouldNotUnarchiveError) == 'constant' && CouldNotUnarchiveError.class == Class

    def self.included(base)
      base.extend ActMethods
    end

    module ActMethods
      def acts_as_archival(options = { })
        unless included_modules.include? InstanceMethods
          include InstanceMethods

          before_validation :raise_if_not_archival
          validate :readonly_when_archived if options[:readonly_when_archived]

          scope :archived, lambda { where(:archived => true) }
          scope :unarchived, lambda { where(:archived => false) }

          callbacks = ['archive','unarchive']
          define_callbacks *[callbacks, {:terminator => lambda { |_, result| result == false }}].flatten
          callbacks.each do |callback|
            eval <<-end_callbacks
              def before_#{callback}(*args, &blk)
                set_callback(:#{callback}, :before, *args, &blk)
              end
              def after_#{callback}(*args, &blk)
                set_callback(:#{callback}, :after, *args, &blk)
              end
            end_callbacks
          end
        end
      end

    end

    module InstanceMethods

      def readonly_when_archived
        if self.archived? && self.changed? && !self.archived_changed?
          self.errors.add(:base, "Cannot modify an archived record.")
        end
      end

      def raise_if_not_archival
        missing_columns = []
        missing_columns << "archived" unless self.respond_to?(:archived)
        raise MissingArchivalColumnError.new("Add '#{missing_columns.join "', '"}' column(s) to '#{self.class.name}' to make it archival") unless missing_columns.blank?
      end

      def archived?
        self.archived
      end

      def archive
        self.class.transaction do
          begin
            run_callbacks :archive do
              unless self.archived?
                self.archive_associations
                self.archived = true
                self.save!
              end
            end
            return true
          rescue => e
            ActiveRecord::Base.logger.try(:debug, e.message)
            ActiveRecord::Base.logger.try(:debug, e.backtrace)
            raise ActiveRecord::Rollback
          end
        end
        false
      end

      def unarchive
        self.class.transaction do
          begin
            run_callbacks :unarchive do
              if self.archived?
                self.archived = false
                self.save!
                self.unarchive_associations
              end
            end
            return true
          rescue => e
            ActiveRecord::Base.logger.try(:debug, e.message)
            ActiveRecord::Base.logger.try(:debug, e.backtrace)
            raise ActiveRecord::Rollback
          end
        end
        false
      end

      def archive_associations
        AssociationOperation::Archive.new(self).execute
      end

      def unarchive_associations
        AssociationOperation::Unarchive.new(self).execute
      end
    end
  end
end
