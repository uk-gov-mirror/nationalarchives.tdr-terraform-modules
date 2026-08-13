CREATE OR REPLACE VIEW "frontend_consignment_errors_today" AS 
SELECT t.consignment_id, t."time", t."request_url", t."request_verb", t."elb_status_code", t."target_status_code"
FROM (
  SELECT
    regexp_extract(request_url, 'consignment/([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})', 1) AS consignment_id,
    *
  FROM "tdr_security_logs_intg"."frontend_alb_logs"
  WHERE "timestamp" = date_format(current_date, '%Y/%m/%d')
  AND "elb_status_code" BETWEEN 400 AND 599
) t
WHERE t.consignment_id IS NOT NULL
ORDER BY t."time" DESC;
