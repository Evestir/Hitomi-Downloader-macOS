//
//  UpdateManager.swift
//  HitomiDownloader
//
//  Created by Vesitte on 8/26/23.
//

import Foundation
import Cocoa

func AtLoad() {
    let nodePath = picturesDirectoryPath()+"/Hitomi/node.py"
    
    if (!fileExists(atPath: nodePath)) {
        let alert = NSAlert()
        alert.messageText = "Hitomi Downloader"
        alert.informativeText = "Node File is not found!\nTrying to download.."
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    FetchNode()
}

func FetchNode() {
    let session = URLSession.shared
    
    let task = session.dataTask(with: URL(string: "https://raw.githubusercontent.com/Evestir/Hitomi-Downloader-macOS/main/HitomiDownloader/node.py").unsafelyUnwrapped) { data, response, error in
        if let error = error {
            print("Error: \(error)")
            return
        }
        
        if let data = data {
            // Process the response data
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response: \(responseString)")
            }
            
            let fileURL = FileManager.default.urls(for: .picturesDirectory, in: .userDomainMask).first?.appendingPathComponent("Hitomi/node.py")
                        
            do {
                // Write the downloaded data to the local file
                try data.write(to: fileURL!)
                print("File downloaded and saved as node.py")
            } catch {
                print("Error saving file: \(error)")
            }
        }
    }
    
    task.resume()
    Notify(msg: "Successfully Fetched Downloader", type: BannerType.success)
}
