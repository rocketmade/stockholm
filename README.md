# stockholm
swift command line tool to rename provisioning profiles to a human readable name.

This project was born out of my frustration with an issue where Xcode would download (or move if you downloaded it yourself) provisioning profiles and give them an non human readable filename based on the uuid.
This allows old provisioning profiles that have been replaced by a newer version to remain in the directory and the current version of Xcode doesn't know that it should ignore the old version. When encountering duplicates the tool prefers to keep the most recent version based on the provisioning profiles `CreationDate` property inside the plist.

Install:

Download and build the tool.

Usage:

Run the tool.  If you just want to try it out I would suggest backing up `~/Library/MobileDevice/Provisioning Profiles` (e.g. using git). You can always delete all the profiles and have Xcode re-download them for you if you don't back them up.
