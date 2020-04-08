
generate:
	@swift package generate-xcodeproj --skip-extra-files

push_pod:
	@pod trunk push Firebolt.podspec
