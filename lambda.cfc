component accessors=true extends='aws' {

	property name='myClient' type='com.amazonaws.services.lambda.AWSLambdaClient' getter=false setter=false;	

	public lambda function init(
		string account,
		string secret,
		string region = 'eu-west-1'
	) {

		super.init(
			argumentCollection = arguments
		);

		variables.myClient = CreateAWSObject( 'services.lambda.AWSLambdaClientBuilder' )
			.standard()
			.withCredentials( getCredentials() )
			.build();

		if (
			StructKeyExists( arguments , 'region' ) 
		) {
			setRegion( region = arguments.region );
		}

		return this;
	}

	public any function invoke(
		required string method,
		required struct payload,
		string invocationType = 'RequestResponse'
	) {

		var invoke_request = CreateAWSObject( 'services.lambda.model.InvokeRequest' )
			.init()
			.withFunctionName( arguments.method )
			.withInvocationType( arguments.invocationType )
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