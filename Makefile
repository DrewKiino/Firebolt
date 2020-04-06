
generate:
	@swift package generate-xcodeproj --skip-extra-files

pod_push:
	@pod trunk push Firebolt.podspec
