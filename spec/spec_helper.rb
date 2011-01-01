require 'rubygems'
require 'bundler/setup'
require 'rspec'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),'..','lib'))

require 'tick'

RSpec.configure do |config|
  config.mock_with :rr
  config.after(:each) do 
    Tick.reset
  end
end


