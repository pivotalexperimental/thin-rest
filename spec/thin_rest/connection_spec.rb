require File.expand_path("#{File.dirname(__FILE__)}/../thin_rest_spec_helper")

module ThinRest
  describe Connection do
    attr_reader :connection

    def create_connection(guid = Guid.new.to_s)
      connection = ThinRest::Connection.new(guid)
      connection.backend = Object.new
      stub(connection.backend).connection_finished
      connection
    end

    def stub_send_data
      stub(EventMachine).send_data do |signature, data, data_length|
        data_length
      end
    end

    describe "#send_head" do
      before do
        @connection = create_connection
        stub(EventMachine).close_connection
      end

      it "responds with the HTTP header excluding the Content-Length" do
        expected_header = Connection::HEAD
        mock(EventMachine).send_data( connection.signature, expected_header, expected_header.length ) {expected_header.length}
        connection.send_head
      end
    end

    describe "#send_body" do
      before do
        @connection = create_connection
        stub(EventMachine).close_connection
      end

      it "responds with Content-Length and the body" do
        data = "The data"
        header = "Content-Length: #{data.length}\r\n\r\n"

        mock(EventMachine).send_data( connection.signature, header, header.length ) {header.length}
        mock(EventMachine).send_data( connection.signature, data, data.length ) {data.length}

        connection.send_body data
      end
    end

    describe "#unbind" do
      attr_reader :game_session

      before do
        stub_send_data
        stub(EventMachine).close_connection
        @connection = create_connection
        params = "param_1=1&param_2=2"
        body = "#{params}\r\n"
        connection.receive_data("POST /subresource HTTP/1.1\r\nHost: _\r\n\r\n#{body}")
      end

      it "calls connection_finished on the backend to protect against memory leaks" do
        mock(connection.backend).connection_finished(connection)
        connection.unbind
      end

      it "does not send data or add a timer of any type" do
        dont_allow(EventMachine).send_data
        dont_allow(EventMachine).add_timer

        connection.unbind
      end
    end

    describe "#handle_error" do
      before do
        @connection = create_connection
        Thin::Logging.silent = true
      end

      it "logs the error" do
        error = RuntimeError.new("Unexpected Error")
        stub(error).backtrace(caller)

        stub(connection).warn
        mock.proxy(connection).log_error(error)
        mock.proxy(connection).log_error(anything)

        connection.handle_error(error)
      end
    end
  end
end
