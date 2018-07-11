component accessors=true {

	property name='credentials' type='com.amazonaws.auth.BasicAWSCredentials' getter=false setter=false;	
	property name='regions' type='com.amazonaws.regions.Regions' getter=false setter=false;

	public aws function init(
		string account,
		string secret
	) {
		if ( 
			IsDefined( 'arguments.account' )
			&&
			IsDefined( 'arguments.secret' )
			&&
			( arguments.account ?: '' ).len() > 0
			&&
			( arguments.secret ?: '' ).len() > 0
		) {
			variables.credentials = CreateAWSObject( 'auth.BasicAWSCredentials' ).init(
				arguments.account,
				arguments.secret
			);
		} else {
			variables.credentials = CreateAWSObject( 'auth.InstanceProfileCredentialsProvider' )
				.init( false );
		}


		variables.regions = CreateAWSObject( 'regions.Regions' );
		return this;
	}

	private function CreateAWSObject(
		required string name
	) {
		return CreateObject(
			'java',
			'com.amazonaws.'&arguments.name,
			[
				'aws-java-sdk/aspectjrt-1.8.2.jar',
				'aws-java-sdk/aspectjweaver.jar',
				'aws-java-sdk/aws-java-sdk-1.11.49.jar',
				'aws-java-sdk/commons-codec-1.9.jar',
				'aws-java-sdk/commons-logging-1.1.3.jar',
				'aws-java-sdk/freemarker-2.3.9.jar',
				'aws-java-sdk/httpclient-4.5.2.jar',
				'aws-java-sdk/httpcore-4.4.4.jar',
				'aws-java-sdk/ion-java-1.0.1.jar',
				'aws-java-sdk/jackson-annotations-2.6.0.jar',
				'aws-java-sdk/jackson-core-2.6.6.jar',
				'aws-java-sdk/jackson-databind-2.6.6.jar',
				'aws-java-sdk/jackson-dataformat-cbor-2.6.6.jar',
				'aws-java-sdk/javax.mail-api-1.4.6.jar',
				'aws-java-sdk/jmespath-java-1.0.jar',
				'aws-java-sdk/joda-time-2.8.1.jar',
				'aws-java-sdk/spring-beans-3.0.7.RELEASE.jar',
				'aws-java-sdk/spring-context-3.0.7.RELEASE.jar',
				'aws-java-sdk/spring-core-3.0.7.RELEASE.jar',
				'aws-java-sdk/spring-test-3.0.7.RELEASE.jar'
			]
		);
	}

	private function getCredentials() {
		return variables.credentials;
	}

	private function getRegions() {
		return variables.regions;
	}

	public function getRegion(
		string region = 'eu-west-1'
	) {
		return getRegions().fromName(
			arguments.region
		);
	}

	private any function getMyClient() {
		return variables.myClient;
	}

	public function setRegion(
		string region = 'eu-west-1'
	) {
		getMyClient().configureRegion(
			getRegion(
				arguments.region
			)
		);

		return this;
	}

}