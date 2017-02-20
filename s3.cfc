component accessors=true extends='aws' {

	property name='myClient' type='com.amazonaws.services.s3.AmazonS3Client' getter=false setter=false;	
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

		variables.myClient = CreateAWSObject( 'services.s3.AmazonS3Client' ).init(
			getCredentials()
		);

		variables.bucket = arguments.bucket;
		variables.basepath = arguments.basepath;

		return this;
	}
	
	private any function getBucketACL() {
		if (
			!IsDefined( 'variables.bucketACL' )
		) {
			variables.bucketACL = getMyClient().getBucketACL( 
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
	
	public array function directoryList(
		string directory = ''
	) {

		var array_of_keys = [];

		var directory_with_trailing_slash = arguments.directory;

		if ( 
			Len( directory_with_trailing_slash ) > 0 
			&& 
			Right( arguments.directory , 1 ) != '/'
		) {
			directory_with_trailing_slash &= '/';
		}

		var full_path = variables.basepath & directory_with_trailing_slash;
		var strip_basepath = ( Len( variables.basepath ) > 0 );

		var object_listing = getMyClient().listObjects( variables.bucket, full_path );

		do {
			for (var summary in object_listing.getObjectSummaries() ) {

				var key = summary.getKey();
				if ( strip_basepath ) {
					key = REReplace( key , '^' & variables.basepath , '' );
				}

				var name = REReplace( key , '^' & directory_with_trailing_slash , '' );

				if ( Len( name ) > 0 ) {
					array_of_keys.add({
						'key': key,
						'name': name,
						'type': ( Right(key,1) == '/' )?'folder':'item',
						'size': summary.getSize(),
						'lastModified': summary.getLastModified()
					});				
				}
			}

			getMyClient().listNextBatchOfObjects(object_listing);				 	

		} while ( object_listing.isTruncated() );

		return array_of_keys;
	}

	public s3 function copyObject(
		required string source,
		required string destination
	) {

		// Does the source file exists?
		getObjectMetadata(
			key = arguments.source
		);

		// Is it trying to copy over itself?
		if ( arguments.source == arguments.destination ) {
			return this;
		}

		getMyClient().copyObject(
			variables.bucket,
			getKeyFromPath(
				key = arguments.source
			),
			variables.bucket,
			getKeyFromPath(
				key = arguments.destination
			)
		);

		return this;
	}

	public s3 function moveObject(
		required string source,
		required string destination
	) {

		copyObject(
			source = arguments.source,
			destination = arguments.destination
		);

		// Do I need to delete the original?
		if ( arguments.source != arguments.destination ) {
			deleteObject(
				key = arguments.source
			);
		}

		return this;
	}

	public s3 function makeDirectory(
		required string key
	) {
		var object_metadata = CreateAWSObject( 'services.s3.model.ObjectMetadata' ).init();

		var empty_string = '';
		var empty_file = CreateObject( 
			'java',
			'java.io.ByteArrayInputStream'
		).init(
			empty_string.getBytes('UTF-8')
		);

		getMyClient().putObject(
			variables.bucket,
			getKeyFromPath(
				key = arguments.key
			),
			empty_file,
			object_metadata
		);

		getMyClient().setObjectAcl(
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
		getMyClient().deleteObject(
			variables.bucket,
			getKeyFromPath(
				key = arguments.key
			)
		);
		return this;
	}

	public struct function getObjectMetadata(
		required string key
	) {
		var full_key = getKeyFromPath(
			key = arguments.key
		);
		
		try {

			var metadata = getMyClient().getObjectMetadata(
				variables.bucket,
				full_key
			);

			return {
				'length': metadata.getContentLength(),
				'type': metadata.getContentType()
			};
			
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
			var object = getMyClient().getObject(
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
		required string object,
		string acl = 'inheritFromBucket'
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

		var object_metadata = CreateAWSObject( 'services.s3.model.ObjectMetadata' ).init();
		object_metadata.setContentType( mime_type );

		var input_stream = CreateObject( 
			'java',
			'java.io.ByteArrayInputStream'
		).init(
			binary_data
		);
		
		getMyClient().putObject(
			variables.bucket,
			getKeyFromPath(
				key = arguments.key
			),
			input_stream,
			object_metadata
		);

		return setObjectAcl(
			key = arguments.key,
			acl = arguments.acl
		);
	}

	public s3 function setObjectAcl(
		required string key,
		required string acl
	) {

		var acl = '';

		switch( arguments.acl ) {
			case 'AuthenticatedRead':
			case 'BucketOwnerFullControl':
			case 'BucketOwnerRead':
			case 'LogDeliveryWrite':
			case 'Private':
			case 'PublicRead':
			case 'PublicReadWrite':

				acl = CreateAWSObject( 'services.s3.model.CannedAccessControlList' )
					.valueOf( arguments.acl );

				break;

			case 'inheritFromBucket':
				acl = getBucketACL();
				break;

			default:
				throw( type = 's3.acl.unrecognisedLevel' , detail = arguments.acl );
				break;
		}

		getMyClient().setObjectAcl(
			variables.bucket,
			getKeyFromPath(
				key = arguments.key
			),
			acl
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