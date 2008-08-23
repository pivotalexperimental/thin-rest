dir = File.dirname(__FILE__)
$LOAD_PATH.unshift(File.expand_path("#{dir}/../lib"))
require "thin_rest"
require "spec"
require "guid"

Spec::Runner.configure do |config|
  config.mock_with :rr

  config.before do
    stub(EventMachine).send_data {raise "EventMachine.send_data needs to be stubbed or mocked out"}
    stub(EventMachine).close_connection {raise "EventMachine.close_connection needs to be stubbed or mocked out"}
    stub(EventMachine).close_connection_after_writing {raise "EventMachine.close_connection_after_writing needs to be stubbed or mocked out"}
    stub(EventMachine).set_comm_inactivity_timeout {raise "EventMachine.set_comm_inactivity_timeout needs to be stubbed or mocked out"}
    stub(EventMachine).report_connection_error_status {0}
    stub(EventMachine).add_timer
    Thin::Logging.silent = !self.class.thin_logging
    Thin::Logging.debug = self.class.thin_logging
    Thin::Logging.trace = false
  end
end

module Spec::Example::ExampleGroupMethods
  def thin_logging
    if @thin_logging.nil?
      return false
    else
      @thin_logging
    end
  end
  attr_writer :thin_logging
end

module Spec::Example::ExampleMethods
  def create_connection(guid = Guid.new.to_s)
    connection = TestConnection.new(guid)
    connection.backend = Object.new
    stub(connection.backend).connection_finished
    connection
  end

  def stub_send_data
    stub(EventMachine).send_data do |signature, data, data_length|
      data_length
    end
  end
end

class TestConnection < ThinRest::Connection
  def root_resource
    Root
  end
end

class Root < ThinRest::Resource
  property :connection
  route 'subresource', 'Subresource'
  route 'block_subresource' do |env, name|
    BlockSubresource.new(env)
  end
end

class Subresource < ThinRest::Resource
  def do_get
    "GET response"
  end

  def do_post
    "POST response"
  end

  def do_put
    "PUT response"
  end

  def do_delete
    "DELETE response"
  end
end

class BlockSubresource < ThinRest::Resource

end