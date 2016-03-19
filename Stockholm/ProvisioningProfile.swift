//
//  ProvisioningProfile.swift
//  Stockholm
//
//  Created by Brandon Roth on 3/21/16.
//
//

import Foundation

public struct ProvisioningProfile {
    
    let uuid: String
    let name: String
    let createdAt: NSDate
    let inputFilePath: NSURL
    
    init(filepath: NSURL) throws {
        
        let path = filepath.path!
        
        //create a task to decrypt the provisioning profile
        let task = NSTask()
        task.launchPath = "/usr/bin/security"
        task.arguments = ["cms","-D","-i",path]
        
        //keep the input log clean
        task.standardInput = NSPipe()
        
        //keep the debug console log clean
        task.standardError = NSPipe()
        
        //create a pipe to read the output from after the task completes
        let standardOutput = NSPipe()
        let outputFileHandle = standardOutput.fileHandleForReading
        task.standardOutput = standardOutput
        task.launch()
        
        //read the provisioning profile into a plist
        let data = outputFileHandle.readDataToEndOfFile()
        let plist = try NSPropertyListSerialization.propertyListWithData(data, options: NSPropertyListReadOptions(), format: nil) as! NSDictionary
        
        //extract the values were looking for
        self.uuid = plist["UUID"] as! String
        self.name = plist["Name"] as! String
        self.createdAt = plist["CreationDate"] as! NSDate
        self.inputFilePath = filepath
    }
    
    var outputURL: NSURL {
        var massagedName = name.stringByReplacingOccurrencesOfString("*", withString: "wildcard")
        massagedName = massagedName.stringByReplacingOccurrencesOfString(":", withString: "")
        massagedName = massagedName.stringByReplacingOccurrencesOfString(" ", withString: "_")
        return inputFilePath.URLByDeletingLastPathComponent!.URLByAppendingPathComponent(massagedName).URLByAppendingPathExtension("mobileprovision")
    }
}

extension ProvisioningProfile: Hashable, Comparable{
    public var hashValue: Int {
        return self.name.hashValue
    }
}

public func ==(lhs: ProvisioningProfile, rhs: ProvisioningProfile) -> Bool {
    return lhs.name == rhs.name
}

public func <(lhs: ProvisioningProfile, rhs: ProvisioningProfile) -> Bool {
    return lhs.name < rhs.name
}