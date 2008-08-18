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
          resource_type = resource_type_name.split('::').inject(Object) do |mod, next_mod_name|
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
    attr_reader :event, :env

    def initialize(env={})
      @env = env
      env.each do |name, value|
        instance_variable_set("@#{name}", value)
      end
      after_initialize
    end

    def request; connection.request; end
    def response; connection.response; end

    def get
      connection.send_head
      connection.send_body(do_get || "")
    end

    def post
      connection.send_head
      connection.send_body(do_post || "")
    end

    def put
      connection.send_head
      connection.send_body(do_put || "")
    end

    def delete
      connection.send_head
      connection.send_body(do_delete || "")
    end

    def locate(name)
      route_handler = self.class.routes[name] || self.class.routes[ANY]
      raise ::GameServer::Resources::InvalidRouteError.new(name, self) unless route_handler
      route_handler.call(env, name)
    end

    def unbind
    end

    protected
    def after_initialize
    end
  end
end