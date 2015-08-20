# lucee-aws

[![Build Status](https://travis-ci.org/mso-net/lucee-aws.svg?branch=master)](https://travis-ci.org/mso-net/lucee-aws)

Lucee extension to provide simpler access to common AWS commands through the AWS SDK.

## Installation

The easiest way to install this at present is to use CommandBox.  To install with CommandBox 2.1+ simply do the following.

1. `box install mso-net/lucee-aws --production`
2. Add the following to your Application.cfc
```
this.javaSettings = {
    loadPaths: [
        '/aws/aws-java-sdk/'
    ]
};
```

The contents of /aws-java-sdk are just the jar files from [http://sdk-for-java.amazonwebservices.com/latest/aws-java-sdk.zip](http://sdk-for-java.amazonwebservices.com/latest/aws-java-sdk.zip).  I am looking for a better way of handling this dependency but for now I'm concentrating on other tasks.

## Usage

### S3
Example for S3

```
s3 = new aws.s3( 
  account = 'account_id',
  secret = 'secret',
  bucket = 'bucket_name'
);

s3.getObject( 'path/to/something.ext' );
s3.putObject( 'path/to/something.ext' , 'data:image/png;base64,data_base64_encoded_here' );
s3.deleteObject( 'path/to/something.ext' );
```

## Additional reading

- [Strayegg lucee-aws blog](http://www.strayegg.com/tag/lucee-aws/)
- [AWS SDK for Java API documentation](http://docs.aws.amazon.com/AWSJavaSDK/latest/javadoc/index.html)
