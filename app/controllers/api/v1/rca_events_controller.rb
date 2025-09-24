module Api
  module V1
    class RcaEventsController < ApplicationController
      # GET /api/v1/rca_events
      def index
        render json: RcaEventService.index
      end

      # ----------------------------
      # GET /api/v1/rca_events/active
      # Detect spikes, packet loss, HTTP failures in last 5 min
      # ----------------------------
      def active
        render json: RcaEventService.active
      end

      # ----------------------------
      # GET /api/v1/rca_events/summary
      # Group open issues by location & ISP
      # ----------------------------
      def summary
        render json: RcaEventService.summary
      end

      # ----------------------------
      # GET /api/v1/rca_events/org_alerts
      # Show alerts per endpoint: locations affected & ISPs
      # ----------------------------
      def org_alerts
        render json: RcaEventService.org_alerts
      end

      # ----------------------------
      # GET /api/v1/rca_events/top_issues
      # Top 5 ISP/location with highest latency increase vs last 1 hour
      # ----------------------------
      def top_issues
        render json: RcaEventService.top_issues
      end
    end
  end
end
