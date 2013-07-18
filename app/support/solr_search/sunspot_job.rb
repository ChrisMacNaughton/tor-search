require 'digest/md5'
require 'yaml'
require 'sunspot'
require 'delayed_job'

module SolrSearch
  # Helper for keeping Solr indices up to date. Used in both the observers
  # and the concern for setting up Sunspot model index configuration.
  SunspotJob = Struct.new :method, :klass, :object_id do
    def perform
      self.klass = Module.const_get(self.klass) if self.klass.is_a?(String)
      send(method)
    end

    def index!
      index
      Sunspot.commit
    end

    def index
      obj = self.klass.where(id: self.object_id)
      Sunspot.index obj.first if obj.exists?
    end

    def remove_by_id
      Sunspot.remove_by_id self.klass, self.object_id
    end

    def unique?
      Delayed::Job.where(handler_hash: checksum).any?
    end

  private
    def checksum
      Digest::MD5.hexdigest to_yaml
    end
  end
end