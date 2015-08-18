# lucee-aws
Lucee extension to provide simpler access to common AWS commands through the AWS SDK

At present the cfcs are available in /src/aws/, once they have been cleaned up and organised properly then proper examples will follow.

To use these you will need to have installed the AWS Java SDK, jars available from [http://sdk-for-java.amazonwebservices.com/latest/aws-java-sdk.zip](http://sdk-for-java.amazonwebservices.com/latest/aws-java-sdk.zip)

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

Travis skeleton based on https://github.com/DominicWatson/travis-testbox-skeleton