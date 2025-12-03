import SwiftUI
import Foundation

// MARK: - ColorEnum

enum ColorEnum {
    case original
    case second
    case third
    case fourth
    case fifth
}

//Make an Enum

// MARK: - Theme Picker

class ThemePicker: ObservableObject {
    @Published var theme: ColorEnum = .original
    static let shared = ThemePicker()
}

//Make a Theme Picker and we can use shared to make it static for the app

// MARK: - Theme Model

struct Theme {
    let primary: Color      // darkest
    let secondary: Color    // lightest (pastel)
    let tertiary: Color
    let fourth: Color
    let fifth: Color

    static func from(_ theme: ColorEnum) -> Theme {
        switch theme {

        // 🌿 Soft Sage (Calm / wellness apps)
        case .original:
            return Theme(
                primary: Color(hex: "#1F2D27"),   // deep forest sage
                secondary: Color(hex: "#E6F2EC"), // pastel mint fog
                tertiary: Color(hex: "#BFD9CC"),  // soft sage
                fourth: Color(hex: "#8DAF9F"),    // muted eucalyptus
                fifth: Color(hex: "#566F64")      // moss
            )

        // 🌸 Blush Mauve (journaling / lifestyle apps)
        case .second:
            return Theme(
                primary: Color(hex: "#2E1A2F"),   // deep plum
                secondary: Color(hex: "#F6E7F3"), // pastel blush
                tertiary: Color(hex: "#E2BFD9"),  // dusty pink
                fourth: Color(hex: "#C193B6"),    // muted mauve
                fifth: Color(hex: "#7B4A70")      // berry
            )

        // ☕️ Warm Latte (productivity / writing apps)
        case .third:
            return Theme(
                primary: Color(hex: "#2B221B"),   // dark roast
                secondary: Color(hex: "#FAF2EA"), // cream foam
                tertiary: Color(hex: "#E6D4C2"),  // warm oat
                fourth: Color(hex: "#C9AB8F"),    // caramel tan
                fifth: Color(hex: "#7A5E4A")      // toasted brown
            )

        // 🌊 Misty Blue (tech / focus / AI apps)
        case .fourth:
            return Theme(
                primary: Color(hex: "#101C2C"),   // deep midnight blue
                secondary: Color(hex: "#EAF2FB"), // icy pastel blue
                tertiary: Color(hex: "#C6D9F2"),  // soft sky
                fourth: Color(hex: "#92B5DE"),    // muted denim
                fifth: Color(hex: "#415F88")      // steel blue
            )

        // 🍊 Soft Citrus (mood / creativity / energy)
        case .fifth:
            return Theme(
                primary: Color(hex: "#33240D"),   // dark amber
                secondary: Color(hex: "#FFF7E6"), // pastel sherbet
                tertiary: Color(hex: "#FFE3B3"),  // mango cream
                fourth: Color(hex: "#FFC971"),    // muted orange
                fifth: Color(hex: "#9E6B2E")       // burnt honey
            )
        }
    }
}

// MARK: - Color Extension

extension Color {
    // ✅ Keep your hex initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted) 
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b, a: UInt64
        switch hex.count {
        case 6: // RGB
            (r, g, b, a) = ((int >> 16) & 0xFF,
                            (int >> 8) & 0xFF,
                            int & 0xFF,
                            255)
        case 8: // ARGB
            (r, g, b, a) = ((int >> 24) & 0xFF,
                            (int >> 16) & 0xFF,
                            (int >> 8) & 0xFF,
                            int & 0xFF)
        default:
            (r, g, b, a) = (255, 0, 0, 255)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    // ✅ Theme colors as static computed properties
    private static var currentTheme: Theme {
        Theme.from(ThemePicker.shared.theme)
    }
   
    static var primary: Color { currentTheme.primary }
    static var secondary: Color { currentTheme.secondary }
    static var tertiary: Color { currentTheme.tertiary }
    static var fourth: Color { currentTheme.fourth }
    static var fifth: Color { currentTheme.fifth }
}
