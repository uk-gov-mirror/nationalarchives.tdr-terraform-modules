SELECT *
FROM ${database_name}."tdr_cloudtrail_logs_mgmt"
WHERE
  eventsource = 'lambda.amazonaws.com' AND
  eventtime >= '2020-05-15' AND
  eventtime <= '2020-05-31'
ORDER BY sourceipaddress
LIMIT 20;