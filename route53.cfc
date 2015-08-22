component accessors=true extends='aws' {

	property name='elb' type='elb' getter=false setter=false;
	property name='route53Client' type='com.amazonaws.services.route53.AmazonRoute53Client' getter=false setter=false;	

	public route53 function init(
		required string account,
		required string secret
	) {

		super.init(
			argumentCollection = arguments
		);

		variables.elb = new elb(
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

	private any function getHostedZoneForDomain(
		required string domain
	) {

		var target_domain = arguments.domain & '.';

		var hosted_zones = getRoute53Client()
			.listHostedZones()
			.HostedZones;

		for( var hosted_zone in hosted_zones ) {
			if (
				hosted_zone.Name == target_domain
			) {
				return hosted_zone;
			}
		}

		throw( type = 'route53.domain.nonexistant' , detail = arguments.domain );

	}

	public route53 function addAliasSubdomain(
		required string subdomain,
		required string elb_region,
		required string elb_name
	) {

		return changeAliasSubdomain(
			action = 'UPSERT',
			subdomain = arguments.subdomain,
			elb_region = arguments.elb_region,
			elb_name = arguments.elb_name
		);

	}

	public route53 function deleteAliasSubdomain(
		required string subdomain,
		required string elb_region,
		required string elb_name
	) {

		return changeAliasSubdomain(
			action = 'DELETE',
			subdomain = arguments.subdomain,
			elb_region = arguments.elb_region,
			elb_name = arguments.elb_name
		);

	}

	public route53 function changeAliasSubdomain(
		required string subdomain,
		required string elb_region,
		required string elb_name,
		required string action
	) {

		var full_domain = arguments.subdomain;
		var sub_domain = ListFirst( full_domain , '.' );
		var tl_domain = ListDeleteAt( full_domain , 1 , '.' );

		var route53 = getRoute53Client();

		try {
			var hosted_zone = getHostedZoneForDomain(
				domain = tl_domain
			);
		} catch ( route53.domain.nonexistant e ) {
			throw('Unable to find hosted zone for domain '&tl_domain);
		}

		var hosted_zone_id = hosted_zone.Id;

		var resource_record_set = CreateObject(
			'java',
			'com.amazonaws.services.route53.model.ResourceRecordSet'
		).init(
			full_domain&'.',
			'A'
		);

		var elbToLinkTo = variables.elb.getConfig( 
			region = arguments.elb_region,
			name = arguments.elb_name
		);

		var alias_target = CreateObject(
			'java',
			'com.amazonaws.services.route53.model.AliasTarget'
		).init(
			elbToLinkTo.CanonicalHostedZoneNameID,
			elbToLinkTo.CanonicalHostedZoneName
		);

		alias_target.setEvaluateTargetHealth( false );
		resource_record_set.setAliasTarget( alias_target );

		var change = CreateObject(
			'java',
			'com.amazonaws.services.route53.model.Change'
		).init(
			arguments.action,
			resource_record_set
		);

		var change_batch = CreateObject(
			'java',
			'com.amazonaws.services.route53.model.ChangeBatch'
		).init(
			[
				change
			]
		);

		var change_resource_record_sets_request = CreateObject(
			'java',
			'com.amazonaws.services.route53.model.ChangeResourceRecordSetsRequest'
		).init(
			hosted_zone_id,
			change_batch
		);

		route53.changeResourceRecordSets(
			change_resource_record_sets_request
		);
		
		return this;
	}

}