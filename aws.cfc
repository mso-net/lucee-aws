component accessors=true {

	property name='credentials' type='com.amazonaws.auth.AWSCredentialsProvider' getter=false setter=false;	
	property name='regions' type='com.amazonaws.regions.Regions' getter=false setter=false;

	public aws function init(
		string account,
		string secret
	) {
		var potential_credentials = [
			CreateAWSObject( 'auth.InstanceProfileCredentialsProvider' )
				.init( false )
		];

		if ( 
			IsDefined( 'arguments.account' )
			&& IsDefined( 'arguments.secret' )
			&& arguments.account.len() > 0 
			&& arguments.secret.len() > 0 
		) {
			potential_credentials.add(
				CreateAWSObject( 'auth.AWSStaticCredentialsProvider' )
					.init( CreateAWSObject( 'auth.BasicAWSCredentials' ).init(
						arguments.account,
						arguments.secret
					) )
			);
		}

		var system = CreateObject( 'java' , 'java.lang.System' );
		var environment = system.getenv();

		if ( IsDefined( 'environment.AWS_PROFILE' ) && IsDefined( 'environment.AWS_CONFIG_FILE' ) ) {
			potential_credentials.add(
				CreateAWSObject( 'auth.profile.ProfileCredentialsProvider' )
					.init( environment.AWS_CONFIG_FILE , environment.AWS_PROFILE )
			);
		}

		variables.credentials = CreateAWSObject( 'auth.AWSCredentialsProviderChain' )
			.init( potential_credentials );

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
				'aws-java-sdk/aws-java-sdk-1.11.365.jar',
				'aws-java-sdk/aws-swf-build-tools-1.1.jar',
				'aws-java-sdk/commons-codec-1.10.jar',
				'aws-java-sdk/commons-logging-1.1.3.jar',
				'aws-java-sdk/freemarker-2.3.9.jar',
				'aws-java-sdk/httpclient-4.5.5.jar',
				'aws-java-sdk/httpcore-4.4.9.jar',
				'aws-java-sdk/ion-java-1.0.2.jar',
				'aws-java-sdk/jackson-annotations-2.6.0.jar',
				'aws-java-sdk/jackson-core-2.6.7.jar',
				'aws-java-sdk/jackson-databind-2.6.7.1.jar',
				'aws-java-sdk/jackson-dataformat-cbor-2.6.7.jar',
				'aws-java-sdk/javax.mail-api-1.4.6.jar',
				'aws-java-sdk/jmespath-java-1.11.365.jar',
				'aws-java-sdk/joda-time-2.8.1.jar',
				'aws-java-sdk/netty-buffer-4.1.17.Final.jar',
				'aws-java-sdk/netty-codec-4.1.17.Final.jar',
				'aws-java-sdk/netty-codec-http-4.1.17.Final.jar',
				'aws-java-sdk/netty-common-4.1.17.Final.jar',
				'aws-java-sdk/netty-handler-4.1.17.Final.jar',
				'aws-java-sdk/netty-resolver-4.1.17.Final.jar',
				'aws-java-sdk/netty-transport-4.1.17.Final.jar',
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