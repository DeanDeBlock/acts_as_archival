module ExpectedBehavior
  module ActsAsArchival
    module AssociationOperation
      class Unarchive < Base

        protected

        def act_on_archivals(scope)
          scope.archived.find_each do |related_record|
            raise ActiveRecord::Rollback unless related_record.unarchive
          end
        end

      end
    end
  end
end
