module Api
  module V1
    class MetricsController < ApplicationController
      # GET /api/v1/metrics/endpoint_metrics?location=Bangalore&isp=Airtel
      # Return recent rollup metrics for given location & ISP
      # Example: [{ "ts_min": "2025-09-14T22:10:00Z", "endpoint": "8.8.8.8", "avg_latency": 70, "samples": 20 }]
      def endpoint_metrics
        location = params[:location]
        isp      = params[:isp]

        sql = <<~SQL
          SELECT
            ts_min,
            endpoint,
            location,
            isp,
            sum_latency / samples AS avg_latency,
            samples
          FROM router_metrics_rollup
          WHERE 1=1
            #{ "AND location = '#{location}'" if location.present? }
            #{ "AND isp = '#{isp}'" if isp.present? }
          ORDER BY ts_min DESC
          LIMIT 100
        SQL

        results = ClickHouse.connection.select_all(sql)
        render json: results
      end

      # GET /api/v1/metrics/summary
      # Return aggregated metrics summary per location, ISP, and endpoint
      # Example: [{ "location": "Bangalore", "isp": "Airtel", "endpoint": "8.8.8.8", "avg_latency": 70, "max_latency": 200, "min_latency": 20, "total_samples": 500 }]
      def metrics_summary
        sql = <<~SQL
          SELECT
            location,
            isp,
            endpoint,
            avg(sum_latency / samples) AS avg_latency,
            max(sum_latency / samples) AS max_latency,
            min(sum_latency / samples) AS min_latency,
            sum(samples) AS total_samples
          FROM router_metrics_rollup
          GROUP BY location, isp, endpoint
          ORDER BY avg_latency DESC
          LIMIT 50
        SQL

        results = ClickHouse.connection.select_all(sql)
        render json: results
      end
    end
  end
end
