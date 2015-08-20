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
			'aws_accountid': '',
			'aws_secretkey': '',
			'dynamodb_table': '',
			'route53_alias_hostedzoneid': '',
			'route53_alias_target': '',
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