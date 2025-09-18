# app/services/rca_detector.rb
class RcaDetector
  def self.run
    detect_latency_spikes
    detect_packet_loss
    detect_http_failures
  end

  private

  def self.client
    @client ||= ClickHouse.connection
  end

  def self.find_or_create_event(attrs)
    existing = RcaEvent.where(
      status: "open",
      location: attrs[:location],
      isp: attrs[:isp],
      endpoint: attrs[:endpoint],
      metric_type: attrs[:metric_type]
    ).first

    if existing.present?
      # Optionally update the existing event with latest value/message
      existing.update(value: attrs[:value], message: attrs[:message], ts: Time.current)
    else
      RcaEvent.create!(attrs)
    end
  end

  # ------------------------
  # Latency Spike Detection
  # ------------------------
  def self.detect_latency_spikes
    sql = <<~SQL
      SELECT
          location,
          isp,
          endpoint,
          avg_latency AS recent_avg
      FROM router_metrics_rollup
      WHERE ts_min >= subtractMinutes(now(), 5)
      AND avg_latency > 100
      ORDER BY avg_latency DESC
      LIMIT 20
    SQL

    client.select_all(sql).each do |row|
      baseline_value = row["recent_avg"]
      find_or_create_event(
        ts: Time.current,
        location: row["location"],
        isp: row["isp"],
        endpoint: row["endpoint"],
        metric_type: "latency",
        value: row["recent_avg"],
        baseline: baseline_value,
        severity: "warning",
        message: "Latency spike: #{row['recent_avg']}ms vs baseline #{baseline_value}ms",
        status: "open"
      )
    end
  end

  # ------------------------
  # Packet Loss Detection
  # ------------------------
  def self.detect_packet_loss
    sql = <<~SQL
      SELECT
          location,
          isp,
          endpoint,
          packet_loss_count
      FROM router_metrics_rollup
      WHERE ts_min >= subtractMinutes(now(), 5)
      AND packet_loss_count > 0
      ORDER BY packet_loss_count DESC
      LIMIT 20
    SQL

    client.select_all(sql).each do |row|
      value = row["packet_loss_count"]
      find_or_create_event(
        ts: Time.current,
        location: row["location"],
        isp: row["isp"],
        endpoint: row["endpoint"],
        metric_type: "loss",
        value: value,
        baseline: 0,
        severity: "critical",
        message: "High packet loss: #{value}%",
        status: "open"
      )
    end
  end

  # ------------------------
  # HTTP Failures Detection
  # ------------------------
  def self.detect_http_failures
    sql = <<~SQL
      SELECT
          location,
          isp,
          endpoint,
          countIf(http_status >= 500) AS failures
      FROM router_metrics_raw
      WHERE ts >= subtractMinutes(now(), 5)
      GROUP BY location, isp, endpoint
      HAVING failures > 3
    SQL

    client.select_all(sql).each do |row|
      value = row["failures"]
      find_or_create_event(
        ts: Time.current,
        location: row["location"],
        isp: row["isp"],
        endpoint: row["endpoint"],
        metric_type: "http_status",
        value: value,
        baseline: 200,
        severity: "critical",
        message: "Endpoint down (HTTP failures > 3 in 5m)",
        status: "open"
      )
    end
  end
end
