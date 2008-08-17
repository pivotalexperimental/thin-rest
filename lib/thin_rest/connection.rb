module ThinRest
  class Connection < Thin::Connection
    attr_reader :resource, :rack_request

    def process
      guard_against_errors do
        @rack_request = Rack::Request.new(@request.env)
        method = rack_request.request_method.downcase.to_sym
        @resource = get_resource(rack_request)
        resource.send(method)
      end
    end

    def unbind
      super
      resource.unbind if resource
    rescue Exception => e
      handle_error e
    end

    def handle_error(error)
      close_connection rescue nil
    rescue Exception => unexpected_error
      log_error unexpected_error
    end

    protected
    def guard_against_errors
      yield
    rescue InvalidRouteError => e
      RAILS_DEFAULT_LOGGER.info "Invalid route: #{rack_request.path_info}"
    rescue ResourceInvalid => e
      RAILS_DEFAULT_LOGGER.info "Invalid resource: #{e.message}, route=#{rack_request.path_info}"
    rescue Exception => e
      handle_error e
    end
    
    def get_resource(request)
      path_parts(request).inject(Resources::Root.new(:connection => self)) do |resource, child_resource_name|
        resource.locate(child_resource_name)
      end
    end

    def path_parts(request)
      request.path_info.split('/').reject { |part| part == "" }
    end

    def error_message(e)
      output = "Error in Connection#receive_line\n"
      output << "#{e.message}\n"
      output << e.backtrace.join("\n\t")
      output << "\n\nResource was:\n\t"
      output << "#{resource.inspect}\n"
      output
    end
  end
end
