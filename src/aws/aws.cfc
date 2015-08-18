component accessors=true {

	property name='credentials' type='com.amazonaws.auth.BasicAWSCredentials' getter=false setter=false;	
	property name='regions' type='com.amazonaws.regions.Regions' getter=false setter=false;	

	public aws function init(
		required string account,
		required string secret
	) {

		variables.credentials = CreateObject(
			'java',
			'com.amazonaws.auth.BasicAWSCredentials'
		).init(
			arguments.account,
			arguments.secret
		);

		variables.regions = CreateObject(
			'java',
			'com.amazonaws.regions.Regions'
		);

		return this;
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

}