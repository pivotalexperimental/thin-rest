module ThinRest
  class Connection < Thin::Connection
    attr_reader :resource, :rack_request

    def process
      guard_against_errors do
        method = rack_request.request_method.downcase.to_sym
        @resource = get_resource
        resource.send(method)
      end
    end

    def rack_request
      @rack_request ||= Rack::Request.new(@request.env)
    end

    def send_head(status=200)
      send_data(head(status))
    end

    def head(status)
      "HTTP/1.1 #{status} OK\r\nConnection: close\r\nServer: Thin Rest Server\r\n"
    end

    def send_body(data)
      length = send_data("Content-Length: #{data.length}\r\n\r\n")
      length += send_data(data)
      close_connection_after_writing
    ensure
      terminate_request
    end

    def unbind
      super
      resource.unbind if resource
    rescue Exception => e
      handle_error e
    end

    def handle_error(error)
      log_error error
      close_connection rescue nil
    rescue Exception => unexpected_error
      log_error unexpected_error
    end

    protected
    def guard_against_errors
      yield
    rescue Exception => e
      handle_error e
    end
    
    def get_resource
      path_parts.inject(root_resource) do |resource, child_resource_name|
        resource.locate(child_resource_name)
      end
    end

    def root_resource
      raise NotImplementedError
    end

    def path_parts
      rack_request.path_info.split('/').reject { |part| part == "" }
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
