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

        // 🍃 Soft Sage Pastel
        case .original:
            return Theme(
                primary: Color(hex: "#2F3E38"),   // deep sage
                secondary: Color(hex: "#DDEBE2"), // pastel sage mist
                tertiary: Color(hex: "#A8C3B0"),  // soft green
                fourth: Color(hex: "#7FA18C"),    // leafy sage
                fifth: Color(hex: "#4D675A")      // eucalyptus dark
            )

        // 🍑 Peachy Mauve Pastel
        case .second:
            return Theme(
                primary: Color(hex: "#3A233F"),   // blackberry plum
                secondary: Color(hex: "#EBD9EF"), // pastel lilac
                tertiary: Color(hex: "#C7A7CE"),  // soft mauve
                fourth: Color(hex: "#A57FAF"),    // mauve rose
                fifth: Color(hex: "#6D4D72")      // muted violet
            )

        // 🍯 Warm Latte Pastel
        case .third:
            return Theme(
                primary: Color(hex: "#3A2F28"),   // espresso brown
                secondary: Color(hex: "#EFE1D5"), // pastel latte foam
                tertiary: Color(hex: "#D4BFAA"),  // warm oat
                fourth: Color(hex: "#B89C84"),    // caramel
                fifth: Color(hex: "#7D6657")      // mocha
            )

        // 🫐 Blueberry Milk Pastel
        case .fourth:
            return Theme(
                primary: Color(hex: "#1E2A38"),   // midnight blueberry
                secondary: Color(hex: "#DDE7F4"), // pastel periwinkle
                tertiary: Color(hex: "#A9C1DE"),  // baby denim
                fourth: Color(hex: "#7C9EC4"),    // dusty blue
                fifth: Color(hex: "#4F6B8C")      // muted navy
            )

        // 🍋 Pastel Citrus Pop (still soft, not neon)
        case .fifth:
            return Theme(
                primary: Color(hex: "#3F3A16"),   // deep olive seed
                secondary: Color(hex: "#F3F0D8"), // pastel lemon cream
                tertiary: Color(hex: "#E3DA9B"),  // soft lemon grass
                fourth: Color(hex: "#C3B673"),    // olive gold
                fifth: Color(hex: "#857A38")      // vintage olive
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
