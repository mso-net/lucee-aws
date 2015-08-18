component {
	this.name = 'lucee-aws_' & Hash( GetCurrentTemplatePath() );

	this.mappings[ '/testbox' ] = ExpandPath( './testbox' );
	this.mappings[ '/tests'   ] = ExpandPath( './tests' );
	this.mappings[ '/aws'   ] = ExpandPath( '../src' );

	public void function onRequest( required string requestedTemplate ) {
		include template=arguments.requestedTemplate;
	}
}