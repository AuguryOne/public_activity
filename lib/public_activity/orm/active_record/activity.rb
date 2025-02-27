# frozen_string_literal: true

module PublicActivity

  if not defined? ::PG::ConnectionBad
    module ::PG
      class ConnectionBad < Exception; end
    end
  end
  if not defined? Mysql2::Error::ConnectionError
    module Mysql2
      module Error
        class ConnectionError < Exception; end
      end
    end
  end

  module ORM
    module ActiveRecord
      # The ActiveRecord model containing
      # details about recorded activity.
      class Activity < ::ActiveRecord::Base
        include Renderable
        self.table_name = PublicActivity.config.table_name
        self.abstract_class = true

        # Define polymorphic association to the parent
        belongs_to :trackable, polymorphic: true

        case ::ActiveRecord::VERSION::MAJOR
        when 5
          with_options(required: false) do
            # Define ownership to a resource responsible for this activity
            belongs_to :owner, polymorphic: true
            # Define ownership to a resource targeted by this activity
            belongs_to :recipient, polymorphic: true
          end
        when 6..7
          with_options(optional: true) do
            # Define ownership to a resource responsible for this activity
            belongs_to :owner, polymorphic: true
            # Define ownership to a resource targeted by this activity
            belongs_to :recipient, polymorphic: true
          end
        end

        # Serialize parameters Hash
        serialize :parameters, Hash

        if ::ActiveRecord::VERSION::MAJOR < 4 || defined?(ProtectedAttributes)
          attr_accessible :key, :owner, :parameters, :recipient, :trackable
        end
      end
    end
  end
end
