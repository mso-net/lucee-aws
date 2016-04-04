component accessors=true {

	property name='credentials' type='com.amazonaws.auth.BasicAWSCredentials' getter=false setter=false;	
	property name='regions' type='com.amazonaws.regions.Regions' getter=false setter=false;

	public aws function init(
		required string account,
		required string secret
	) {
		variables.credentials = CreateAWSObject( 'auth.BasicAWSCredentials' ).init(
			arguments.account,
			arguments.secret
		);
		variables.regions = CreateAWSObject( 'regions.Regions' );
		return this;
	}

	private function CreateAWSObject(
		required string name
	) {
		return CreateObject(
			'java',
			'com.amazonaws.'&arguments.name
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