component accessors=true extends='aws' {

	property name='lambdaClient' type='com.amazonaws.services.lambda.AWSLambdaClient' getter=false setter=false;	

	public lambda function init(
		required string account,
		required string secret
	) {

		super.init(
			argumentCollection = arguments
		);

		variables.lambdaClient = CreateObject(
			'java',
			'com.amazonaws.services.lambda.AWSLambdaClient'
		).init(
			getCredentials()
		);

		return this;
	}

	private any function getLambdaClient() {
		return variables.lambdaClient;
	}

	public any function invoke(
		required string region,
		required string method,
		required struct payload
	) {

		// This is duplicating because setRegion is not threadsafe
		var rqLambdaClient = Duplicate( variables.lambdaClient );
		rqLambdaClient.setRegion(
			getRegion(
				arguments.region
			)
		);

		var invoke_request = CreateObject(
			'java',
			'com.amazonaws.services.lambda.model.InvokeRequest'
		)
			.init()
			.withFunctionName( arguments.method )
			.withInvocationType( 'RequestResponse' )
			.withPayload( 
				SerializeJSON(
					arguments.payload
				)
			);

		return 
			DeserializeJSON(
				ToString( 
					rqLambdaClient
						.invoke( invoke_request )
						.getPayload()
						.array() 
				) 
			);
	}

}