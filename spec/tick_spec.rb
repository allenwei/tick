require 'spec_helper'
require 'logger'

describe Tick do 
  it "will use Rails logger if Rails defined" do 
    module Rails; end
    default_logger = Logger.new(STDOUT)
    mock(Rails).logger  { default_logger }
    Tick.logger.should == default_logger
    Object.send(:remove_const, :Rails)
  end

  it "will create new logger if no Rails defined" do 
    Tick.logger.should be_kind_of(Logger)
  end

  it "can set logger" do 
    logger = Logger.new(STDOUT)
    Tick.logger = logger 
    Tick.logger.should == logger
  end

  it "turn on color by default" do 
    Sickill::Rainbow.enabled.should be true
  end

  it "can turn off color" do 
    Tick.color = false 
    Sickill::Rainbow.enabled.should be false
  end

  it "can not set color to value which is not boolean" do 
    old_value = Sickill::Rainbow.enabled
    Tick.color = "asdasdas"
    Sickill::Rainbow.enabled.should be old_value
  end

  it "is turn on by default" do 
    Tick.enabled.should be true
  end

  it "can be turn off" do 
    Tick.enabled = false
    Tick.enabled.should be false
  end

  it "can set custom desc color" do 
    Tick.desc_color = "#FFC482" 
    Tick.desc_color.should == "#FFC482"
  end

  it "can set custom time color" do 
    Tick.time_color = "#FFC482" 
    Tick.time_color.should == "#FFC482"
  end

  it "can set custom desc message" do 
    a_proc = lambda { |class_name, method_name| "TIME c:#{class_name} m:#{method_name}" }
    Tick.desc_message = a_proc
    Tick.desc_message.should be a_proc
  end

  it "will raise exception if desc_message lambda arg number dones't match" do 
    a_proc = lambda { |class_name| "TIME c:#{class_name}" }
    lambda {Tick.desc_message = a_proc}.should raise_error(ArgumentError, "wrong number of arguments (1 for 2)")
  end

  it "will raise exception if desc_message lambda arg number dones't match" do 
    a_proc = lambda { |a, b|"COST (0.1)" }
    lambda {Tick.time_message = a_proc}.should raise_error(ArgumentError, "wrong number of arguments (2 for 1)")
  end

  it "can set custom time message" do 
    a_proc = lambda { |sec| "COST (#{sec})" }
    Tick.time_message = a_proc
    Tick.time_message.should be a_proc
  end
end

describe "A class include Tick" do
  before(:each) do 
    class TestClass;end
    @klass = TestClass
    @klass.send(:include, Tick)
  end

  after(:each) do 
    Object.send(:remove_const, :TestClass)
  end

  it "should have class method tick" do 
    @klass.should respond_to :tick
  end

  it "should not have logger method" do 
    @klass.should_not respond_to :logger
    @klass.new.should_not respond_to :logger
  end

  it "should raise exception if passing wrong method name" do 
    lambda {@klass.send(:tick, :xxx)}.should raise_error
  end

  describe "tick with options" do 
    before(:each) do 
      @klass.class_eval do  
        def default
          sleep 0.5
        end
      end
      @instance = @klass.new 
      @instance.should respond_to :default
    end

    it "support customize message for each method" do 
      message = "method default"
      @klass.send(:tick, :default, :message => message) 
      mock(@instance)._log_benchmark(message, anything)
      @instance.default
    end

    it "support customize lambda message for each method" do 
      message = "method default"
      @klass.send(:tick, :default, :message => lambda {|class_name, method_name| "m:#{method_name}" }) 
      mock(@instance)._log_benchmark("m:default", anything)
      @instance.default
    end
  end

  describe "tick on :default method" do 
    before do 
      @klass.class_eval do  
        def default
          sleep 0.5
        end
      end

      @klass.send(:tick, :default) 
      @instance = @klass.new 
      @instance.should respond_to :default
    end

    it "should log time when default method be called" do 
      mock(@instance)._log_benchmark(Tick.desc_message.call("TestClass","default"), anything)
      @instance.default
    end

    it "should not do benchmark if Tick is turn off" do 
      dont_allow(Benchmark).realtime(anything)
      old_value = Tick.enabled
      Tick.enabled = false
      @instance.default
      Tick.enabled = old_value
    end

  end

  describe "#_log_benchmark" do 
    before do 
      @instance = @klass.new
      mock(@instance)._colorize_desc(anything) do  |desc| 
        desc
      end
      mock(@instance)._colorize_time(anything) do |time| 
        time
      end
    end

    it "log sec in color" do 
      desc = "TICK: method 'default' in class ''"
      time = "(0.1 ms)"
      message = ""
      message << desc
      message << "  "
      message << time
      mock(Tick.logger).debug(message)
      @instance._log_benchmark(desc, time)    
    end

    it "should print custom message if set custom message" do 
      Tick.desc_message = lambda {|class_name, method_name| "c:#{class_name} m:#{method_name}" }
      Tick.time_message = lambda {|sec| "cost #{sec}" }
      desc = "c: m:default"
      time = "cost 0.1"
      message = ""
      message << desc
      message << "  "
      message << time
      mock(Tick.logger).debug(message)
      @instance._log_benchmark(desc, time)    
    end
  end

  describe "#colorize" do 
    it "should set desc color if desc color is set" do 
      str = "a" 
      color = "#FFC482"
      Tick.desc_color = color
      @klass.new._colorize_desc(str).should == str.color(color)
    end

    it "should set time color if time color is set" do 
      str = "a" 
      color = "#FFC482"
      Tick.time_color = color
      @klass.new._colorize_time(str).should == str.color(color)
    end

  end


end
