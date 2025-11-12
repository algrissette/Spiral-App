///
//  Settings.swift
//  SpiralApp
//
//  Created by Alan Grissette on 11/4/25.
//

import SwiftUI
import Foundation

struct Settings: View {
    @State var showSideBar = false
    @State var showClearTaskmenu = false
    @EnvironmentObject var userInfo: AuthModel   // Shared model
    @ObservedObject private var theme = ThemePicker.shared // observe singleton for UI updates

    var body: some View {
        ZStack {
            Color.primary
                .ignoresSafeArea()

            clearTaskMenu(showClearTaskMenu: $showClearTaskmenu) {
                VStack(alignment: .leading, spacing: 0) {

                    Navbar(showSidebar: $showSideBar, headerText: "Settings")
                        .background(Color.secondary)

                    SettingsHero()
                        .padding(.horizontal)

                    ScrollView {
                        VStack(spacing: 18) {

                            // Theme Selector Section
                            ThemeSection()

                            // MARK: ───────── General Section
                            SettingsSection(title: "General") {

                                SettingsRow(icon: Image(systemName: "person.circle"),
                                            text: "Change Username",
                                            destination: ChangeUsername().environmentObject(userInfo))

                                SettingsRow(icon: Image(systemName: "pencil"),
                                            text: "Change Name",
                                            destination: ChangeName().environmentObject(userInfo))

                                SettingsRow(icon: Image(systemName: "at"),
                                            text: "Change Email",
                                            destination: ChangeEmail().environmentObject(userInfo))

                                SettingsRow(icon: Image(systemName: "key"),
                                            text: "Change Password",
                                            destination: ChangePassword().environmentObject(userInfo))
                            }

                            // MARK: ───────── App Section
                            SettingsSection(title: "App") {

                                SettingsRow(icon: Image(systemName: "info.circle"),
                                            text: "Help",
                                            destination: HelpTutorial())

                                SettingsRow(icon: Image(systemName: "list.bullet.clipboard"),
                                            text: "Terms and Agreement",
                                            destination: TermsScreen())

                                SettingsRow(icon: Image(systemName: "x.circle"),
                                            text: "Log Out",
                                            destination: LogoutScreen().environmentObject(userInfo))

                                Divider()

                                SettingsRow(
                                    icon: Image(systemName: "x.circle.fill"),
                                    text: "Delete Account",
                                    destination: DeleteAccountScreen().environmentObject(userInfo)
                                )
                            }

                            Spacer(minLength: 60) // spacing at bottom for sidebar overlay
                        }
                        .padding(.vertical)
                        .padding(.horizontal, 12)
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }

            SideBar(showSideBar: $showSideBar, showClearTaskMenu: $showClearTaskmenu)
        }
        .navigationBarBackButtonHidden(true)
    }
        
}


// MARK: - Settings Hero (top name)
struct SettingsHero: View {
    @EnvironmentObject var userInfo: AuthModel
    @ObservedObject private var theme = ThemePicker.shared

    var body: some View {
        VStack(spacing: 8) {
            Text("\(userInfo.currentUser?.fullname ?? "User")")
                .font(.custom("AlegreyaSansSC-Bold", size: 20))
                .foregroundColor(.white)
                .tracking(10)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(userInfo.currentUser?.email ?? "")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.white.opacity(0.8))
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.vertical, 8)
    }
}


// MARK: - Theme Section
struct ThemeSection: View {
    @ObservedObject private var theme = ThemePicker.shared

    // theme order - keep same enum ordering as your ColorEnum
    private let themes: [ColorEnum] = [.original, .second, .third, .fourth, .fifth]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Theme")
                .font(.custom("AlegreyaSansSC-Bold", size: 16))
                .foregroundColor(.gray)
                .padding(.horizontal, 6)

            HStack(spacing: 18) {
                ForEach(themes.indices, id: \.self) { idx in
                    let t = themes[idx]
                    ThemeButton(theme: t, isSelected: t == theme.theme) {
                        // Update singleton theme on tap (Option 1)
                        withAnimation(.easeInOut(duration: 0.22)) {
                            ThemePicker.shared.theme = t
                        }
                    }
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 8)
            .background(Color.secondary.opacity(0.06))
            .cornerRadius(12)
        }
        .padding(.horizontal, 6)
    }
}

// MARK: - Theme Button (concentric rings)
struct ThemeButton: View {
    let theme: ColorEnum
    let isSelected: Bool
    let action: () -> Void

    // sizes (Option 2: medium & noticeable)
    private let outerSize: CGFloat = 40
    private let middleSize: CGFloat = 26
    private let innerSize: CGFloat = 14

    var body: some View {
        Button(action: action) {
            ZStack {
                // outer ring - primary
                Circle()
                    .fill(Theme.from(theme).primary)
                    .frame(width: outerSize, height: outerSize)

                // middle ring - secondary (slightly inset to look like a ring)
                Circle()
                    .fill(Theme.from(theme).secondary)
                    .frame(width: middleSize, height: middleSize)

                // inner dot - tertiary
                Circle()
                    .fill(Theme.from(theme).tertiary)
                    .frame(width: innerSize, height: innerSize)

                // optional accent border when selected (thin)
                if isSelected {
                    Circle()
                        .strokeBorder(Color.tertiary.opacity(0.85), lineWidth: 2)
                        .frame(width: outerSize + 6, height: outerSize + 6)
                        .blendMode(.overlay)
                }
            }
            .scaleEffect(isSelected ? 1.08 : 1.0)
            .shadow(color: isSelected ? Theme.from(theme).primary.opacity(0.28) : Color.clear,
                    radius: isSelected ? 12 : 0, x: 0, y: 6)
            .animation(.spring(response: 0.28, dampingFraction: 0.7, blendDuration: 0), value: isSelected)
            .accessibilityLabel(Text("\(String(describing: theme)) theme"))
        }
        .buttonStyle(PlainButtonStyle())
    }
}


// MARK: - Reusable Settings Section & Row
struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.custom("AlegreyaSansSC-Bold", size: 16))
                .foregroundColor(.gray)

            VStack(spacing: 0) {
                content
            }
            .background(Color.secondary.opacity(0.02))
            .cornerRadius(10)
            .padding(.top, 6)
        }
        .padding(.vertical, 6)
    }
}

struct SettingsRow<Destination: View>: View {
    let icon: Image
    let text: String
    let destination: Destination

    init(icon: Image, text: String, destination: Destination) {
        self.icon = icon
        self.text = text
        self.destination = destination
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                
                NavLink(destination: destination, image: icon, text: text)
                Spacer()
               
            }
            .padding(.vertical, 12)
            Divider().overlay(.white)
        }
    }
}


// MARK: - Preview
#Preview {
    Settings()
        .environmentObject(AuthModel())
        // make preview start with a known theme (optional)
        .onAppear {
            ThemePicker.shared.theme = .original
        }
}
