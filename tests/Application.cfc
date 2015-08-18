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

	public void function onRequest( required string requestedTemplate ) {
		include template=arguments.requestedTemplate;
	}
}