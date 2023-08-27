import SwiftUI
import Foundation
import PopupView

struct ContentView: View {
    @State private var gallaryIdInput = ""
    @State private var Iter = 0
    @State private var mangas: [Gallery] = []
    @StateObject var settings = insPopupSettings

    var body: some View {
        ZStack {
            VStack {
                HStack(alignment: .top) {
                    NeumorphicStyleTextField(textField: TextField("Input ID...", text: $gallaryIdInput), imageName: "safari.fill").padding([.top, .leading], 10).padding(.trailing, 4)
                    Button(action:{downloadGal()}) { Image(systemName: "arrow.down").padding(10) }.buttonStyle(Serculant(cornerRadius: 6)).padding([.top, .trailing], 10)
                }.padding(.bottom, 3.0)
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
                                        Text(manga.name.wrappedValue).lineLimit(1).truncationMode(.middle).foregroundColor(Color(red: 240 / 255, green: 240 / 255, blue: 240 / 255)).fontWeight(.bold).font(.system(size: 18))
                                        Spacer()
                                        Text(String(manga.date.wrappedValue)).padding([.leading, .trailing]).lineLimit(1).truncationMode(.middle).fontWeight(.ultraLight)
                                    }.padding(.top, 10)
                                    
                                    Text("ID: " + String(manga.id.wrappedValue)).lineLimit(1).truncationMode(.middle).fontWeight(.thin)
                                    Text("Pages: " + String(manga.totalPages.wrappedValue))
                                    
                                    Spacer()
                                    if !manga.wrappedValue.complete {
                                        ProgressView(value: manga.wrappedValue.progress).progressViewStyle(DefaultProgressViewStyle()).padding()
                                    }
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        DeleteButton(mangas: $mangas, item: manga.wrappedValue)
                                    }
                                }.frame(maxWidth: .infinity, alignment: .topLeading)
                            }
                            .background(manga.order.wrappedValue % 2 == 0 ?  Color(red: 30/255, green: 30/255, blue: 31/255) : Color(red: 41/255, green: 41/255, blue: 42/255)).cornerRadius(manga.order.wrappedValue % 2 == 0 ? 0 : 5).padding([.leading, .trailing], 8.0)
                        }.padding(.bottom, 8)
                    }
                }.onAppear(perform: PrepareList).frame(maxWidth: .infinity).frame(maxWidth: .infinity).background(Color(red: 30/255, green: 30/255, blue: 31/255)).border(width: 1, edges: [.top, .bottom], color: Color(red: 59/255, green: 59/255, blue: 59/255))
                HStack {
                    Text(String(GalOrder) + " Galleries").padding([.leading])
                    Spacer()
                    Text("v0.2a").fontWeight(SwiftUI.Font.Weight.ultraLight).padding([.trailing], 3)
                    Image(systemName: "swift").padding([.trailing])
                }.padding([.bottom], 10)
            }.background(VisualEffectView().ignoresSafeArea()).border(width: 1, edges: [.bottom], color: Color(red: 59/255, green: 59/255, blue: 59/255)).onAppear(perform: FetchNode)
        }.popup(isPresented: $settings.IsShowing) {
            Toast()
        } customize: {
            $0
                .type(.floater())
                .position(.top)
                .isOpaque(true)
                .animation(.spring())
                .closeOnTapOutside(true)
                .backgroundColor(.black.opacity(0.5))
                .autohideIn(2)
        }.environmentObject(settings)
    }
    
    struct PressActions: ViewModifier {
        var onPress: () -> Void
        var onRelease: () -> Void
        func body(content: Content) -> some View {
            content
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged({ _ in
                            onPress()
                        })
                        .onEnded({ _ in
                            onRelease()
                        })
                )
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
    
    func downloadGal() {
        if gallaryIdInput != "" {
            Download(id:gallaryIdInput)
            print("Started downloading")
        } else {
            Notify(msg: "Please fill in the field.", type: .warning)
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
                                Notify(msg: "Successfully downloaded: " + mangas[targetManga].name, type: BannerType.success)
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

struct Toast: View {
    @EnvironmentObject var settings: PopupSettings
    var body: some View {
        HStack {
            Text(settings.Content).fontWeight(.light).font(.system(size: 14)).padding(10).background(settings.type.tintColor).cornerRadius(15).shadow(radius: 10)
        }.cornerRadius(10).background(Color.clear).ignoresSafeArea().padding()
    }
}

class PopupSettings: ObservableObject {
    @Published var Content = "Being added content"
    @Published var type = BannerType.info
    @Published var IsShowing = false
    
    func UpdateContent(msg: String, Bannertype: BannerType) {
        Content = msg
        type = Bannertype
    }
}

var insPopupSettings = PopupSettings()

enum BannerType {
    case info
    case warning
    case success
    case error

    var tintColor: Color {
        switch self {
        case .info:
            return Color(red: 67/255, green: 154/255, blue: 215/255)
        case .success:
            return Color.green
        case .warning:
            return Color.yellow
        case .error:
            return Color.red
        }
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
