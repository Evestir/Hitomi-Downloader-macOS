//
//  Node.swift
//  HitomiDownloader
//
//  Created by Vesitte on 8/14/23.
//

import Foundation

func picturesDirectoryPath() -> String {
    let fileManager = FileManager.default
    let urls = fileManager.urls(for: .picturesDirectory, in: .userDomainMask)
    if let picturesDirectoryURL = urls.first {
        return picturesDirectoryURL.path
    } else {
        return "Pictures directory not found"
    }
}

func getFolderNameFromPath(_ path: String) -> String! {
    let url = URL(fileURLWithPath: path)
    return url.lastPathComponent
}

func getName(path:String) -> String! {
    var subbedString = "Unknown"
    if var startIndex = path.lastIndex(of: "く") {
        startIndex = path.index(after: startIndex)
        let endIndex = path.endIndex
        subbedString = String(path[startIndex..<endIndex])
        
        print(subbedString)
    }
    
    return subbedString
}

func getID(path:String) -> String! {
    var subbedString = "Unknown"
    if var endIndex = path.lastIndex(of: "く") {
        endIndex = path.index(before: endIndex)
        let startIndex = path.startIndex
        subbedString = String(path[startIndex..<endIndex])
        
        print(subbedString)
    }
    
    return subbedString
}

extension URL {
    func subDirectories() throws -> [URL] {
        // @available(macOS 10.11, iOS 9.0, *)
        guard hasDirectoryPath else { return [] }
        return try FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]).filter(\.hasDirectoryPath)
    }
}

func RunPy(id:String) {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/python3") // Path to the Python interpreter
    task.arguments = ["/Users/vesitte/Desktop/HitomiDownloader/HitomiDownloader/node.py", id] // Path to your Python script
    
    do {
        try task.run()
        task.waitUntilExit()
    } catch {
        print("Error: \(error)")
    }
}

func Download(id:String) -> Void {
    let queue = DispatchQueue(label: "PythonExecutionQueue", qos: .background)
    queue.async {
        RunPy(id: id)
    }
    //var result = Gallary(name: "\(response._name)", id: "\(response._id)", coverImage: "\(response._coverImage)")
}
