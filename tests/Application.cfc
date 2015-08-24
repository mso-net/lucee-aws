component {
	this.name = 'lucee-aws_' & Hash( GetCurrentTemplatePath() );

	this.mappings[ '/testbox' ] = ExpandPath( '../testbox' );
	this.mappings[ '/tests'   ] = ExpandPath( './' );
	this.mappings[ '/aws'   ] = ExpandPath( '../' );

	this.javaSettings = {
		loadPaths: [
			'../aws-java-sdk/'
		]
	};

	public boolean function onApplicationStart() {

		var env = CreateObject( 'java' , 'java.lang.System' ).getenv();
			
	        application.aws_settings = {
	            'aws_accountid': '',	// self explanatory, DO NOT COMMIT TO A PUBLIC REPO
	            'aws_secretkey': '', 	// self explanatory, DO NOT COMMIT TO A PUBLIC REPO
	            'dynamodb_table': '', 	// a dynamodb table with some keys that i can't remember
	            'elb_name': '', 		// subdomain of a loadbalancer
	            'elb_region': '', 		// region that the elb_name is in
	            'lambda_method': '', 	// name of a lambda method that takes in {key1='',key2='',key3=''} and returns a concat string
	            'route53_tld': '', 		// a hosted zone domain name i.e. something.com
	            's3_bucket': ''  		// name of an s3 bucket
	        };
		application.aws_settings = {
			'aws_accountid': '',
			'aws_secretkey': '',
			'dynamodb_table': '',
			'elb_name': '',
			'elb_region': '',
			'lambda_method': '',
			'route53_tld': '',
			's3_bucket': ''
		};

		for( key in env ) {
			if (
				StructKeyExists( application.aws_settings , key )
			) {
				application.aws_settings[ key ] = env[ key ];
			}
		}

		return true;
	}

}
