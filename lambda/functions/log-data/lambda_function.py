import boto3
import ast
import os
from urllib.parse import unquote
from base64 import b64decode
print('Loading function')

def lambda_handler(event, context):
    s3 = boto3.client('s3')
    sns_message = ast.literal_eval(event['Records'][0]['Sns']['Message'])
    target_bucket = boto3.client('kms').decrypt(CiphertextBlob=b64decode(os.environ['TARGET_S3_BUCKET']), EncryptionContext={'LambdaFunctionName': os.environ['AWS_LAMBDA_FUNCTION_NAME']} )['Plaintext'].decode('utf-8')
    source_bucket = str(sns_message['Records'][0]['s3']['bucket']['name'])
    key = str(unquote(sns_message['Records'][0]['s3']['object']['key']))
    copy_source = {'Bucket':source_bucket, 'Key':key}

    print('Copying %s from bucket %s to bucket %s ...' % (key, source_bucket, target_bucket))
    s3.copy_object(Bucket=target_bucket, Key=key, CopySource=copy_source, ACL='bucket-owner-full-control')