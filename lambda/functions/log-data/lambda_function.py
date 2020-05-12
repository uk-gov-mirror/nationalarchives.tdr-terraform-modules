import boto3
import ast
import json
import os
from urllib.parse import unquote
print('Loading function')

def lambda_handler(event, context):
    s3 = boto3.client('s3')
    sns_message = ast.literal_eval(event['Records'][0]['Sns']['Message'])
    target_bucket = os.environ['TARGET_S3_BUCKET']
    source_bucket = str(sns_message['Records'][0]['s3']['bucket']['name'])
    key = str(unquote(sns_message['Records'][0]['s3']['object']['key']))
    copy_source = {'Bucket':source_bucket, 'Key':key}

    sts_connection = boto3.client('sts')
    acct_b = sts_connection.assume_role(
        RoleArn="arn:aws:iam::328920706552:role/TDRLogDataCrossAccountRoleMgmt",
        RoleSessionName="cross_acct_lambda"
    )

    ACCESS_KEY = acct_b['Credentials']['AccessKeyId']
    SECRET_KEY = acct_b['Credentials']['SecretAccessKey']
    SESSION_TOKEN = acct_b['Credentials']['SessionToken']

    # create service client using the assumed role credentials, e.g. S3
    client = boto3.client(
        's3',
        aws_access_key_id=ACCESS_KEY,
        aws_secret_access_key=SECRET_KEY,
        aws_session_token=SESSION_TOKEN,
    )

    print('Copying %s from bucket %s to bucket %s ...' % (key, source_bucket, target_bucket))
    s3.copy_object(Bucket=target_bucket, Key=key, CopySource=copy_source)