require 'solr_search/sunspot_job'

module SolrSearch
  # Index any model with Solr using Sunspot. When included in a
  # model, any create/update/destroy action will be followed
  # by refreshing the Solr index for this particular model
  # instance.
  module Index
    extend ActiveSupport::Concern

    included do
      cattr_accessor    :_index_class, :_index_id, :_index_validator

      after_save    :reindex_solr_on_save
      after_destroy :reindex_solr_on_destroy
    end

    module ClassMethods
      # Set the class by which we are referencing the index.
      def index_on(index_class_name, and_identifier=nil, and_conditions=nil)
        self._index_class = index_class_name
        self._index_id = and_identifier || identifier_from_index_class
        self._index_validator = and_conditions
      end

      def identifier_from_index_class
        if self._index_class.present?
          :"#{index_class_parameter}_id"
        else
          :id
        end
      end

      def index_class_parameter
        "#{self._index_class}".downcase.underscore
      end
    end
    private

    # Create an index to this model on Solr every time the model's
    # data is persisted to the database.
    def reindex_solr_on_save
      queue_job(sunspot_job(:save))
    end

    def reindex_solr_on_destroy
      queue_job(sunspot_job(:destroy))
    end

    def queue_job(j)
      if solr_index_can_be_updated?(j)
        logger.info "Indexing #{j.klass} ##{j.object_id} on Solr (in #{self.class})"
        Delayed::Job.enqueue j, priority: 0
      else
        logger.info "Not queueing up index for #{j.klass} ##{j.object_id} on Solr (in #{self.class})"
      end
    end

    def sunspot_job(action_type)
      model      = self._index_class || self.class
      id_method  = self._index_id || :id
      identifier = self.send(id_method)

      # If destroying *this* object, we want to send in remove by id
      # If we are reflecting on another object, we want to trigger a re-indexing of that
      # other object
      index_method = if action_type == :destroy && model != self.class && identifier != self.id
        :remove_by_id
      else
        :index
      end

      SolrSearch::SunspotJob.new index_method, model, identifier
    end

    def solr_index_can_be_updated?(j)
      configured_to_update_solr? && valid_to_index? && !j.unique?
    end

    def valid_to_index?
      self._index_validator.nil? || self._index_validator.call(self)
    end

    def configured_to_update_solr?
      ::TorSearch::Application.config.tor_search.update_solr_on_change
    end
  end
end
