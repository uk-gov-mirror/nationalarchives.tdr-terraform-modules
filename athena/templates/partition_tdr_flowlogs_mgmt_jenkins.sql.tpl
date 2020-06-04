ALTER TABLE tdr_flowlogs_mgmt_jenkins
ADD PARTITION (`date` = '2020-06-04')
location 's3://tdr-log-data-mgmt/flowlogs/mgmt/jenkins/AWSLogs/${account_id}/vpcflowlogs/eu-west-2/2020/06/04';