component accessors=true extends='aws' {

	property name='SESClient' type='com.amazonaws.services.lambda.AWSLambdaClient' getter=false setter=false;	

	public ses function init(
		required string account,
		required string secret
	) {

		super.init(
			argumentCollection = arguments
		);

		variables.SESClient = CreateObject(
			'java',
			'com.amazonaws.services.simpleemail.AmazonSimpleEmailServiceClient'
		).init(
			getCredentials()
		);

		return this;
	}

	private any function getSESClient() {
		return variables.SESClient;
	}

}