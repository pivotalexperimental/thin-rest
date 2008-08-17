module ThinRest
  class Resource
    class << self
      def property(*names)
        properties.concat(names)
        attr_reader *names
      end

      def properties
        @properties ||= []
      end

      def route(name, resource_type_name=nil, &block)
        routes[name] = block || lambda do |env, name|
          resource_type = resource_type_name.split('::').inject(Resources) do |mod, next_mod_name|
            mod.const_get(next_mod_name)
          end
          resource_type.new(env)
        end
      end

      def routes
        @routes ||= {}
      end

      protected
      def handle_dequeue_and_process_error(command, error)
        if command.connection
          command.connection.handle_error error
        else
          super
        end
      end
    end
    ANY = Object.new

    property :connection
    delegate :request, :response, :to => :connection
    attr_reader :event, :env

    def initialize(env={})
      @env = env
      env.each do |name, value|
        instance_variable_set("@#{name}", value)
      end
      after_initialize
    end

    def get
      connection.send_response(do_get || "")
    rescue TransientState::RecordInvalid => e
      raise ResourceInvalid, e
    end

    def post
      connection.send_response(do_post || "")
    rescue TransientState::RecordInvalid => e
      raise ResourceInvalid, e
    end

    def put
      connection.send_response(do_put || "")
    rescue TransientState::RecordInvalid => e
      raise ResourceInvalid, e
    end

    def delete
      connection.send_response(do_delete || "")
    rescue TransientState::RecordInvalid => e
      raise ResourceInvalid, e
    end

    def locate(name)
      route_handler = self.class.routes[name] || self.class.routes[ANY]
      raise ::GameServer::Resources::InvalidRouteError.new(name, self) unless route_handler
      route_handler.call(env, name)
    end

    def unbind
      RAILS_DEFAULT_LOGGER.info "#{Clock.now.to_f} - #{self.class}#unbind : Connection#signature=#{connection.signature}"
    end

    protected
    def after_initialize
    end
  end
end