import SwiftUI
import Foundation

func Notify(msg: String, type: BannerType) {
    insPopupSettings.Content = msg
    insPopupSettings.type = type
    insPopupSettings.IsShowing = true
}

extension NSTextField {
    open override var focusRingType: NSFocusRingType {
        get { .none }
        set { }
    }
}

extension Color {
    static let blackShadow = Color(red: 40 / 255, green: 40 / 255, blue: 40 / 255)
    static let darkShadow = Color(red: 80 / 255, green: 80 / 255, blue: 80 / 255)
    static let background = Color(red: 58 / 255, green: 58 / 255, blue: 58 / 255)
    static let neumorphictextColor = Color(red: 132 / 255, green: 132 / 255, blue: 132 / 255)
}

struct NeumorphicStyleTextField: View {
    var textField: TextField<Text>
    var imageName: String
    var body: some View {
        HStack {
            Image(systemName: imageName)
                .foregroundColor(Color.darkShadow).padding(8.0)
            textField.textFieldStyle(PlainTextFieldStyle())
        }
        .foregroundColor(.neumorphictextColor)
        .background(Color.background)
        .cornerRadius(6)
        .shadow(color: Color.darkShadow, radius: 3, x: 0, y: 2)
        .shadow(color: Color.blackShadow, radius: 3, x: 0, y: -2)
    }
}

struct Serculant: ButtonStyle {
    var cornerRadius: CGFloat
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(0)
            .background(.blue)
            .foregroundStyle(.white)
            .scaleEffect(configuration.isPressed ? 1.6 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            .clipShape(RoundedRectangle.init(cornerRadius: self.cornerRadius))
            .shadow(color: Color.darkShadow, radius: 3, x: 0, y: 2)
            .shadow(color: Color.blackShadow, radius: 3, x: 0, y: -2)
    }
}
