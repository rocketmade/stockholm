//
//  main.swift
//  Stockholm
//
//  Created by Brandon Roth on 3/18/16.
//
//

import Foundation

extension String {
    
    func writeToFileHandler(handler: NSFileHandle) {
        if let data = NSString(string: self).dataUsingEncoding(NSUTF8StringEncoding) {
            handler.writeData(data)
        }
    }
}

extension NSFileHandle {
    func writeString(string: String) {
        string.writeToFileHandler(self)
    }
}

func printHelpMessage() {
    print("Usage:")
    print("\tRenames provisioning profiles to something more closely resembling what you would see in Xcode.  Replaces spaces with _, and * (common with team provisioning profiles) with 'wildcard'.")
    print("\te.g. e0d8eb32-88c6-4892-b13c-1efb6336e1bd.mobileprovision becomes profile_name.mobileprovision")
    
    print("")
    print("Aguments:")
    print("\t-h: Prints this help message")
    print("\t-v: Runs verbosely")
    print("\t-c: Automatially removes outdated profiles.  This often occures when you update a provisioning profile and Xcode doesn't delete the outdated one. This is turned off by default")
    exit(0)
}

func renameFiles(verbose: Bool, clean: Bool) {
    
    let fileManager = NSFileManager.defaultManager()
    
    let defaultProfilesPath = "~/Library/MobileDevice/Provisioning Profiles"
    let profilesPath = NSString(string: defaultProfilesPath).stringByExpandingTildeInPath
    let profilesURL = NSURL.fileURLWithPath(profilesPath)
    let profileURLS = try! fileManager.contentsOfDirectoryAtURL(profilesURL, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsHiddenFiles)
    
    var toRename = Set<ProvisioningProfile>()
    var toDelete = Set<ProvisioningProfile>()
    
    for url in profileURLS {
        
        do {
            let profile = try ProvisioningProfile(filepath: url)
            
            //check if there is a duplicate profile.  This can happen when you update a profile and Xcode doesn't delete the old one.
            //This is what motivated this whole project.  So this really is the magical part here.  We'll choose to pick the newest one
            if let duplicate = toRename.filter({$0.name == profile.name}).first {
                
                var newest: ProvisioningProfile
                var oldest: ProvisioningProfile
                if profile.createdAt.compare(duplicate.createdAt) == .OrderedDescending {
                    newest = profile
                    oldest = duplicate
                }
                else {
                    newest = duplicate
                    oldest = profile
                }
                
                toRename.remove(oldest)
                toDelete.insert(oldest)
                toRename.insert(newest)
            }
            else {
                toRename.insert(profile)
            }
        }
        catch {
            if verbose {
                print("Failed to process file: \(url.path!)")
            }
        }
    }
   
    if clean {
        for profile in toDelete where fileManager.fileExistsAtPath(profile.inputFilePath.path!) {
            if verbose {
                print("cleaning file: \(profile.inputFilePath.path!)")
            }
            try! fileManager.removeItemAtURL(profile.inputFilePath)
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
       
        if verbose {
            NSFileHandle.fileHandleWithStandardOutput().writeString("Rewriting file: \(profile.inputFilePath.path!) to \(profile.outputURL.path!)")
            NSFileHandle.fileHandleWithStandardOutput().writeString("\n")
        }
        try! fileManager.moveItemAtURL(profile.inputFilePath, toURL: profile.outputURL)
    }
}


var verbose: Bool = false
var removeOutdated: Bool = false


for arg in Process.arguments {
    switch arg {
    case "-h", "--help": printHelpMessage()
    case "-c", "--clean": removeOutdated = true
    case "-v", "--verbose": verbose = true
    default:
        break
    }
}

renameFiles(verbose, clean: removeOutdated)
exit(0)

