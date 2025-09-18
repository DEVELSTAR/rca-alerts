class AlertDispatcherJob < ApplicationJob
  queue_as :critical

  def perform
    AlertDispatcher.run
  end
end
