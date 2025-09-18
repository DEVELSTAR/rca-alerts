class RcaDetectorJob < ApplicationJob
  queue_as :default

  def perform
    RcaDetector.run
  end
end
