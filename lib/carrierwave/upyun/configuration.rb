module CarrierWave
  module UpYun
    module Configuration
      extend ActiveSupport::Concern
      included do
        add_config :upyun_storage_username
        add_config :upyun_storage_userpass
        add_config :upyun_storage_bucket
        add_config :upyun_storage_api_host
        add_config :upyun_bucket_domain
      end
    end
    
    module ClassMethods
      def add_config(name)
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def self.#{name}(value=nil)
            @#{name} = value if value
            return @#{name} if self.object_id == #{self.object_id} || defined?(@#{name})
            name = superclass.#{name}
            return nil if name.nil? && !instance_variable_defined?("@#{name}")
            @#{name} = name && !name.is_a?(Module) && !name.is_a?(Symbol) && !name.is_a?(Numeric) && !name.is_a?(TrueClass) && !name.is_a?(FalseClass) ? name.dup : name
          end

          def self.#{name}=(value)
            @#{name} = value
          end

          def #{name}
            value = self.class.#{name}
            value.instance_of?(Proc) ? value.call : value
          end
        RUBY
      end   
    end
  end
end