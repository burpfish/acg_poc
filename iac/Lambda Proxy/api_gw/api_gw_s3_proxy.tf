resource "aws_api_gateway_rest_api" "s3_proxy" {
  body = jsonencode(

  {
    "swagger": "2.0",
    "info": {
      "version": "2021-09-27T12:35:50Z",
      "title": "test"
    },
    "schemes": [
      "https"
    ],
    "paths": {
      "/static/{object}": {
        "get": {
          "produces": [
            "application/json"
          ],
          "parameters": [
            {
              "name": "object",
              "in": "path",
              "required": true,
              "type": "string"
            }
          ],
          "responses": {
            "200": {
              "description": "200 response",
              "schema": {
                "$ref": "#/definitions/Empty"
              },
              "headers": {
                "Content-Length": {
                  "type": "string"
                },
                "Timestamp": {
                  "type": "string"
                },
                "Content-Type": {
                  "type": "string"
                }
              }
            },
            "400": {
              "description": "400 response"
            },
            "500": {
              "description": "500 response"
            }
          },
          "x-amazon-apigateway-integration": {
            "type": "aws",
            "credentials": aws_iam_role.apigw_s3.arn,
            "httpMethod": "GET",
            "uri": "arn:aws:apigateway:us-east-1:s3:path/${var.static_content.bucket.id}/{object}",
            "responses": {
              "4\\d{2}": {
                "statusCode": "400"
              },
              "default": {
                "statusCode": "200",
                "responseParameters": {
                  "method.response.header.Content-Type": "integration.response.header.Content-Type",
                  "method.response.header.Content-Length": "integration.response.header.Content-Length",
                  "method.response.header.Timestamp": "integration.response.header.Timestamp"
                }
              },
              "5\\d{2}": {
                "statusCode": "500"
              }
            },
            "requestParameters": {
              "integration.request.path.object": "method.request.path.object"
            },
            "passthroughBehavior": "when_no_match"
          }
        }
      }
    },
    "definitions": {
      "Empty": {
        "type": "object",
        "title": "Empty Schema"
      }
    }
  }
  )

  name = "proxy_s3"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "s3_proxy" {
  rest_api_id = aws_api_gateway_rest_api.s3_proxy.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.s3_proxy.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "s3_proxy" {
  deployment_id = aws_api_gateway_deployment.s3_proxy.id
  rest_api_id   = aws_api_gateway_rest_api.s3_proxy.id
  stage_name    = "v1"
}