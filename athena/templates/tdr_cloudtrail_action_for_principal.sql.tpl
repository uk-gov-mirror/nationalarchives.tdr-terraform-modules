SELECT eventname,
       eventsource,
       requestparameters,
       useridentity.principalid,
       useridentity.sessioncontext.sessionissuer.username,
       eventtime
FROM tdr_cloudtrail_logs t
         CROSS JOIN UNNEST(t.resources) unnested (resources_entry)
WHERE useridentity.principalid LIKE '%:User.Name@nationalarchives.gov.uk'
  AND timestamp = date_format(current_date, '%Y/%m/%d')
ORDER BY eventtime desc
