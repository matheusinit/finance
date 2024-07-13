class UserJob
  include Sidekiq::Job

  def buffer

  def perform(*args)
    
    # Do something
  end
end
