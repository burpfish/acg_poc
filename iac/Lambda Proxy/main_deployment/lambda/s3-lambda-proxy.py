import os
import json
import boto3
import logging
import os
from botocore.exceptions import ClientError
import base64
import gzip
import tempfile
import gzip

# Example event
# {
#     "requestContext":{
#       "elb":{
#          "targetGroupArn":"arn:aws:elasticloadbalancing:us-east-1:441110004022:targetgroup/testapp-dev/3e18029c264e2d80"
#       }
#     },
#     "httpMethod":"GET",
#     "path":"/static/index.html",
#     "queryStringParameters":{

#     },
#     "headers":{
#       "accept":"*/*",
#       "host":"testapp-dev-1592232659.us-east-1.elb.amazonaws.com",
#       "user-agent":"curl/7.55.1",
#       "x-amzn-trace-id":"Root=1-614267f2-1fd32e163cbbc950249f51d5",
#       "x-forwarded-for":"31.49.139.83",
#       "x-forwarded-port":"80",
#       "x-forwarded-proto":"http"
#     },
#     "body":"",
#     "isBase64Encoded":false
# }

def lambda_handler(event, context):
    enable_large_file_support = os.environ['ENABLE_LARGE_FILE_SUPPORT_VIA_PRESIGNED_URL'].lower() in ('true', '1', 't')
    compress_response = os.environ['COMPRESS_RESPONSE'].lower() in ('true', '1', 't')
    aws_region = os.environ['AWS_REGION']
    bucket_name = os.environ['BUCKET_NAME']

    path = event['path'].split('/')
    file_path = '/'.join(path[2:])

    output = {
        "isBase64Encoded": False,
        "statusCode": 200,
        "headers": {
         "Content-Type": 'text/html'
        },
    }

    if event['headers'] != None and 'user-agent' in event['headers'] and event['headers']['user-agent'] == 'ELB-HealthChecker/2.0':
            output['body'] = 'Response to HealthCheck'
            return output

    s3 = boto3.resource('s3', region_name=aws_region)
    obj = s3.Object(bucket_name, file_path)

    try:
        obj = obj.get()
    except Exception as e:
        return {
            "statusCode": 404
        }

    try:
        object_size = obj['ContentLength']
        object_size_in_mb = '{:.2f}'.format(object_size / 1024 / 1024)
        print(">> Uncompressed response length: ", object_size)

        data = obj.get('Body').read()

        # Lambda output is limited to 1Mb when invoked from ALB - Enable for large file support via pre signed URLs
        if (enable_large_file_support):
            # Do not hardcode size (differs depending on the solution we select)
            if object_size >= 1048574:
                print(">> Response exceeds ALB-Lambda limit, returning presigned URL redirect")
                url = create_presigned_url(bucket_name, file_path)
                output = {
                    "statusCode": 302,
                    "headers": {
                        "Location": url
                    },
                }
                return output

        if (compress_response):
            data = gzip.compress(data)
            object_size = len(data)
            print(">> Compressed response length: ", object_size)

            output['body']=(base64.b64encode(data).decode('utf-8'))
            output['headers']['Content-Encoding'] = 'gzip'
            output['isBase64Encoded'] = True
        else:
            output['body'] = data.decode("utf-8")

        metadata = obj.get('ResponseMetadata')['HTTPHeaders']
        output['headers']['Content_Language'] = metadata.get('content-language')
        output['headers']['Cache_Control'] = metadata.get('cache-control')
        output['headers']['Content_Disposition'] = metadata.get('content-disposition')
        output['headers']['Content_Encoding'] = metadata.get('content-encoding')
        output['headers']['Content_Language'] = metadata.get('content-language')
        output['headers']['Content-Type'] = metadata['content-type']

        # Remove empty headers to avoid 502 errors from ALB.
        output['headers'] = {k: v for k, v in output['headers'].items() if v is not None}

    except ClientError as e:
        output['body'] = json.dumps({'status': 'error', 'message': [str(e)]}, indent=4)
    except Exception as e:
        output['body'] = json.dumps({'status': 'unknown exception', 'message': [str(e)]}, indent=4)


    return output

def create_presigned_url(bucket_name, object_name, expiration=3600):
    """Generate a presigned URL to share an S3 object

    :param bucket_name: string
    :param object_name: string
    :param expiration: Time in seconds for the presigned URL to remain valid
    :return: Presigned URL as string. If error, returns None.
    """

    # Generate a presigned URL for the S3 object
    s3_client = boto3.client('s3')
    try:
        response = s3_client.generate_presigned_url('get_object',
                                                    Params={'Bucket': bucket_name,
                                                            'Key': object_name},
                                                    ExpiresIn=expiration)
    except ClientError as e:
        logging.error(e)
        return None

    # The response contains the presigned URL
    return response