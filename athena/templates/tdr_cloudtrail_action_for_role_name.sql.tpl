SELECT
       eventime,
       eventname,
       eventsource,
       errorcode,
       requestparameters,
       useridentity.principalid,
       useridentity.sessioncontext.sessionissuer.username
FROM tdr_cloudtrail_logs t
         CROSS JOIN UNNEST(t.resources) unnested (resources_entry)
WHERE useridentity.sessioncontext.sessionissuer.username = 'TDRTerraformRoleIntg'
  AND timestamp = date_format(current_date, '%Y/%m/%d')
ORDER BY eventtime desc
