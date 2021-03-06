class HomeController < ApplicationController

  def index
    # @logs = SystemEvents.where("SysLogTag = 'rails[10941]:'").order('Message').limit(200)
    # @logs = SystemEvents.where("SysLogTag = 'rails[10941]:'").order('ReceivedAt').limit(200)
    @logs = RenderLog.order('time').limit(200)
    # @data = @logs.map {|l| ["#{l.time}", l.completed_time]}
  end

  def graph
    @logs = RenderLog.order('time')
    @data = @logs.map {|l| ["#{l.time}", l.completed_time]}
  end

  def list
    @logs = RenderLog.order('completed_time DESC').limit(200)
  end

  def syslog_list
    @logs = SystemEvents.order('Message').limit(200)
  end

  def candlestick
    start_time = RenderLog.order('time').first.time
    end_time = RenderLog.order('time').last.time
    period = 3.hours
    n = ((end_time - start_time)/3.hours).floor
    start_times = (1..n).to_a.map {|x| start_time+x*period}
    @data = []
    start_times.each do |time|
      logs = RenderLog.order('time').where('time > ? and time < ?', time, time+period)
      open = logs.first.completed_time
      close = logs.last.completed_time
      values = logs.map {|l| l.completed_time}.sort
      x = (values.length/50).to_i
      values = values[x..values.length-x]
      high = values.last
      low = values.first
      @data << ["#{time.strftime('%F - %T')}",low,open,close,high]
    end
  end

  def pie
    x = RenderLog.all.map {|log| log.controller+'/'+log.action}
    y = Hash.new(0)
    x.each do |v|
      y[v] += 1
    end
    @data = []
  end

end
