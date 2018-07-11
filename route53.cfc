component accessors=true extends='aws' {

	property name='elb' type='elb' getter=false setter=false;
	property name='myClient' type='services.route53.AmazonRoute53Client' getter=false setter=false;	

	public route53 function init(
		string account,
		string secret
	) {

		super.init(
			argumentCollection = arguments
		);

		variables.elb = new elb(
			argumentCollection = arguments
		);

		variables.myClient = CreateAWSObject( 'services.route53.AmazonRoute53Client' ).init(
			getCredentials()
		);

		return this;
	}

	private any function getHostedZone(
		required string domain
	) {

		var target_domain = arguments.domain & '.';

		var hosted_zones_request = CreateAWSObject( 'services.route53.model.ListHostedZonesByNameRequest' )
			.init()
			.withDNSName( target_domain )
			.withMaxItems( 1 );

		var hosted_zone = getMyClient()
			.listHostedZonesByName(hosted_zones_request)
			.HostedZones[1];

		if (
			hosted_zone.Name == target_domain
		) {
			return hosted_zone;
		}

		throw( type = 'route53.domain.nonexistant' , detail = arguments.domain );

	}

	private string function getHostedZoneID(
		required string domain
	) {

		return getHostedZone(
			domain = arguments.domain
		).Id.ListLast( '/' );

	}

	private any function getResourceRecordForSubdomain(
		required string subdomain
	) {
		var target_subdomain = arguments.subdomain & '.';

		var resource_record_sets_request = CreateAWSObject( 'services.route53.model.ListResourceRecordSetsRequest' )
			.init( 
				getHostedZoneID(
					domain = arguments.subdomain.ListDeleteAt( 1 , '.' )
				)
			)
			.withStartRecordName( target_subdomain );

		var resource_record_set = getMyClient()
			.listResourceRecordSets( resource_record_sets_request )
			.ResourceRecordSets[1];

		if (
			resource_record_set.Name == target_subdomain
		) {
			return resource_record_set;
		}

		throw( type = 'route53.subdomain.nonexistant' , detail = arguments.subdomain );

	}

	public boolean function isThereAHostedZoneForThisDomain(
		required string domain
	) {

		try {
			getHostedZone(
				domain = arguments.domain
			);
			return true;
		} catch ( route53.domain.nonexistant e ) {
			return false;
		}

	}

	public boolean function isThereAResourceRecordForThisSubdomain(
		required string subdomain
	) {

		try {
			getResourceRecordForSubdomain(
				subdomain = arguments.subdomain
			);
			return true;
		} catch ( route53.subdomain.nonexistant e ) {
			return false;
		}
		
	}

	public route53 function addAliasSubdomain(
		required string subdomain,
		required string elb_region,
		required string elb_name
	) {

		var resource_record_set = CreateAWSObject( 'services.route53.model.ResourceRecordSet' ).init(
			arguments.subdomain&'.',
			'A'
		);

		var elbToLinkTo = variables.elb.setRegion(
			region = arguments.elb_region
		).getConfig( 
			name = arguments.elb_name
		);

		var alias_target = CreateAWSObject( 'services.route53.model.AliasTarget' ).init(
			elbToLinkTo.CanonicalHostedZoneNameID,
			elbToLinkTo.CanonicalHostedZoneName
		);

		alias_target.setEvaluateTargetHealth( false );
		resource_record_set.setAliasTarget( alias_target );

		var change = CreateAWSObject( 'services.route53.model.Change' ).init(
			'UPSERT',
			resource_record_set
		);

		return changeResourceRecordSets(
			subdomain = arguments.subdomain,
			change = change
		);

	}

	public route53 function deleteSubdomain(
		required string subdomain
	) {

		try {
			var resource_record_set = getResourceRecordForSubdomain(
				subdomain = arguments.subdomain
			);
		} catch ( route53.subdomain.nonexistant e ) {
			throw('Unable to find resource record for subdomain '&arguments.subdomain);
		}

		var change = CreateAWSObject( 'services.route53.model.Change' ).init(
			'DELETE',
			resource_record_set
		);

		return changeResourceRecordSets(
			subdomain = arguments.subdomain,
			change = change
		);

	}

	private route53 function changeResourceRecordSets(
		required string subdomain,
		required change
	) {

		var tl_domain = arguments.subdomain.ListDeleteAt( 1 , '.' );

		var route53 = getMyClient();

		try {
			var hosted_zone_id = getHostedZoneID(
				domain = tl_domain
			);
		} catch ( route53.domain.nonexistant e ) {
			throw('Unable to find hosted zone for domain '&tl_domain);
		}

		var change_batch = CreateAWSObject( 'services.route53.model.ChangeBatch' ).init(
			[
				arguments.change
			]
		);

		var change_resource_record_sets_request = CreateAWSObject( 'services.route53.model.ChangeResourceRecordSetsRequest' ).init(
			hosted_zone_id,
			change_batch
		);

		route53.changeResourceRecordSets(
			change_resource_record_sets_request
		);
		
		return this;

	}

}