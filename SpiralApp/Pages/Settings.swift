//
//  Settings.swift
//  SpiralApp
//
//  Created by Alan Grissette on 11/4/25.
//

import SwiftUI
import Foundation

struct Settings: View {
    @State private var showSideBar = false
    @State private var showClearTaskMenu = false
    @State private var refreshTrigger = false
    @EnvironmentObject var userInfo: AuthModel
    @ObservedObject private var theme = ThemePicker.shared
    
    var body: some View {
        ZStack {
            Color.primary
                .ignoresSafeArea()
            
            Home.ClearTaskMenu(showClearTaskMenu: $showClearTaskMenu) {
                VStack(alignment: .leading, spacing: 0) {
                    Navbar(
                        showSidebar: $showSideBar,
                        refreshTrigger: $refreshTrigger,

                        headerText: "Settings"
                    )
                    .background(Color.secondary)
                    
                    SettingsHero()
                        .padding(.horizontal)
                    
                    ScrollView {
                        VStack(spacing: 18) {
                            // Theme Selector Section
                            ThemeSection()
                            
                            // MARK: ───────── General Section
                            SettingsSection(title: "General") {
                                SettingsRow(
                                    icon: Image(systemName: "person.circle"),
                                    text: "Change Username",
                                    destination: ChangeUsername().environmentObject(userInfo)
                                )
                                
                                SettingsRow(
                                    icon: Image(systemName: "pencil"),
                                    text: "Change Name",
                                    destination: ChangeName().environmentObject(userInfo)
                                )
                                
                                SettingsRow(
                                    icon: Image(systemName: "at"),
                                    text: "Change Email",
                                    destination: ChangeEmail().environmentObject(userInfo)
                                )
                                
                                SettingsRow(
                                    icon: Image(systemName: "key"),
                                    text: "Change Password",
                                    destination: ChangePassword().environmentObject(userInfo)
                                )
                            }
                            
                            // MARK: ───────── App Section
                            SettingsSection(title: "App") {
                                SettingsRow(
                                    icon: Image(systemName: "info.circle"),
                                    text: "Help",
                                    destination: HelpTutorial()
                                )
                                
                                SettingsRow(
                                    icon: Image(systemName: "list.bullet.clipboard"),
                                    text: "Terms and Agreement",
                                    destination: TermsScreen()
                                )
                                
                                SettingsRow(
                                    icon: Image(systemName: "x.circle"),
                                    text: "Log Out",
                                    destination: LogoutScreen().environmentObject(userInfo)
                                )
                                
                                Divider()
                                
                                SettingsRow(
                                    icon: Image(systemName: "x.circle.fill"),
                                    text: "Delete Account",
                                    destination: DeleteAccountScreen().environmentObject(userInfo)
                                )
                            }
                            
                            Spacer(minLength: 60)
                        }
                        .padding(.vertical)
                        .padding(.horizontal, 12)
                    }
                    .onChange(of: refreshTrigger) { _ in
                        // Refresh user info or reset theme if needed
                        // Example: reload user data from Firestore
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
            
            Home.SideBar(
                showSideBar: $showSideBar,
                showClearTaskMenu: $showClearTaskMenu
            )
            .transition(.backSlide.combined(with: .identity))
            .animation(.linear, value: showSideBar)
        }
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Navbar
extension Settings {
    struct Navbar: View {
        @Binding var showSidebar: Bool
        @Binding var refreshTrigger: Bool
        var headerText: String
        
        var body: some View {
            VStack(spacing: 0) {
                HStack {
                    Button(action: { showSidebar.toggle() }) {
                        Image(systemName: "chevron.forward")
                            .font(.system(size: 16))
                            .padding()
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    Text(headerText)
                        .font(.custom("AlegreyaSansSC-Bold", size: 20))
                        .lineLimit(1)
                        .tracking(5)
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button(action: {
                        refreshTrigger.toggle()
                    }) {
                        Image("SpiralLogo")
                            .resizable()
                            .frame(width: 25, height: 25)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: 500, y: 0))
                }
                .stroke(Color.black, lineWidth: 1)
                .shadow(color: Color.black, radius: 3, y: 3)
                .frame(maxHeight: 4)
            }
        }
    }
}

// MARK: - Settings Hero
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

// MARK: - Theme Button
struct ThemeButton: View {
    let theme: ColorEnum
    let isSelected: Bool
    let action: () -> Void
    
    private let outerSize: CGFloat = 40
    private let middleSize: CGFloat = 26
    private let innerSize: CGFloat = 14
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Theme.from(theme).primary)
                    .frame(width: outerSize, height: outerSize)
                
                Circle()
                    .fill(Theme.from(theme).secondary)
                    .frame(width: middleSize, height: middleSize)
                
                Circle()
                    .fill(Theme.from(theme).tertiary)
                    .frame(width: innerSize, height: innerSize)
                
                if isSelected {
                    Circle()
                        .strokeBorder(Color.tertiary.opacity(0.85), lineWidth: 2)
                        .frame(width: outerSize + 6, height: outerSize + 6)
                        .blendMode(.overlay)
                }
            }
            .scaleEffect(isSelected ? 1.08 : 1.0)
            .shadow(
                color: isSelected ? Theme.from(theme).primary.opacity(0.28) : Color.clear,
                radius: isSelected ? 12 : 0,
                x: 0,
                y: 6
            )
            .animation(
                .spring(response: 0.28, dampingFraction: 0.7, blendDuration: 0),
                value: isSelected
            )
            .accessibilityLabel(Text("\(String(describing: theme)) theme"))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Settings Section
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

// MARK: - Settings Row
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
                Home.NavLink(destination: destination, image: icon, text: text)
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
        .onAppear {
            ThemePicker.shared.theme = .original
        }
}
