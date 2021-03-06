require 'date'
require 'logger'
require_relative 'utils'

module Schedule_maker
    extend self

    SCHEDULE_DATA = Struct.new(:daily_task_list, :rerun_max, :scheduled_days, :consecutive_days, :year, :month, :max_monthly_assignments, :max_times_assigned_to_task, :position_class)
    attr_reader :schedule_data, :assignments

    class Monthly_Schedule
        include Calendar_formats

        attr_reader :schedule

        def initialize(prep_schedule, config)
            @prep_schedule = prep_schedule
            @config = config
            Worker.max_monthly_assignments = @config.max_monthly_assignments
            Worker.total_tasks = @config.daily_task_list.count
            Worker.max_times_assigned_to_task = @config.max_times_assigned_to_task
            Worker.scheduled_days = @config.scheduled_days
            make_schedule(@config.rerun_max)
        end

        def generate_calendar(calendar_run)
            begin
                calendar_data = CALENDAR_DATA.new(calendar_run, initialize_calendar(false), @config.daily_task_list, Worker.scheduled)
                calendar(calendar_data)
            rescue => e
                puts e.message
            end
        end

        protected
            def make_schedule(rerun_max)
                rerun = false
                rerun_count = 0
                calendar = []
                begin
                    calendar = initialize_calendar()
                    Worker.data_reset() if rerun
                    calendar.each{|day| @config.daily_task_list.each { |schedule_type| select_attendant(schedule_type, day) }}
                    break if rerun_max <= rerun_count += 1
                    rerun = Worker.scheduled.count_candidates(Worker::DEFAULT_WORKER)
                end while rerun
            end

            def select_attendant(schedule_type, day)
                @attendant_classes.data.each do |data|
                    if data.schedule_type == schedule_type
                        if data.respond_to?('get_custom_worker')
                            custom_data = Config::get_worker_data(data)
                            data.get_custom_worker(day, custom_data[0])
                        else
                            data.get_worker()
                        end
                        break
                    end
                end
            end

            def gen_calendar(year, month, scheduled_days_of_week = [])
                calendar = []
                day = 0
                until !Date.valid_date?(year,month,day += 1)
                    if scheduled_days_of_week.include?(Date.new(year,month,day).cwday) || scheduled_days_of_week == []
                        block_given? ? calendar << yield(year,month,day) : calendar << day.to_s
                    end
                end
                calendar
            end

            def initialize_calendar(prep_schedule = true)
                @attendant_classes = @prep_schedule::Attendant_data_classes.new(@config.daily_task_list) if prep_schedule
                gen_calendar(@config.year,@config.month,@config.scheduled_days) {|y,m,d| Date::ABBR_DAYNAMES[Date.new(y,m,d).wday] + " " + d.to_s}
            end
    end
end