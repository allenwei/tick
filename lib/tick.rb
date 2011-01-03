require 'logger'
require 'benchmark'
require 'rainbow'

module Tick

  Sickill::Rainbow.enabled = true

  def self.included(base)
    base.extend(ClassMethods)    
    base.send(:include, InstanceMethods)    
  end 

  def self.logger
    return @logger if @logger

    if defined?(Rails)
      Rails.logger
    else 
      Logger.new(STDOUT)
    end
  end

  def self.logger=(logger) 
    @logger = logger
  end

  def self.color=(is_turn_on)
    return unless is_turn_on.kind_of?(TrueClass) || is_turn_on.kind_of?(FalseClass)
    Sickill::Rainbow.enabled = is_turn_on
  end

  def self.enabled 
    @enabled = true if @enabled.nil?
    @enabled
  end

  def self.enabled=(is_turn_on) 
    @enabled = is_turn_on
  end

  def self.desc_message
    @desc_message ||= lambda {|class_name, method_name| "TICK: method '#{method_name}' in class '#{class_name}'"}
  end

  def self.desc_message=(block)
    return @desc_message = nil if block.nil?
    raise ArgumentError.new("wrong number of arguments (#{block.arity} for 2)") if block.arity != 2
    @desc_message = block
  end

  def self.desc_color 
    @desc_color
  end

  def self.desc_color=(color) 
    @desc_color = color
  end

  def self.time_message
    @time_message ||= lambda { |sec| "(#{sec.to_s} s)" }
  end

  def self.time_message=(block)
    return @time_message = nil if block.nil?
    raise ArgumentError.new("wrong number of arguments (#{block.arity} for 1)") if block.arity != 1
    @time_message = block
  end

  def self.time_color
    @time_color
  end

  def self.time_color=(color) 
    @time_color = color
  end

  def self.reset 
    self.enabled = true 
    self.color = true 
    @desc_message = nil 
    @time_message = nil 
    @desc_color = nil 
    @time_color = nil
  end


  module ClassMethods 
    def tick(method_name, options = {})
      if Tick.enabled
        alias_method "#{method_name}_without_tick", method_name  
        define_method method_name do
          result = nil 
          sec = Benchmark.realtime  { result = self.send("#{method_name}_without_tick") } 

          desc = nil 
          if options[:message].kind_of?(Proc) 
            desc = options[:message].call(self.class.name, method_name)
          else
            desc = options[:message] || Tick.desc_message.call(self.class.name, method_name)
          end

          time = Tick.time_message.call(sec)
          _log_benchmark(desc, time)
          result
        end
      end
    end
  end

  module InstanceMethods 
    def _log_benchmark(desc, time)
      message = self._colorize_desc(desc)
      message << "  "
      message << self._colorize_time(time)
      Tick.logger.debug(message)
    end

    def _colorize_desc(str) 
      if Tick.desc_color 
        str.color(Tick.desc_color)
      else
        str.bright.foreground(:yellow)
      end
    end

    def _colorize_time(str)
      if Tick.time_color 
        str.color(Tick.time_color)
      else
        str.underline.foreground(:cyan).bright
      end
    end

  end

end
