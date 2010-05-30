# Pack and compress a tarball at $name from $source directory.
#
# == Examples
#
# <b>1)</b> Create a tar archive at /foo/mytarball.tar.gz from directory /tar/me.
# By default it will be compressed using 
#
#	archive::tar {"/foo/mytarball.tar.gz":
#		source => "/tar/me"
#	}
#	
# == Synopsis
#
#	archive::tar {"<file_path>":
#		source => "<dir_path>",
#		[ compression => "[xz|lzma|gz|bzip2]", ]
#	}
#
# == Parameters
#
# [<b>archive::tar{"<file_path>":</b>]
#	Destination path to the created tarball
#
# [<b>source => "<dir_path>"</b>]
#	Path to the directory you want to pack into the tarball
#
# [<b>compression => "[xz|lzma|gz|bzip2]"</b>]
#	Compression type. If not specified we will use the extension for the 
#	file path specified in $name to guess this.
#
define archive::tar(
	$source,
	$compress = undef
) {
	$resource_name = "archive::tar"	
	fail("The resource archive::tar is not available yet.")
}
