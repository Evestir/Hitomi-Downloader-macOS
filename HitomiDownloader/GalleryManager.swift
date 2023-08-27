//
//  GalleryManager.swift
//  HitomiDownloader
//
//  Created by Vesitte on 8/16/23.
//

import Foundation
import FileWatcher
import SwiftUI

let watcher = FileWatcher([NSString(string: "~/Pictures/Hitomi").expandingTildeInPath])

var GalOrder = 0

func removeDirectory(atPath path: URL) {
    do {
        print(path)
        try FileManager.default.removeItem(at: path)
        print("Directory removed successfully")
    } catch {
        print("Error removing directory: \(error.localizedDescription)")
    }
}


func GetAttr(url: URL) -> Gallery {
    do {
        let JsonPath = URL(fileURLWithPath: url.path + "/gallery.json")
        let Json = try Data(contentsOf: JsonPath)
        
        let attribute = try JSONDecoder().decode(Gallery.self, from: Json)
        
        return attribute
    }
    catch {
        print(error)
        return Gallery(name: "Err", id: "Err", totalPages: 0, date: "Err", coverImage: "Err")
    }
}

extension URL {
    var isDirectory: Bool {
       (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
}

struct EdgeBorder: Shape {
    var width: CGFloat
    var edges: [Edge]

    func path(in rect: CGRect) -> Path {
        edges.map { edge -> Path in
            switch edge {
            case .top: return Path(.init(x: rect.minX, y: rect.minY, width: rect.width, height: width))
            case .bottom: return Path(.init(x: rect.minX, y: rect.maxY - width, width: rect.width, height: width))
            case .leading: return Path(.init(x: rect.minX, y: rect.minY, width: width, height: rect.height))
            case .trailing: return Path(.init(x: rect.maxX - width, y: rect.minY, width: width, height: rect.height))
            }
        }.reduce(into: Path()) { $0.addPath($1) }
    }
}

extension View {
    func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
}

func loadImageFromPath(path: String) -> NSImage {
    let url = URL(fileURLWithPath: path)
    do {
        let data = try Data(contentsOf: url)
        if let image = NSImage(data: data) {
            return image
        } else {
            return NSImage(systemSymbolName: "questionmark.folder.fill", accessibilityDescription: nil)! // Return a default image or handle the error
        }
    } catch {
        return NSImage(systemSymbolName: "questionmark.folder.fill", accessibilityDescription: nil)! // Return a default image or handle the error
    }
}

struct Gallery : Hashable, Equatable, Codable {
    var progress: Float!
    var complete: Bool!
    var order: Int!
    var name: String
    var id: String
    var totalPages: Int
    var date: String
    var coverImage: String
}

extension View {
    public static func semiOpaqueWindow() -> some View {
        VisualEffect().ignoresSafeArea()
    }
}

struct VisualEffect : NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSVisualEffectView()
        view.state = .active
        return view
    }
    func updateNSView(_ view: NSView, context: Context) { }
}
