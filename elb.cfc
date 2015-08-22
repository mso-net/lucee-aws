component accessors=true extends='aws' {

	property name='ELBClient' type='com.amazonaws.services.elasticloadbalancing.AmazonElasticLoadBalancingClient' getter=false setter=false;	

	public elb function init(
		required string account,
		required string secret
	) {

		super.init(
			argumentCollection = arguments
		);

		variables.ELBClient = CreateObject(
			'java',
			'com.amazonaws.services.elasticloadbalancing.AmazonElasticLoadBalancingClient'
		).init(
			getCredentials()
		);

		return this;
	}

	private any function getELBClient() {
		return variables.ELBClient;
	}

	public function getConfig(
		required string region,
		required string name
	) {

		var describeLoadBalancerRequest = CreateObject(
				'java',
				'com.amazonaws.services.elasticloadbalancing.model.DescribeLoadBalancersRequest'
			)
			.init(
				[ arguments.name ]
			);

		// This is duplicating because setRegion is not threadsafe
		var rqELBClient = Duplicate( variables.ELBClient );
		rqELBClient.setRegion(
			getRegion(
				arguments.region
			)
		);


		try {

			describeLoadBalancerResponse = rqELBClient
				.describeLoadBalancers(
					describeLoadBalancerRequest
				)
				.getLoadBalancerDescriptions()
				[1];

			return {
				'CanonicalHostedZoneName': describeLoadBalancerResponse.getCanonicalHostedZoneName(),
				'CanonicalHostedZoneNameID': describeLoadBalancerResponse.getCanonicalHostedZoneNameID(),
				'DNSName': describeLoadBalancerResponse.getDNSName(),
				'LoadBalancerName': describeLoadBalancerResponse.getLoadBalancerName()
			};

		} catch ( com.amazonaws.services.elasticloadbalancing.model.LoadBalancerNotFoundException e ) {

			throw( type = 'elb.nonexistant' , detail = arguments.name );

		}

	}

}