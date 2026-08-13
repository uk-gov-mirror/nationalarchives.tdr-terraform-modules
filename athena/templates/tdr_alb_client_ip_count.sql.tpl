SELECT client_ip,
       count(client_ip) as count
FROM consignmentapi_alb_logs
WHERE timestamp = date_format(current_date, '%Y/%m/%d')
GROUP BY  client_ip
ORDER BY  count DESC limit 10;
