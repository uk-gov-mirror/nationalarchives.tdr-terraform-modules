CREATE EXTERNAL TABLE IF NOT EXISTS tdr_flowlogs_mgmt_jenkins (
  version int,
  account string,
  interfaceid string,
  sourceaddress string,
  destinationaddress string,
  sourceport int,
  destinationport int,
  protocol int,
  numpackets int,
  numbytes bigint,
  starttime int,
  endtime int,
  action string,
  logstatus string
)
PARTITIONED BY (`date` date)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ' '
LOCATION 's3://tdr-log-data-mgmt/flowlogs/mgmt/jenkins/'
TBLPROPERTIES ("skip.header.line.count"="1");
