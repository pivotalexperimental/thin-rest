module ThinRest
  module Resources
    class FileNotFound < Resource
      property :name
      def get
        connection.send_head(404)
        connection.send_body(Representations::FileNotFound.new(self, :path => rack_request.path_info).to_s)
        raise RoutingError, "Invalid route: #{connection.rack_request.path_info} ; name: #{name}"
      end
    end
  end
end