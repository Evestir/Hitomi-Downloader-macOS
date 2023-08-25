import SwiftUI
import Foundation

struct ContentView: View {
    @State private var gallaryIdInput = ""
    @State private var Iter = 0
    @State private var mangas: [Gallery] = []

    var body: some View {
        VStack {
            HStack(alignment: .top) {
                TextField("Gallary ID or Link", text:$gallaryIdInput).padding([.top, .leading])
                
                Button(action: {
                    if gallaryIdInput != "" {
                        Download(id:gallaryIdInput)
                    }
                }) {
                    Image(systemName:"arrow.down.circle")
                        .padding()
                }.padding([.top, .trailing])
            }.padding(.bottom, 5.0)
            Spacer()
            
            ScrollView {
                VStack(spacing: 0) {
                    ForEach($mangas, id: \.self) { manga in
                        HStack(alignment: .center) {
                            ZStack {
                                Image(nsImage: loadImageFromPath(path: manga.coverImage.wrappedValue)).resizable().frame(width: 100, height: 141).cornerRadius(5).clipped().aspectRatio(contentMode: .fill).shadow(radius: 10)
                            }.padding(.leading, 12.0).padding([.bottom, .top], 6)
                            VStack (alignment: .leading) {
                                HStack {
                                    Text(manga.name.wrappedValue).lineLimit(1).truncationMode(.middle).foregroundColor(Color(red: 240 / 255, green: 240 / 255, blue: 240 / 255)).fontWeight(.bold)
                                    Spacer()
                                    Text(String(manga.date.wrappedValue)).padding([.leading, .trailing]).lineLimit(1).truncationMode(.middle).fontWeight(.ultraLight)
                                }.padding(.top, 10)
                                
                                Text("ID: " + String(manga.id.wrappedValue)).lineLimit(1).truncationMode(.middle).fontWeight(.thin)
                                Text("Pages: " + String(manga.totalPages.wrappedValue))

                                Spacer()
                                if !manga.wrappedValue.complete {
                                    ProgressView(value: manga.wrappedValue.progress).progressViewStyle(DefaultProgressViewStyle())
                                        .animation(.easeInOut(duration: 0.5), value: manga.wrappedValue.progress)
                                }
                                Spacer()
                                HStack {
                                    Spacer()
                                    DeleteButton(mangas: $mangas, item: manga.wrappedValue)
                                }
                            }.frame(maxWidth: .infinity, alignment: .topLeading)
                        }.background(VisualEffectView().ignoresSafeArea()).border(width: 1, edges: [.bottom], color: Color(red: 59/255, green: 59/255, blue: 59/255))
                        /*.background(manga.order.wrappedValue % 2 == 0 ?  Color(red: 30/255, green: 30/255, blue: 31/255) : Color(red: 41/255, green: 41/255, blue: 42/255)).cornerRadius(manga.order.wrappedValue % 2 == 0 ? 0 : 15).padding([.leading, .trailing], 8.0)*/
                    }
                }
            }.onAppear(perform: PrepareList).frame(maxWidth: .infinity).frame(maxWidth: .infinity).background(Color(red: 30/255, green: 30/255, blue: 31/255)).border(width: 1, edges: [.top, .bottom], color: Color(red: 59/255, green: 59/255, blue: 59/255))
            HStack {
                Text(String(GalOrder + 1)).padding([.leading])
                Spacer()
                Image(systemName: "swift").padding([.trailing])
            }.padding([.bottom], 10)
        }
    }
    
    struct VisualEffectView: NSViewRepresentable {
        func makeNSView(context: Context) -> NSVisualEffectView {
            let effectView = NSVisualEffectView()
            effectView.state = .active
            return effectView
        }

        func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        }
    }
    
    func PrepareList(){
        do {
            let mangaDirs =  try URL(fileURLWithPath: picturesDirectoryPath()+"/Hitomi").subDirectories()
            mangaDirs.forEach { paths in
                print(paths)
                let attr = GetAttr(url: paths)
                mangas.append(Gallery(complete: true, order: GalOrder, name: attr.name, id: attr.id, totalPages: attr.totalPages, date: attr.date, coverImage: attr.coverImage))
                print(attr.totalPages)
                GalOrder += 1
            }
        }
        catch {
            print(error)
        }
        
        watcher.callback = { event in
            print("Something happened here: " + event.path)
            if URL(fileURLWithPath: event.path).isDirectory {
                print(event.path)
                
                let alreadyEx = mangas.contains { gallery in
                    gallery.id == getFolderNameFromPath(event.path)
                }
                
                if alreadyEx {
                    print("Found already existing one.." + event.path)
                }
                else {
                    let attr = GetAttr(url: URL(fileURLWithPath: event.path))
                    
                    mangas.append(Gallery(complete:false, order: GalOrder, name: attr.name, id: attr.id, totalPages: attr.totalPages, date: attr.date, coverImage: attr.coverImage))
                    GalOrder += 1
                }
            }
            else {
                if event.path.localizedStandardContains(".webp") {
                    let Galid = URL(filePath: event.path).deletingLastPathComponent().lastPathComponent
                    
                    print(Galid)
                    
                    let alreadyEx = mangas.contains { gallery in
                        gallery.id == Galid
                    }
                    // Avoiding nulls
                    if !alreadyEx {
                        print("not found manga")
                        return
                    }
                    
                    if let targetManga = mangas.firstIndex(where: { $0.id == Galid }) {
                        // The targetManga with the desired ID has been found
                        // You can work with targetManga here
                        print("Found manga with ID " + mangas[targetManga].id)
                                            
                        if mangas[targetManga].complete {
                            return
                        }
                        
                        let orderS = URL(filePath: event.path).lastPathComponent.replacingOccurrences(of: ".webp", with: "")
                        if let order = Int(orderS) {
                            if mangas[targetManga].totalPages == order {
                                mangas[targetManga].complete = true
                            }
                            mangas[targetManga].progress = Float(order) / Float(mangas[targetManga].totalPages)
                        }
                    } else {
                        // No manga with the desired ID was found
                        print("Manga with ID " + Galid + " not found.")
                    }
                }
            }
        }
        watcher.start()
    }
}

struct DeleteButton: View {
    @State private var isShowingPopover = false
    @Binding var mangas: [Gallery]
    let item: Gallery
    
    var body: some View {
        Button(action: {
            isShowingPopover = true
        }) {
            Image(systemName: "trash.fill")
        }
        .padding([.bottom, .trailing, .top])
        .buttonStyle(PlainButtonStyle())
        .popover(isPresented: $isShowingPopover, arrowEdge: .trailing) {
            VStack {
                Text("Confirm Deletion")
                    .font(.headline).padding()
                HStack {
                    Button("Cancel") {
                        isShowingPopover = false
                    }
                    Spacer()
                    Button("Delete", action: {
                        removeDirectory(atPath: URL(filePath: item.coverImage).deletingLastPathComponent())
                        isShowingPopover = false
                        if let targetManga = mangas.firstIndex(where: { $0.id == item.id }) {
                            mangas.remove(at: targetManga)
                        }
                    })
                }
            }
            .frame(width: 150)
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
            .frame(width: 500.0, height: 700.0)
            
    }
}
