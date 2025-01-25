module Cacheable extend ActiveSupport::Concern

  included do
    # Code to be executed when the module is included
    after_commit :update_cache_version
  end

  class_methods do
    def cached_data
      # pentru a evita erori datorate Class Reloading
      if Rails.env == 'development'
        self.all 
      else
        # cod de productie
        version = Rails.cache.fetch("#{name.underscore.pluralize}_version") do 
          # Daca cumva nu avem in cache nici o versiune, ii setam numarul = max(updated_at)
          maximum(:updated_at)&.to_i || 0
        end
        Rails.cache.fetch("#{name.underscore.pluralize}/v#{version}") do
          # Daca nu exista cache-ul cu exact numarul versiunii, executam SQL
          all.to_a
        end
      end
    end
  end

  private
  def update_cache_version
    # actualizam VERSIUNEA de cache
    Rails.cache.write("#{self.class.name.underscore.pluralize}_version", self.class.maximum(:updated_at)&.to_i)
  end

end

