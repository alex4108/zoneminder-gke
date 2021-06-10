#!/usr/bin/env bash

echo "Checking for homebrew"
brew help
if [[ $? != 0 ]]; then
	echo "Homebrew is not installed.  Please install it :)"
	exit 1
fi

brews="jq yq helm terraform"
for brew in ${brews}; do
	echo "Installing: ${brew}"
	#brew install ${brew}
done

echo "Please install the gcloud SDK here: https://cloud.google.com/sdk/docs/quickstart"
