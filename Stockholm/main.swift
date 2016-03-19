//
//  main.swift
//  Stockholm
//
//  Created by Brandon Roth on 3/18/16.
//
//

import Foundation

let fileManager = NSFileManager.defaultManager()


let fileExtension = "mobileprovision"

let path = NSString(string: "~/Library/MobileDevice/Provisioning Profiles").stringByExpandingTildeInPath
let files = try! fileManager.contentsOfDirectoryAtPath(path).flatMap{NSURL(string: $0)}.filter{$0.pathExtension == fileExtension}

//for file in files {
var collection = [String]()
for file in files {
    let fullPath = NSString(string: path).stringByAppendingPathComponent(file.absoluteString)
    let args = ["cms","-D","-i",fullPath]
    let task = NSTask()
    task.launchPath = "/usr/bin/security"
    task.arguments = args
    task.standardInput = NSPipe()
    task.standardError = NSPipe()
    
    let pipe = NSPipe()
    task.standardOutput = pipe
    let handler = pipe.fileHandleForReading
    task.launch()
    
    let data = handler.readDataToEndOfFile()
    let hash = try! NSPropertyListSerialization.propertyListWithData(data, options: NSPropertyListReadOptions(), format: nil) as! NSDictionary
    let uuid = hash["UUID"]!
    let name = hash["Name"]!
    let creationDate = hash["CreationDate"]!
    let x = hash["AppIDName"]!
    
    collection.append("\(name) - \(uuid) - \(creationDate)")
}


for e in collection.sort() {
    print(e)
}