CREATE OR REPLACE VIEW consignmentapi_alb_4xx_errors_today_by_ip AS
SELECT client_ip,
       elb_status_code,
       count(*) as count
FROM consignmentapi_alb_logs
WHERE timestamp = date_format(current_date, '%Y/%m/%d')
  AND elb_status_code >= 400 and elb_status_code < 500 
GROUP BY  client_ip, elb_status_code
ORDER BY count DESC limit 10;
