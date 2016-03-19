//
//  main.swift
//  Stockholm
//
//  Created by Brandon Roth on 3/18/16.
//
//

import Foundation

let fileManager = NSFileManager.defaultManager()
let profilesPath = NSString(string: "~/Library/MobileDevice/Provisioning Profiles").stringByExpandingTildeInPath
let profilesURL = NSURL.fileURLWithPath(profilesPath)
let profileURLS = try! fileManager.contentsOfDirectoryAtURL(profilesURL, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsHiddenFiles)

var toRename = Set<ProvisioningProfile>()
var toDelete = Set<ProvisioningProfile>()

for url in profileURLS {
    
    do {
        let profile = try ProvisioningProfile(filepath: url)
       
        //check if there is a duplicate profile.  This can happen when you update a profile and Xcode doesn't delete the old one.
        //This is what motivated this whole project.  So this really is the magical part here.  We'll choose to pick the newest one
        if let duplicate = toRename.filter({$0.name == profile.name}).first where profile.createdAt.compare(duplicate.createdAt) == .OrderedDescending {
            toRename.remove(duplicate)
            toDelete.insert(duplicate)
            toRename.insert(profile)
        }
        else {
            toRename.insert(profile)
        }
    }
    catch {
        print("Failed to process file: \(url.path!)")
    }
}

for profile in toRename {
    
    //only rename files that have a uuid filename, i.e. the ones apple copies there
    let originalFilename = profile.inputFilePath.URLByDeletingPathExtension!.lastPathComponent!
    guard originalFilename == profile.uuid else {
        continue
    }
    
    if fileManager.fileExistsAtPath(profile.outputURL.path!) {
        //delete the old file first.  This could happen if we have a outdated profile and we end up with a new old that
        //needs to be renamed.  We have to delete before we rename or else NSFileManager will throw an error
        try! fileManager.removeItemAtURL(profile.outputURL)
    }
    
    try! fileManager.moveItemAtURL(profile.inputFilePath, toURL: profile.outputURL)
}







