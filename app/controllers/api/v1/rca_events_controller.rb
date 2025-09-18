module Api
  module V1
    class RcaEventsController < ApplicationController
      # GET /api/v1/rca_events
      # Fetch the 50 most recent RCA (Root Cause Analysis) events
      def index
        events = RcaEvent.order(ts: :desc).limit(50)
        render json: events
      end

      # GET /api/v1/rca_events/active
      # Fetch all currently active (open) RCA events
      def active
        events = RcaEvent.where(status: "open").order(ts: :desc)
        render json: events
      end

      # GET /api/v1/rca/summary
      # Return a summary of open issues grouped by location & ISP
      # Example: [{ "location": "Bangalore", "isp": "Airtel", "count": 2 }]
      def summary
        data = RcaEvent.where(status: "open")
                       .group(:location, :isp)
                       .count

        formatted = data.map do |(location, isp), count|
          {
            location: location,
            isp: isp,
            count: count
          }
        end

        render json: formatted
      end

      # GET /api/v1/rca/org_alerts
      # Return alerts per endpoint → how many locations are affected and which ISPs
      # Example: [{ "endpoint": "8.8.8.8", "bad_locations": 2, "bad_isps": ["Airtel", "Jio"] }]
      def org_alerts
        raw_data = RcaEvent.where(status: "open")
                           .group(:endpoint)
                           .pluck(:endpoint,
                                  Arel.sql("COUNT(DISTINCT location) as bad_locations"),
                                  Arel.sql("GROUP_CONCAT(DISTINCT isp) as bad_isps"))

        formatted = raw_data.map do |endpoint, bad_locations, bad_isps|
          {
            endpoint: endpoint,
            bad_locations: bad_locations,
            bad_isps: bad_isps.to_s.split(",")
          }
        end

        render json: formatted
      end

      # GET /api/v1/rca/top_issues
      # Return the top 5 ISPs/locations with the highest latency increase (vs baseline)
      def top_issues
        sql = <<~SQL
          SELECT
            isp,
            location,
            (avg(value) - avg(baseline)) / NULLIF(avg(baseline), 0) * 100 AS latency_increase_pct
          FROM rca_events
          WHERE metric_type = 'latency'
            AND status = 'open'
          GROUP BY isp, location
          ORDER BY latency_increase_pct DESC
          LIMIT 5
        SQL

        results = ActiveRecord::Base.connection.exec_query(sql)
        render json: results
      end
    end
  end
end
