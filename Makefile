
generate:
	@swift package generate-xcodeproj --skip-extra-files

push_pod:
	@pod trunk push Firebolt.podspec

xcframework:
# generate iOS
	xcodebuild archive \
	-scheme FireboltSwift \
	-destination "generic/platform=iOS" \
	-archivePath .build/iOS \
	SKIP_INSTALL=NO 
# generate watchOS
	xcodebuild archive \
	-scheme FireboltSwift \
	-destination "generic/platform=watchOS" \
	-archivePath .build/watchOS \
	SKIP_INSTALL=NO 
# generate iOS sim
	xcodebuild archive \
	-scheme FireboltSwift \
	-destination "generic/platform=iOS Simulator" \
	-archivePath .build/iOS_Simulator \
	SKIP_INSTALL=NO 
# generate watchOS sim
	xcodebuild archive \
	-scheme FireboltSwift \
	-destination "generic/platform=watchOS Simulator" \
	-archivePath .build/watchOS_Simulator \
	SKIP_INSTALL=NO 
# build xcframework
	xcodebuild -create-xcframework \
	-framework .build/iOS.xcarchive/Products/Library/Frameworks/FireboltSwift.framework \
	-framework .build/watchOS.xcarchive/Products/Library/Frameworks/FireboltSwift.framework \
	-framework .build/iOS_Simulator.xcarchive/Products/Library/Frameworks/FireboltSwift.framework \
	-framework .build/watchOS_Simulator.xcarchive/Products/Library/Frameworks/FireboltSwift.framework \
	-output .build/FireboltSwift.xcframework