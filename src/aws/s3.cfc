component accessors=true extends='aws' {

	property name='s3Client' type='com.amazonaws.services.s3.AmazonS3Client' getter=false setter=false;	
	property name='bucketACL' type='com.amazonaws.services.s3.model.AccessControlList' getter=false setter=false;	
	property name='bucket' type='string' getter=false setter=false;	
	property name='basepath' type='string' getter=false setter=false;	


	public s3 function init(
		required string account,
		required string secret,
		required string bucket,
		string basepath = ''
	) {

		super.init(
			argumentCollection = arguments
		);

		variables.s3Client = CreateObject(
			'java',
			'com.amazonaws.services.s3.AmazonS3Client'
		).init(
			getCredentials()
		);

		variables.bucket = arguments.bucket;
		variables.basepath = arguments.basepath;

		return this;
	}

	private any function getS3Client() {
		return variables.s3Client;
	}

	private any function getBucketACL() {
		if (
			!IsDefined( 'variables.bucketACL' )
		) {
			variables.bucketACL = getS3Client().getBucketACL( 
				variables.bucket 
			);
		}

		return variables.bucketACL;
	}

	public boolean function fileExists(
		required string key
	) {
		try {
			getObjectMetadata(
				key = arguments.key
			);
			return true;
		} catch ( s3.key.nonexistant ) {
			return false;
		}
	}

	public s3 function makeDirectory(
		required string key
	) {
		var object_metadata = CreateObject(
			'java',
			'com.amazonaws.services.s3.model.ObjectMetadata'
		).init();

		var empty_string = '';
		var empty_file = CreateObject( 
			'java',
			'java.io.ByteArrayInputStream'
		).init(
			empty_string.getBytes('UTF-8')
		);

		getS3Client().putObject(
			variables.bucket,
			getKeyFromPath(
				key = arguments.key
			),
			empty_file,
			object_metadata
		);

		getS3Client().setObjectAcl(
			variables.bucket,
			getKeyFromPath(
				key = arguments.key
			),
			getBucketACL()
		);

		return this;
	}

	public s3 function deleteObject(
		required string key
	) {
		getS3Client().deleteObject(
			variables.bucket,
			getKeyFromPath(
				key = arguments.key
			)
		);
		return this;
	}

	private any function getObjectMetadata(
		required string key
	) {
		var full_key = getKeyFromPath(
			key = arguments.key
		);
		
		try {
			return getS3Client().getObjectMetadata(
				variables.bucket,
				full_key
			);
		} catch( com.amazonaws.services.s3.model.AmazonS3Exception ) {
			throw( type = 's3.key.nonexistant' , detail = full_key );
		}
	}

	public string function getKeyFromPath(
		required string key
	) {
		return variables.basepath&arguments.key;
	}

	public struct function getObject(
		required string key
	) {
		var full_key = getKeyFromPath(
			key = arguments.key
		);

		try {
			var object = getS3Client().getObject(
				variables.bucket,
				full_key
			);
		} catch( com.amazonaws.services.s3.model.AmazonS3Exception ) {
			throw( type = 's3.key.nonexistant' , detail = full_key );
		}

		var metadata = object.getObjectMetadata();

		var input_stream = object.getObjectContent();
		var file_content = CreateObject( 'java' , 'java.io.ByteArrayOutputStream' ).init();

		while( true ) {
			var next = input_stream.read();
			if ( next < 0 ) {
				break;
			}
			file_content.write( next );
		}

		var response = {
			'metadata': {
				'length': metadata.getContentLength(),
				'type': metadata.getContentType()
			},
			'content': BinaryEncode( file_content.toByteArray() , 'Base64' )
		};

		return response;

	}

	public s3 function putObject(
		required string key,
		required string object
	) {
		if (
			!isDataStringValid(
				arguments.object
			)
		) {
			throw( type = 's3.object.unrecognisedformat' );
		}

		var encoded_data = arguments.object.ListLast( ';' );

		var binary_data = BinaryDecode( encoded_data.ListLast( ',' ) , encoded_data.ListFirst( ',' ) );
		var mime_type = arguments.object.ListFirst( ';' ).ListLast( ':' );

		var object_metadata = CreateObject(
			'java',
			'com.amazonaws.services.s3.model.ObjectMetadata'
		).init();
		object_metadata.setContentType( mime_type );

		var input_stream = CreateObject( 
			'java',
			'java.io.ByteArrayInputStream'
		).init(
			binary_data
		);
		
		getS3Client().putObject(
			variables.bucket,
			getKeyFromPath(
				key = arguments.key
			),
			input_stream,
			object_metadata
		);

		getS3Client().setObjectAcl(
			variables.bucket,
			getKeyFromPath(
				key = arguments.key
			),
			getBucketACL()
		);


		return this;
	}


	private boolean function isDataStringValid(
		required string object
	) {
		return (
			arguments.object.REFind( 'data:[^/]*/[^;]*;base64,[a-zA-Z0-9+/]+' )
		);
	}
}