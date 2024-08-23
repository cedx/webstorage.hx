/** Packages the project. **/
function main()
	for (script in ["Clean", "Version"]) Sys.command('lix $script');
