$LOAD_PATH << 'attendants'
require_relative 'setup'
require_relative 'schedule'
require 'attendant.rb'

#Attendant.randomize_count = 23      #config value
#This value should be calculated as follows:  weeks - 1 or sun > wed ? sun - 1 : wed - 1
Attendant.monthly_assignments = 4   #config value
Attendant.weekly_assignments = Prep_schedule::POSITIONS.count
schedule_data = Prep_schedule::Attendant_data_classes.new(Prep_schedule::POSITIONS)
ms = Monthly_Schedule.new(schedule_data, Prep_schedule::POSITIONS, 2016, 3)
ms.sound_position = :ST_SOUND       #config value
ms.rerun_max = 5                    #config value
ms.make_schedule()
#Thek code below this point is test code only
puts ""
puts "details = #{Attendant.scheduled}"
puts ""