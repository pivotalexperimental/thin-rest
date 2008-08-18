require File.expand_path("#{File.dirname(__FILE__)}/../thin_rest_spec_helper")

module ThinRest
  describe Resource do
    attr_reader :connection
    describe "GET /subresource" do
      self.thin_logging = true
      before do
        @connection = create_connection
        stub(EventMachine).close_connection
      end

      it "sends the GET response for the resource" do
        mock(connection).send_data(Connection::HEAD)
        expected_data = "GET response"
        expected_content_length = "Content-Length: #{expected_data.length}\r\n\r\n"
        mock(connection).send_data(expected_content_length) {expected_content_length.length}
        mock(connection).send_data(expected_data) {expected_data.length}
        connection.receive_data("GET /subresource HTTP/1.1\r\nHost: _\r\n\r\n")
      end
    end

    describe "POST /subresource" do
      self.thin_logging = true
      before do
        @connection = create_connection
        stub(EventMachine).close_connection
      end

      it "sends the POST response for the resource" do
        mock(connection).send_data(Connection::HEAD)
        expected_data = "POST response"
        expected_content_length = "Content-Length: #{expected_data.length}\r\n\r\n"
        mock(connection).send_data(expected_content_length) {expected_content_length.length}
        mock(connection).send_data(expected_data) {expected_data.length}
        connection.receive_data("POST /subresource HTTP/1.1\r\nHost: _\r\n\r\n")
      end
    end

    describe "PUT /subresource" do
      self.thin_logging = true
      before do
        @connection = create_connection
        stub(EventMachine).close_connection
      end

      it "sends the PUT response for the resource" do
        mock(connection).send_data(Connection::HEAD)
        expected_data = "PUT response"
        expected_content_length = "Content-Length: #{expected_data.length}\r\n\r\n"
        mock(connection).send_data(expected_content_length) {expected_content_length.length}
        mock(connection).send_data(expected_data) {expected_data.length}
        connection.receive_data("PUT /subresource HTTP/1.1\r\nHost: _\r\n\r\n")
      end
    end

    describe "DELETE /subresource" do
      self.thin_logging = true
      before do
        @connection = create_connection
        stub(EventMachine).close_connection
      end

      it "sends the DELETE response for the resource" do
        mock(connection).send_data(Connection::HEAD)
        expected_data = "DELETE response"
        expected_content_length = "Content-Length: #{expected_data.length}\r\n\r\n"
        mock(connection).send_data(expected_content_length) {expected_content_length.length}
        mock(connection).send_data(expected_data) {expected_data.length}
        connection.receive_data("DELETE /subresource HTTP/1.1\r\nHost: _\r\n\r\n")
      end
    end
  end
end
