class RescueWaitRetry 
  
  attr_accessor :retry_times, :delay_factor, :current_retry, :logger

  def initialize(logger)
    self.retry_times = 5
    self.delay_factor = 4 # Delay for each retry is the current iteration times 4
    self.current_retry = 0
    self.logger = logger
  end

  def wrap(task_name, &blk)
    begin
      time = Time.now
      self.current_retry += 1
      logger.info "#{task_name} - Try at: #{time} : #{self.current_retry}"
      yield blk
    rescue Exception => e
      retry if self.current_retry <= self.retry_times && sleep(self.delay_factor * self.current_retry)
      logger.info "#{task_name} - Retries failed"
      raise e
    end
  end
  
end
