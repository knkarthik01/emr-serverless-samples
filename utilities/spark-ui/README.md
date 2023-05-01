# Spark UI

You can use this Docker image to start the Apache Spark History Server (SHS) and view the Spark UI locally or using single node EMR on EC2 cluster.


## Pre-requisite

- Install Docker
- EMR on EC2 cluster (optional, if local is not used)

## Build Docker image

1. Clone this repository and change into the `utilities/spark-ui` directory.
```shell
git clone https://github.com/knkarthik01/emr-serverless-samples.git
cd emr-serverless-samples/utilities/spark-ui/
#  Edit py_web_server.py file locally with below changes. This will host a web service for S3 executor log files.
# 1/ <Bucket Name> with your bucket
# 2/ Point to your SSL certs or create one using `openssl req -newkey rsa:2048 -nodes -keyout key.pem -x509 -days 365 -out cert.pem`
```
2. Login to ECR
```shell
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 755674844232.dkr.ecr.us-east-1.amazonaws.com
```
3. Build the image
```shell
docker build -t emr/spark-ui .
```

## Start the Spark History Server

You can use a pair of AWS access key and secret key, or temporary AWS credentials. These credentials should have access to the S3 log bucket. If encryption is enabled for the logs stored in the S3 bucket, these credentials should have access to the necessary KMS key as well.

1. Set `LOG_DIR` to the location of your Spark eventlogs.

```shell
export S3_BUCKET="Replace with your Bucket Name. ex. bucket1"
export APPLICATION_ID="Replace with your EMR Serverless Application Id. ex. 00f7etp6vmd8cb09"
export JOB_RUN_ID="Replace with your EMR Serverless JobRunId. ex. 00f7eu9k4bhk1409"
export LOG_DIR=s3://${S3_BUCKET}/logs/applications/$APPLICATION_ID/jobs/$JOB_RUN_ID/sparklogs/
```

2. Set `EXECUTOR_LOG_PATH` to the location of your Executor log files.

```shell
export EXECUTOR_LOG_PATH=https://s3.console.aws.amazon.com/s3/object/${S3_BUCKET}/logs/applications/$APPLICATION_ID/jobs/$JOB_RUN_ID/{{CONTAINER_ID}}/{{FILE_NAME}}.gz
```

3. Set your AWS access key and secret key, and optionally session token.
  (This is an optional step if you are using EMR on EC2 single node master as Spark UI host. Host default credentials will be used)
  
```shell
export AWS_ACCESS_KEY_ID="ASIAxxxxxxxxxxxx"
export AWS_SECRET_ACCESS_KEY="yyyyyyyyyyyyyyy"
export AWS_SESSION_TOKEN="zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
```

4. Run the Docker image

```shell
docker run --rm -it \
    -p 18080:18080 \
    -e SPARK_HISTORY_OPTS="-Dspark.history.fs.logDirectory=$LOG_DIR -Dspark.history.custom.executor.log.url=$EXECUTOR_LOG_PATH -Dspark.hadoop.fs.s3.customAWSCredentialsProvider=com.amazonaws.auth.DefaultAWSCredentialsProviderChain" \
    -e AWS_REGION=us-east-1 \
    -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_SESSION_TOKEN \
    emr/spark-ui
```

### Option for multiple UI's on EMR Master (Port 18081 used as example):

```shell
docker run --rm -itd \
    -p 18083:18080 -p 9978:9977 \
    -e SPARK_HISTORY_OPTS="-Dspark.history.fs.logDirectory=$LOG_DIR -Dspark.hadoop.fs.s3.customAWSCredentialsProvider=com.amazonaws.auth.DefaultAWSCredentialsProviderChain" \
    -e AWS_REGION=us-east-1 \
    emr/spark-ui
```

5. Access the Spark UI via http://localhost:18080 OR http://<EMR_MASTER_IP>:<PORT_USED>

## Troubleshooting

You may get following exception during SHS startup.

1. **Issue/Exception:** com.amazon.ws.emr.hadoop.fs.shaded.com.amazonaws.services.s3.model.AmazonS3Exception: The ciphertext refers to a customer master key that does not exist, does not exist in this region, or you are not allowed to access. (Service: Amazon S3; Status Code: 403; Error Code: AccessDenied) 
   
   **Reason:** Given user credentials may not have the access to KMS key which is used to encrypt the logs in the S3 bucket. Add KMS policy with decrypt permission and verify.
2. **Issue/Exception:**  com.amazon.ws.emr.hadoop.fs.shaded.com.amazonaws.services.s3.model.AmazonS3Exception: Access Denied (Service: Amazon S3; Status Code: 403; Error Code: AccessDenied) 

   **Reason:** Given user credentials may not have the access the S3 bucket. Add S3 policy with read permission and verify.
