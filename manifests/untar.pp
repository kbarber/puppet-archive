# Decompress and unpack the tarball at $source into the directory $name
#
# == Examples
#
# <b>1)</b> Download and untar the file at http://someweb.page/foo.tar.gz into the 
# directory /destination/directory:
#
#	archive::untar {"/desination/directory":
#		source => "http://someweb.page/foo.tar.gz"
#	}
#
# == Synopsis
#
#	archive::untar {"<dir_path>":
#		source => "<file_path>|<uri>",
#		[ compression => "xz|lzma|gz|bzip2|none", ]
#		[ rootdir => "<file_path>", ]
#	}
#
# == Parameters
#
# [<b>archive::untar{"<dir_path>":</b>]
#	Destination directory to unpack the tarball into
#
# [<b>source => "<file_path>|<uri>"</b>]
#	URI or path of the tarball
#
# [<b>compression => "xz|lzma|gz|bzip2|none"</b>]
#	Compression type. If not specified we will use the extension for the 
#	file path or URI specified in $source to guess this. None will assume
#	no compression at all.	
#
# [<b>rootdir => "<file_path>"</b>]
#	If this is not set, we assume that the rootdir inside the tarball is
#	the same as the basename of the path you supplied. If this is different
#	(for example the root dir is / in the archive) then please specify it
#	here. For a / based tarball use ".".
#
define archive::untar(
	$source,
	$compression = undef,
	$rootdir = undef
) {
	$resource_name = "archive::untar"

	# Work out the compression if it wasn't specified
	if($compression) {
		$_compression = $compression
	} else {
		$_compression = regsubst($source, '(.+)\.(.+)$', '\2', 'E')
	}
	

	# Watch switch is that compression?
	$compress_switch = $_compression ? {
		"bzip2" => "--bzip2",
		"gz" => "--gzip",
		"xz" => "--xs",
		"lzma" => "--lzma",
		"none" => ""
	}
	
	# Different methods for different source types. Lets work out which one
	# we are.
	$prot_prefix = regsubst($source, '^(puppet|http):(.+)$', '\1', 'E')
	
	case $prot_prefix {
		"http": {
			fail("${resource_name}: Fetchng from HTTP not currently supported")
		}
		default: {
		
			# 	
			$source_hash = sha1($source)
			$tmp_archive = "/tmp/puppet-archive_untar-${source_hash}"
			$exec_name = "${resource_name}-${name}"
			$tmp_archive_dir = "/tmp/puppet-archive_untar-${source_hash}-unpacked"
			
			file {$tmp_archive:
				source => $source,
				notify => Exec[$exec_name]
			}
			
			
			file {$tmp_archive_dir:
				ensure => directory,
				notify => Exec[$exec_name]
			}

				
			exec {$exec_name:
				command => "/bin/tar -xzf ${tmp_archive}",
				cwd => $tmp_archive_dir,
				refreshonly => true
			}
			
			if($rootdir) {
				$_rootdir = $rootdir
			} else {
				$_rootdir = inline_template("<%= File.basename(name) %>")				
			}
			file {$name:
				ensure => directory,
				recurse => true,
				source => "${tmp_archive_dir}/${_rootdir}",
				require => [ File[$tmp_archive_dir], Exec[$exec_name] ]
			}
			
		}
		#default: {
		#	# Assume local file?
		#}
	}	
}

