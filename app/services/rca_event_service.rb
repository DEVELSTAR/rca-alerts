# app/services/rca_event_service.rb
class RcaEventService

  # ----------------------------
  # Full history (last 60 min)
  # ----------------------------
  def self.index
    sql = <<~SQL
      SELECT
        rollup.location,
        rollup.isp,
        rollup.endpoint,
        rollup.sum_latency / rollup.samples AS avg_latency,
        rollup.sum_loss / rollup.samples AS packet_loss,
        raw_failures.failures AS http_failures,
        rollup.ts_min AS ts
      FROM router_metrics_rollup AS rollup
      LEFT JOIN (
        SELECT location, isp, endpoint,
               countIf(http_status >= 500) AS failures
        FROM router_metrics_raw
        WHERE ts >= subtractMinutes(now(), 60)
        GROUP BY location, isp, endpoint
      ) AS raw_failures
      USING (location, isp, endpoint)
      ORDER BY ts DESC
      LIMIT 100
    SQL

    ClickHouse.connection.select_all(sql)
  end

  # ----------------------------
  # Active RCA events (last 5 min spikes)
  # ----------------------------
  def self.active
    sql = <<~SQL
      SELECT
        rollup.location,
        rollup.isp,
        rollup.endpoint,
        rollup.sum_latency / rollup.samples AS avg_latency,
        rollup.sum_loss / rollup.samples AS packet_loss,
        raw_failures.failures AS http_failures
      FROM router_metrics_rollup AS rollup
      LEFT JOIN (
        SELECT location, isp, endpoint,
               countIf(http_status >= 500) AS failures
        FROM router_metrics_raw
        WHERE ts >= subtractMinutes(now(), 5)
        GROUP BY location, isp, endpoint
        HAVING failures > 3
      ) AS raw_failures
      USING (location, isp, endpoint)
      WHERE (rollup.sum_latency / rollup.samples) > 100
         OR (rollup.sum_loss / rollup.samples) > 0.1
         OR raw_failures.failures > 3
    SQL

    ClickHouse.connection.select_all(sql)
  end

  # ----------------------------
  # Summary grouped by location & ISP
  # ----------------------------
  def self.summary
    sql = <<~SQL
      SELECT location, isp,
             count(*) AS count
      FROM router_metrics_rollup
      WHERE (sum_latency / samples) > 100
         OR (sum_loss / samples) > 0.1
      GROUP BY location, isp
    SQL

    ClickHouse.connection.select_all(sql)
  end

  # ----------------------------
  # Alerts per endpoint
  # ----------------------------
  def self.org_alerts
    sql = <<~SQL
      SELECT endpoint,
             COUNT(DISTINCT location) AS bad_locations,
             arrayDistinct(groupArray(isp)) AS bad_isps
      FROM router_metrics_rollup
      WHERE (sum_latency / samples) > 100
         OR (sum_loss / samples) > 0.1
      GROUP BY endpoint
    SQL

    ClickHouse.connection.select_all(sql).map do |row|
      {
        endpoint: row["endpoint"],
        bad_locations: row["bad_locations"],
        bad_isps: row["bad_isps"]
      }
    end
  end

  # ----------------------------
  # Top issues: latency increase vs 1 hour baseline
  # ----------------------------
  def self.top_issues
    sql = <<~SQL
      SELECT isp, location,
            (recent.avg_latency - baseline.avg_latency) / NULLIF(baseline.avg_latency,0) * 100 AS latency_increase_pct
      FROM
        (SELECT location, isp, avg(sum_latency / samples) AS avg_latency
         FROM router_metrics_rollup
         WHERE ts_min >= subtractMinutes(now(), 5)
         GROUP BY location, isp) AS recent
      JOIN
        (SELECT location, isp, avg(sum_latency / samples) AS avg_latency
         FROM router_metrics_rollup
         WHERE ts_min >= subtractHours(now(), 1) AND ts_min < subtractMinutes(now(), 5)
         GROUP BY location, isp) AS baseline
      USING (location, isp)
      ORDER BY latency_increase_pct DESC
      LIMIT 5
    SQL

    ClickHouse.connection.select_all(sql)
  end
end
