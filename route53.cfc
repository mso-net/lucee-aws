component accessors=true extends='aws' {

	property name='route53Client' type='com.amazonaws.services.route53.AmazonRoute53Client' getter=false setter=false;	

	public route53 function init(
		required string account,
		required string secret
	) {

		super.init(
			argumentCollection = arguments
		);

		variables.route53Client = CreateObject(
			'java',
			'com.amazonaws.services.route53.AmazonRoute53Client'
		).init(
			getCredentials()
		);

		return this;
	}

	private any function getRoute53Client() {
		return variables.route53Client;
	}

	private boolean function isSubdomainAlreadyDefined() {
		return false;
	}

	public route53 function linkSubdomainToELB(
		required string subdomain,
		required string hostedZoneID,
		required string target
	) {

		
		return this;
	}

	public route53 function deleteSubdomain(
		required string subdomain
	) {

		
		return this;
	}


}