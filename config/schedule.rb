# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end
# Learn more: http://github.com/javan/whenever

every  1.day, :at => '07:00 am' do
  rake "report"
end

every :monday, :at => '01:00 am' do # Use any day of the week or :weekend, :weekday
  rake "teacher_week_pay"
end

every 1.months do 
  rake "teacher_rank"
end
every 1.day, :at => '01:00 am' do # Use any day of the week or :weekend, :weekday
  rake "teacher_daily_pay"
end

every 1.hours do
  rake "update_order_status"
end

every '0 0 1 * *' do 
  rake "teacher_rank"
end

every '30 0 * * 3' do
  command "/bin/bash -l -c 'cd /var/www/SpiderSave && RAILS_ENV=production bundle exec rake notice:spider_data --silent >> /home/crontab_spider_save.log'"
end

every '30 10 * * 3' do 
	command "/bin/bash -l -c 'cd /var/www/SpiderSave && RAILS_ENV=production bundle exec rake notice:send_message --silent >> log/crontab.log 2>&1'"
end

every '30 12 * * 3' do 
	command "/bin/bash -l -c 'cd /var/www/SpiderSave && RAILS_ENV=production bundle exec rake notice:export --silent >> log/crontab.log 2>&1'"
end

every '40 10 * * *' do 
	command "/bin/bash -l -c 'cd /var/www/SpiderSave && RAILS_ENV=production bundle exec rake notice:day_push --silent >> log/crontab.log 2>&1'"
end

every '59 10 * * *' do 
	command "/bin/bash -l -c 'cd /var/www/SpiderSave && RAILS_ENV=production bundle exec rake notice:refresh --silent >> log/crontab.log 2>&1'"
end

every '00 3 * * *' do 
	command "00 3 * * * /usr/sbin/bakmysql.sh"
end

# Begin Whenever generated tasks for: /var/www/mmxueche/config/schedule.rb
###### 0 7 * * * /bin/bash -l -c 'cd /var/www/mmxueche && RAILS_ENV=production bundle exec rake report --silent'

####### 30 0 * * 3 /bin/bash -l -c 'cd /var/www/SpiderSave && RAILS_ENV=production bundle exec rake notice:spider_data --silent >> /home/crontab_spider_save.log'



###### 30 10 * * 3 /bin/bash -l -c 'cd /var/www/SpiderSave && RAILS_ENV=production bundle exec rake notice:send_message --silent >> log/crontab.log 2>&1'



###### 30 12 * * 3 /bin/bash -l -c 'cd /var/www/SpiderSave && RAILS_ENV=production bundle exec rake notice:export --silent >> log/crontab.log 2>&1'



###### 40 10 * * * /bin/bash -l -c 'cd /var/www/SpiderSave && RAILS_ENV=production bundle exec rake notice:day_push --silent >> log/crontab.log 2>&1'



###### 59 10 * * * /bin/bash -l -c 'cd /var/www/SpiderSave && RAILS_ENV=production bundle exec rake notice:refresh --silent >> log/crontab.log 2>&1'

# #定时备份
###### 00 3 * * * /usr/sbin/bakmysql.sh

# #每小时把已经完成的订单修改状态
###### 03 * * * * /bin/bash -l -c 'cd /var/www/mmxueche && RAILS_ENV=production bundle exec rake update_order_status --silent >> /home/log/update_order_status.log'

# #每月更新一次教练排行榜
##### 0 0 1 * * /bin/bash -l -c 'cd /var/www/mmxueche && RAILS_ENV=production bundle exec rake teacher_rank --silent'

# #每周一结算周结教练
##### 0 1 * * 1 /bin/bash -l -c 'cd /var/www/mmxueche && RAILS_ENV=production bundle exec rake teacher_week_pay --silent'

###### 0 1 * * * /bin/bash -l -c 'cd /var/www/mmxueche && RAILS_ENV=production bundle exec rake teacher_daily_pay --silent'
# # End Whenever generated tasks for: /var/www/mmxueche/config/schedule.rb