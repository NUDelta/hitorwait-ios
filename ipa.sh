#!/bin/bash
# original source from http://www.thecave.com/2014/09/16/using-xcodebuild-to-export-a-ipa-from-an-archive/
rm hitorwait.ipa
xcodebuild clean -project hitorwait -configuration Release -alltargets
xcodebuild archive -project hitorwait.xcodeproj -scheme hitorwait -archivePath hitorwait.xcarchive
xcodebuild -exportArchive -archivePath hitorwait.xcarchive -exportPath hitorwait -exportFormat ipa -exportProvisioningProfile "Delta Lab O"
