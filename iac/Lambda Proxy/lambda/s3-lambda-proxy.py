import os
import json
import boto3
import logging
import os
from botocore.exceptions import ClientError

# Example event
# {
#    "requestContext":{
#       "elb":{
#          "targetGroupArn":"arn:aws:elasticloadbalancing:us-east-1:441110004022:targetgroup/testapp-dev/3e18029c264e2d80"
#       }
#    },
#    "httpMethod":"GET",
#    "path":"/static/index.html",
#    "queryStringParameters":{
#
#    },
#    "headers":{
#       "accept":"*/*",
#       "host":"testapp-dev-1592232659.us-east-1.elb.amazonaws.com",
#       "user-agent":"curl/7.55.1",
#       "x-amzn-trace-id":"Root=1-614267f2-1fd32e163cbbc950249f51d5",
#       "x-forwarded-for":"31.49.139.83",
#       "x-forwarded-port":"80",
#       "x-forwarded-proto":"http"
#    },
#    "body":"",
#    "isBase64Encoded":false
# }

def lambda_handler(event, context):
    # print(event)

    # use 'AWS_REGION' environment variable from lambda built-in variables
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
        # Lambda output is limited to 1Mb when invoked from ALB.
        object_size = obj['ContentLength']
        object_size_in_mb = '{:.2f}'.format(object_size / 1024 / 1024)
        print(">> object_size: ", object_size)

        # Enable for large file support via pre signed URLs (disable for testing)
        enable_large_file_support = os.environ['ENABLE_LARGE_FILE_SUPPORT_VIA_PRESIGNED_URL'].lower() in ('true', '1', 't')
        if (enable_large_file_support):
            # Do not hardcode size (differs depending on the solution we select)
            if obj.get('ContentLength') >= 1048574:
                url = create_presigned_url(bucket_name, file_path)
                output = {
                    "statusCode": 302,
                    "headers": {
                        "Location": url
                    },
                }
                return output


        metadata = obj.get('ResponseMetadata')['HTTPHeaders']
        # Extract s3 mimetype (http headers)
        output['headers']['Content_Language'] = metadata.get('content-language')
        output['headers']['Cache_Control'] = metadata.get('cache-control')
        output['headers']['Content_Disposition'] = metadata.get('content-disposition')
        output['headers']['Content_Encoding'] = metadata.get('content-encoding')
        output['headers']['Content_Language'] = metadata.get('content-language')
        output['headers']['Content-Type'] = metadata['content-type']
        # Remove empty headers to avoid 502 errors from ALB.
        output['headers'] = {k: v for k, v in output['headers'].items() if v is not None}
        # output['body'] = obj.get()['Body'].read().encode('latin-1')
        body = obj.get('Body').read()
        output['body'] = body.decode("utf-8")
    except ClientError as e:
        output['body'] = json.dumps({'status': 'error', 'message': [str(e)]}, indent=4)
    except Exception as e:
        output['body'] = json.dumps({'status': 'unknown exception', 'message': [str(e)]}, indent=4)

    # print(output)
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