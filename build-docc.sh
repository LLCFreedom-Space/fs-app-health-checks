##!/bin/sh

xcrun xcodebuild docbuild \
	-scheme fs-app-health-checks \
	-destination 'generic/platform=macos' \
	-derivedDataPath "$PWD/.derivedData"
	
xcrun docc process-archive transform-for-static-hosting \
	"$PWD/.derivedData/Build/Products/" \
	--output-path ".docs" \
	--hosting-base-path "" # add your repo name later
	
echo '<script>window.location.href += "/documentation/fs-app-health-checks"</script>' > .docs/index.html
