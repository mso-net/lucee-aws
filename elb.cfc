component accessors=true extends='aws' {

	property name='myClient' type='com.amazonaws.services.elasticloadbalancing.AmazonElasticLoadBalancingClient' getter=false setter=false;	

	public elb function init(
		string account,
		string secret,
		string region = 'eu-west-1'
	) {

		super.init(
			argumentCollection = arguments
		);

		variables.myClient = CreateAWSObject( 'services.elasticloadbalancing.AmazonElasticLoadBalancingClientBuilder' )
			.standard()
			.withRegion( arguments.region )
			.withCredentials( getCredentials() )
			.build();
			
		return this;
	}

	public function getConfig(
		required string name
	) {

		var describeLoadBalancerRequest = CreateAWSObject( 'services.elasticloadbalancing.model.DescribeLoadBalancersRequest' ).init(
			[ arguments.name ]
		);

		try {

			describeLoadBalancerResponse = getMyClient()
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