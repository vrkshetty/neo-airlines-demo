
Some of Services configured manually due to time constrain
Create ECR Registry
Create S3 Bucket for Artifacts
Create IAM User AWS Credentials with write access to S3 for Jenkins add it in Jenkins Global Credentials with name 'aws-credentials'


```
apiVersion: v1
data:
  config.json: "{\n\t\"auths\": {\n\t\t\"https://index.docker.io/v1/\": {\n\t\t\t\"auth\":
    \"dnJrc2hldHR5OlBhbGlvMS4y\"\n\t\t}\n\t},\n\t\"HttpHeaders\": {\n\t\t\"User-Agent\":
    \"Docker-Client/19.03.5 (linux)\"\n\t}\n}"
kind: ConfigMap
metadata:
  creationTimestamp: "2020-01-28T13:44:58Z"
  name: docker-config4
  namespace: tools
  resourceVersion: "173868"
  selfLink: /api/v1/namespaces/tools/configmaps/docker-config4
  uid: 5f9510f5-41d4-11ea-a630-02096b2c6720
  ```
  IAM Role AWS Credentials with ECR ReadWrite Access

  ```
  apiVersion: v1
data:
  aws.credentials: xxxxxxxxx
kind: Secret
metadata:
  creationTimestamp: "2020-01-28T14:46:15Z"
  name: aws-secret
  namespace: tools
  resourceVersion: "180373"
  selfLink: /api/v1/namespaces/tools/secrets/aws-secret
  uid: ef9ee8bd-41dc-11ea-8558-06614d534ff4
type: Opaque
```
