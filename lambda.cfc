component accessors=true extends='aws' {

	property name='myClient' type='com.amazonaws.services.lambda.AWSLambdaClient' getter=false setter=false;	

	public lambda function init(
		required string account,
		required string secret,
		string region = 'eu-west-1'
	) {

		super.init(
			argumentCollection = arguments
		);

		variables.myClient = CreateObject(
			'java',
			'com.amazonaws.services.lambda.AWSLambdaClient'
		).init(
			getCredentials()
		);

		if (
			StructKeyExists( arguments , 'region' ) 
		) {
			setRegion( region = arguments.region );
		}

		return this;
	}

	public any function invoke(
		required string method,
		required struct payload
	) {

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
					getMyClient()
						.invoke( invoke_request )
						.getPayload()
						.array() 
				) 
			);
	}

}