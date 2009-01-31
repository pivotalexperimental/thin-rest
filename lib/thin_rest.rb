require "rubygems"
require "thin"

dir = File.dirname(__FILE__)
require "#{dir}/thin_rest/connection"
require "#{dir}/thin_rest/resources"
require "#{dir}/thin_rest/resource_invalid"
require "#{dir}/thin_rest/routing_error"
require "#{dir}/thin_rest/extensions"
