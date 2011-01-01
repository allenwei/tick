Tick
=====

About 
------

Tick benchmark your method and print it in color  


Installation 
-------

    gem install tick 


Usge 
--------

    def foo 
    end 
    tick :foo  
    tick :foo, :message => "benchmark for foo"
    tick :foo, :message => lambda {|class_name, method_name| " #{class_name}-#{method_name}"}



Configuration 
-------------

By default you don't need any configuration.


Enable tick:

    Tick.enabled = true 

default: true

Whether print benchmark in color 

    Tick.color = true 

default: true

Logger:
    
    Tick.logger = Logger.new(STDOUT) 

default: Rails.logger if in Rails environment otherwise Logger.new(STDOUT)

Customize messages:

    Tick.desc_message = lambda { |class_name, method_name| "TIME c:#{class_name} m:#{method_name}" }
    Tick.time_message = lambda { |sec| "COST (#{sec})" }

Default: 

* desc_message: "TICK: method '#{method_name.to_s}' in class '#{self.class.name}'" 
* time_message: "(#{sec.to_s} ms)"


Set 256 color:

    Tick.desc_color = "#FFC482"
    Tick.time_color = "#FFC482"

Default:

*  desc_color: yellow 
*  time_color: cyan


Special Thanks To
-----------------

* sickill's rainbow gem 
