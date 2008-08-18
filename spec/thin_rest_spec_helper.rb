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
  end
end

class TestConnection < ThinRest::Connection
  def root_resource
    Root.new(:connection => self)
  end
end

class Root < ThinRest::Resource
  property :connection
  route 'subresource', 'Subresource'
end

class Subresource < ThinRest::Resource
  def do_get
    "Subresource response"
  end
end