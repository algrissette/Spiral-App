//
//  SettingsFunctions.swift
//  SpiralApp
//
//  Created by Alan Grissette on 11/5/25.
//

import SwiftUI

// MARK: - Settings Container (placeholder)
struct SettingsFunctions: View {
    var body: some View {
        Text("Settings")
            .font(.title2)
            .foregroundColor(.primary)
    }
}

// MARK: - Shared Banner View (fade in/out)
struct SuccessBanner: View {
    let message: String
    @Binding var isShown: Bool

    var body: some View {
        if isShown {
            Text(message)
                .font(.subheadline)
                .padding(.vertical, 8)
                .padding(.horizontal, 14)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.green.opacity(0.95)))
                .foregroundColor(.white)
                .transition(.opacity)
                .zIndex(1)
                .padding(.top, 8)
        } else {
            EmptyView()
        }
    }
}

// MARK: - Change Username
struct ChangeUsername: View {
    @EnvironmentObject var auth: AuthModel
        @State private var newUsername: String = ""
        @State private var loading = false
        @State private var alertMessage: String?
        @State private var bannerShown = false
        @State private var bannerText = ""
        @Environment(\.presentationMode) var presentationMode

        var body: some View {
            ZStack {
                Color.primary.ignoresSafeArea()

                VStack(spacing: 16) {

                    SuccessBanner(message: bannerText, isShown: $bannerShown)
                        .animation(.easeInOut(duration: 0.25), value: bannerShown)
                    

                    HStack {
                        NavigationLink(destination: Settings()) {
                            Image(systemName: "x.square")
                                .foregroundColor(.black)
                                .font(.system(size: 30))
                                .padding()
                        }
                        Spacer()
                    }
                    Text("Change your username")
                        .font(.custom("sippinOnSunshine", size: 28))
                        .foregroundStyle(.black)
                    
                    if let currentUser = auth.currentUser {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Current Username")
                                .font(.custom("AlegreyaSansSC-regular", size: 16))
                                .foregroundColor(.secondary)

                            Text(currentUser.userName)
                                .font(.custom("AlegreyaSansSC-regular", size: 16))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                        TextField("Enter new username", text: $newUsername)
                        
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)

                        if loading {
                            ProgressView().padding()
                        } else {
                            Button {
                                Task { await doUpdate() }
                            } label: {
                                Text("Update Username")
                                    .bold()
                                    .frame(maxWidth: .infinity)
                                    .font(.custom("AlegreyaSansSC-Bold", size: 16))
                                    .padding()
                                    .background(Color.primary)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                            }
                        }

                    } else {
                        Text("No user logged in").padding()
                            .font(.custom("AlegreyaSansSC-Bold", size: 16))
                    }

                    Spacer()
                }
                .onDisappear { bannerShown = false }
                .navigationBarBackButtonHidden(true)
                .alert(item: $alertMessage) { msg in
                    Alert(title: Text("Error"), message: Text(msg), dismissButton: .default(Text("OK")))
                }
            }
        }
    private func doUpdate() async {
        let trimmed = newUsername.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            alertMessage = "Please enter a username."
            return
        }

        loading = true
        do {
                
            try await auth.updateUsername(to: trimmed)
            bannerText = "Username updated"
            withAnimation { bannerShown = true }
            // hide after 2.5s
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation { bannerShown = false }
            }
        } catch {
            alertMessage = error.localizedDescription
        }
        loading = false
    }
}

// MARK: - Change Full Name
struct ChangeName: View {
    @EnvironmentObject var user: AuthModel
    @State private var newName: String = ""
    @State private var loading = false
    @State private var alertMessage: String?
    @State private var bannerShown = false
    @State private var bannerText = ""

    var body: some View {
        ZStack{
            Color.primary.ignoresSafeArea()
            VStack(spacing: 16) {
               
                SuccessBanner(message: bannerText, isShown: $bannerShown)
                    .animation(.easeInOut(duration: 0.25), value: bannerShown)
                HStack {
                    NavigationLink(destination: Settings()){
                        Image(systemName: "x.square")
                            .foregroundColor(.black)
                            .font(.system(size: 30))
                            .padding()
                    }
                    Spacer()
                }
                Text("Change your name")
                    .font(.custom("sippinOnSunshine", size: 28))
                    .foregroundStyle(.black)
                
                if let current = user.currentUser {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current Name")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(current.fullname)
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    TextField("Enter new full name", text: $newName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    if loading {
                        ProgressView().padding()
                    } else {
                        Button(action: { Task { await doUpdate() } }) {
                            Text("Update Name")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.primary)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                    }
                } else {
                    Text("No user logged in").padding()
                }
                
                Spacer()
            }
            .navigationBarBackButtonHidden(true)
            .alert(item: $alertMessage) { msg in
                Alert(title: Text("Error"), message: Text(msg), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func doUpdate() async {
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            alertMessage = "Please enter a name."
            return
        }

        loading = true
        do {
            try await user.updateName(to: trimmed)
            bannerText = "Name updated"
            withAnimation { bannerShown = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation { bannerShown = false }
            }
        } catch {
            alertMessage = error.localizedDescription
        }
        loading = false
    }
}

// MARK: - Change Email (secure: re-auth required)
struct ChangeEmail: View {
    @EnvironmentObject var user: AuthModel
    @State private var currentPassword = ""
    @State private var newEmail = ""
    @State private var loading = false
    @State private var alertMessage: String?
    @State private var bannerShown = false
    @State private var bannerText = ""

    var body: some View {
        ZStack{
            VStack(spacing: 12) {
               
                SuccessBanner(message: bannerText, isShown: $bannerShown)
                    .animation(.easeInOut(duration: 0.25), value: bannerShown)
                HStack {
                    NavigationLink(destination: Settings()){
                        Image(systemName: "x.square")
                            .foregroundColor(.black)
                            .font(.system(size: 30))
                            .padding()
                    }
                    Spacer()
                }
                Text("Change your email")
                    .font(.custom("sippinOnSunshine", size: 28))
                    .foregroundStyle(.black)
                
                if let current = user.currentUser {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current Email")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(current.email)
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    SecureField("Current password", text: $currentPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    TextField("New email", text: $newEmail)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding(.horizontal)
                    
                    if loading {
                        ProgressView().padding()
                    } else {
                        Button(action: { Task { await doChangeEmail() } }) {
                            Text("Update Email")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.primary)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                    }
                } else {
                    Text("No user logged in").padding()
                }
                
                Spacer()
            }
            .navigationBarBackButtonHidden(true)
            .alert(item: $alertMessage) { msg in
                Alert(title: Text("Error"), message: Text(msg), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func doChangeEmail() async {
        let trimmedNew = newEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !currentPassword.isEmpty else {
            alertMessage = "Enter your current password."
            return
        }
        guard !trimmedNew.isEmpty else {
            alertMessage = "Enter a new email address."
            return
        }

        loading = true
        do {
            try await user.updateEmail(currentPassword: currentPassword, newEmail: trimmedNew)
            bannerText = "Email updated"
            withAnimation { bannerShown = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation { bannerShown = false }
            }
        } catch {
            alertMessage = error.localizedDescription
        }
        loading = false
    }
}

// MARK: - Change Password (secure: re-auth required)
struct ChangePassword: View {
    
    @EnvironmentObject var user: AuthModel
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var loading = false
    @State private var alertMessage: String?
    @State private var bannerShown = false
    @State private var bannerText = ""

    var body: some View {
        ZStack{
            VStack(spacing: 12) {
                
                SuccessBanner(message: bannerText, isShown: $bannerShown)
                    .animation(.easeInOut(duration: 0.25), value: bannerShown)
                HStack {
                    NavigationLink(destination: Settings()){
                        Image(systemName: "x.square")
                            .foregroundColor(.black)
                            .font(.system(size: 30))
                            .padding()
                    }
                    Spacer()
                }
                Text("Change Username")
                    .font(.custom("sippinOnSunshine", size: 28))
                    .foregroundStyle(.black)
                
                
                SecureField("Current password", text: $currentPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                SecureField("New password", text: $newPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                SecureField("Confirm new password", text: $confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                if loading {
                    ProgressView().padding()
                } else {
                    Button(action: { Task { await doChangePassword() } }) {
                        Text("Update Password")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.primary)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                }
                
                Spacer()
            }
            .navigationBarBackButtonHidden(true)
            .alert(item: $alertMessage) { msg in
                Alert(title: Text("Error"), message: Text(msg), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func doChangePassword() async {
        guard !currentPassword.isEmpty else {
            alertMessage = "Enter your current password."
            return
        }
        guard newPassword.count >= 6 else {
            alertMessage = "New password must be at least 6 characters."
            return
        }
        guard newPassword == confirmPassword else {
            alertMessage = "Passwords do not match."
            return
        }

        loading = true
        do {
            try await user.updatePassword(currentPassword: currentPassword, newPassword: newPassword)
            bannerText = "Password updated"
            withAnimation { bannerShown = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation { bannerShown = false }
            }
            // clear fields
            newPassword = ""
            confirmPassword = ""
            currentPassword = ""
        } catch {
            alertMessage = error.localizedDescription
        }
        loading = false
    }
}


// MARK: - Help Tutorial (Guided Walkthrough)
struct HelpTutorial: View {
    @State private var page: Int = 0
    private let pageCount = 5

    var body: some View {
        NavigationStack {
            
            ZStack {
                // Background uses your app's secondary color as page paper
                Color.secondary
                    .ignoresSafeArea()

                VStack(spacing: 18) {
                    HStack {
                        NavigationLink(destination: Settings()){
                            Image(systemName: "x.square")
                                .foregroundColor(.black)
                                .font(.system(size: 30))
                                .padding()
                        }
                        Spacer()
                    }
                    // Header
                    NavigationLink(destination:  Home(currentDate: Date.now))
                    {
                        Text("Go to Home")
                            .font(.custom("AlegreyaSansSC-Bold", size: 20))
                            .foregroundColor(Color.blue)
                            .underline()
                    }
                    HStack {
                        Text("Guide")
                            .font(.custom("AlegreyaSansSC-Bold", size: 20))
                            .foregroundColor(.primary)
                        Spacer()
                        Text("Page \(page + 1) of \(pageCount)")
                            .font(.custom("AlegreyaSansSC-Regular", size: 14))
                            .foregroundColor(.primary.opacity(0.7))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    // Pager
                    TabView(selection: $page) {
                        PageHome()
                            .tag(0)
                        PageCalendar()
                            .tag(1)
                        PageAddTask()
                            .tag(2)
                        PageThemes()
                            .tag(3)
                        PageAccount()
                            .tag(4)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    // Dots + Controls
                    HStack(spacing: 12) {
                        HStack(spacing: 6) {
                            ForEach(0..<pageCount, id: \.self) { i in
                                Circle()
                                    .fill(i == page ? Color.primary : Color.primary.opacity(0.25))
                                    .frame(width: i == page ? 10 : 6, height: i == page ? 10 : 6)
                                    .animation(.easeInOut, value: page)
                            }
                        }

                        Spacer()

                        Button(action: {
                            withAnimation { page = max(0, page - 1) }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                                .padding(8)
                                .background(RoundedRectangle(cornerRadius: 8).fill(Color.primary.opacity(0.12)))
                        }
                        .disabled(page == 0)

                        Button(action: {
                            withAnimation {
                                if page < pageCount - 1 { page += 1 }
                                else { /* optionally dismiss or loop */ }
                            }
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .semibold))
                                .padding(8)
                                .background(RoundedRectangle(cornerRadius: 8).fill(Color.primary))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Page: Home (visual tutorial)
fileprivate struct PageHome: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Home — Your Daily Journal")
                .font(.custom("sippinOnSunshine", size: 28))
                .foregroundColor(.primary)
                .padding(.top, 12)

            Text("Tap the Add Task button to create a new task for the selected day. Tasks appear below the date and can be tapped to reveal edit or delete options.")
                .font(.custom("AlegreyaSansSC-Regular", size: 16))
                .foregroundColor(.primary.opacity(0.85))
                .padding(.bottom, 8)

            // Mock Header + Example Task list
            VStack(spacing: 12) {
                // Mock header bar
                HStack {
                    Image(systemName: "chevron.forward")
                        .font(.system(size: 14))
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.primary))
                        .foregroundColor(.white)

                    Spacer()

                    Text("Journal")
                        .font(.custom("AlegreyaSansSC-Bold", size: 18))

                    Spacer()

                    Image("SpiralLogo")
                        .resizable()
                        .frame(width: 26, height: 26)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.primary.opacity(0.08)))
                .overlay(SketchAccent().allowsHitTesting(false))

                // Mock task list (non-interactive visuals)
                VStack(spacing: 8) {
                    ExampleTaskRow(text: "Morning pages — 250 words")
                    ExampleTaskRow(text: "Plan meals")
                    ExampleTaskRow(text: "Walk the dog (30 min)")
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.primary.opacity(0.03)))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.primary.opacity(0.06)))
            }
            .padding(.vertical, 6)

            Spacer()
        }
        .padding(.horizontal, 22)
    }
}

// MARK: - Page: Calendar
fileprivate struct PageCalendar: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Calendar — Find Any Day")
                .font(.custom("sippinOnSunshine", size: 28))
                .foregroundColor(.primary)
                .padding(.top, 12)

            Text("Tap a calendar box to view the day's journal preview. The calendar grid is a quick way to jump to past entries.")
                .font(.custom("AlegreyaSansSC-Regular", size: 16))
                .foregroundColor(.primary.opacity(0.85))

            // Calendar mock (non-clickable)
            VStack(spacing: 10) {
                HStack {
                    Text("S")
                    Text("M")
                    Text("T")
                    Text("W")
                    Text("T")
                    Text("F")
                    Text("S")
                }
                .font(.custom("AlegreyaSansSC-Bold", size: 14))
                .foregroundColor(.primary.opacity(0.8))
                .padding(.horizontal, 10)
                .frame(maxWidth: .infinity)

                // Grid row examples (3 rows shown)
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        CalendarCellMock(date: "28", isToday: false)
                        CalendarCellMock(date: "29", isToday: false)
                        CalendarCellMock(date: "30", isToday: false)
                        CalendarCellMock(date: "31", isToday: false)
                        CalendarCellMock(date: "1", isToday: true)  // visually highlighted
                        CalendarCellMock(date: "2", isToday: false)
                        CalendarCellMock(date: "3", isToday: false)
                    }

                    HStack(spacing: 8) {
                        ForEach(4...10, id: \.self) { day in
                            CalendarCellMock(date: String(day), isToday: false)
                        }
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 14).fill(Color.primary.opacity(0.03)))
                .overlay(SketchAccent().allowsHitTesting(false))
            }
            .padding(.vertical, 6)

            Text("Tip: The highlighted box shows today. Tap it to open the day's full journal.")
                .font(.custom("AlegreyaSansSC-Regular", size: 13))
                .foregroundColor(.primary.opacity(0.7))

            Spacer()
        }
        .padding(.horizontal, 22)
    }
}

// MARK: - Page: Add Task
fileprivate struct PageAddTask: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Add Task — Quick Capture")
                .font(.custom("sippinOnSunshine", size: 28))
                .foregroundColor(.primary)
                .padding(.top, 12)

            Text("Use the Add Task dialog to jot down tasks. It saves automatically to the selected date's journal.")
                .font(.custom("AlegreyaSansSC-Regular", size: 16))
                .foregroundColor(.primary.opacity(0.85))

            // Mock add-task dialog visual (non-interactive)
            VStack(spacing: 12) {
                // Dim background to mimic sheet
                VStack(spacing: 10) {
                    Text("Add Task")
                        .font(.custom("AlegreyaSansSC-Bold", size: 18))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    TextField("Write your Task", text: .constant(""))
                        .disabled(true)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.primary.opacity(0.04)))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.primary.opacity(0.06)))
                    HStack {
                        Spacer()
                        Button("Save Task") { }
                            .disabled(true)
                            .font(.custom("AlegreyaSansSC-Bold", size: 16))
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color.primary))
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.primary.opacity(0.03)))
                .overlay(SketchAccent().allowsHitTesting(false))
            }
            .padding(.vertical, 6)

            Text("Note: This mock shows the exact layout and font sizing used in the real Add Task sheet — but it is static in the tutorial.")
                .font(.custom("AlegreyaSansSC-Regular", size: 13))
                .foregroundColor(.primary.opacity(0.7))

            Spacer()
        }
        .padding(.horizontal, 22)
    }
}

// MARK: - Page: Themes
fileprivate struct PageThemes: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
           
            Text("Themes — Personalize Your Space")
                .font(.custom("sippinOnSunshine", size: 28))
                .foregroundColor(.primary)
                .padding(.top, 12)

            Text("Choose a theme that feels like your paper. Themes apply to the app chrome and optional page background.")
                .font(.custom("AlegreyaSansSC-Regular", size: 16))
                .foregroundColor(.primary.opacity(0.85))

            // Theme swatches
            HStack(spacing: 18) {
                ThemeSwatchMock(name: "Grape Noir", colors: [
                    Color(hex: "#2A1A32"),
                    Color(hex: "#4B2E56"),
                    Color(hex: "#7B4E8D"),
                    Color(hex: "#C7A7D9"),
                    Color(hex: "#F7F0FA")
                ])
                ThemeSwatchMock(name: "Forest Fog", colors: [
                    Color(hex: "#1A2E22"),
                    Color(hex: "#304C3A"),
                    Color(hex: "#5D7F67"),
                    Color(hex: "#B7D3C0"),
                    Color(hex: "#F3FBF6")
                ])
            }
            .padding(.vertical, 8)
            .overlay(SketchAccent().allowsHitTesting(false))

            Text("Tip: Primary color is used for navigation and strong accents. Secondary is the light, paper-like background.")
                .font(.custom("AlegreyaSansSC-Regular", size: 13))
                .foregroundColor(.primary.opacity(0.7))

            Spacer()
        }
        .padding(.horizontal, 22)
    }
}

// MARK: - Page: Account & Sync
fileprivate struct PageAccount: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Account & Sync")
                .font(.custom("sippinOnSunshine", size: 28))
                .foregroundColor(.primary)
                .padding(.top, 12)

            Text("Your journal saves to your account. Sign in on another device to access entries. If sync appears delayed, check network or sign-in state.")
                .font(.custom("AlegreyaSansSC-Regular", size: 16))
                .foregroundColor(.primary.opacity(0.85))

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "person.circle")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                    VStack(alignment: .leading) {
                        Text("Signed in as")
                            .font(.custom("AlegreyaSansSC-Bold", size: 13))
                        Text("you@domain.com")
                            .font(.custom("AlegreyaSansSC-Regular", size: 13))
                            .foregroundColor(.primary.opacity(0.7))
                    }
                    Spacer()
                }

                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 18))
                        .foregroundColor(.primary)
                    Text("Last sync: 2 minutes ago")
                        .font(.custom("AlegreyaSansSC-Regular", size: 13))
                        .foregroundColor(.primary.opacity(0.7))
                    Spacer()
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.primary.opacity(0.03)))
            .overlay(SketchAccent().allowsHitTesting(false))

            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .padding(.horizontal, 22)
    }
}

// MARK: - Reusable Mock Components

fileprivate struct ExampleTaskRow: View {
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 18))
                .foregroundColor(.primary.opacity(0.7))
            Text(text)
                .font(.custom("AlegreyaSansSC-Regular", size: 16))
                .foregroundColor(.primary)
            Spacer()
            Image(systemName: "ellipsis")
                .font(.system(size: 14))
                .foregroundColor(.primary.opacity(0.6))
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.primary.opacity(0.02)))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.primary.opacity(0.03)))
    }
}

fileprivate struct CalendarCellMock: View {
    var date: String
    var isToday: Bool

    var body: some View {
        VStack(spacing: 6) {
            Text(date)
                .font(.custom("AlegreyaSansSC-Bold", size: 16))
                .foregroundColor(isToday ? .white : .primary)
                .frame(maxWidth: .infinity)

            Circle()
                .strokeBorder(Color.primary.opacity(0.12), lineWidth: 1)
                .frame(width: 18, height: 18)
                .overlay(
                    // small marker for entries (visual only)
                    Circle().fill(Color.primary.opacity(0.2)).frame(width: 6, height: 6)
                )
        }
        .padding(10)
        .frame(width: 44, height: 58)
        .background(
            Group {
                if isToday {
                    LinearGradient(colors: [Color.primary, Color.primary.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                } else {
                    Color.secondary.opacity(0.06)
                }
            }
        )
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.06), radius: 2, x: 0, y: 1)
    }
}

fileprivate struct ThemeSwatchMock: View {
    let name: String
    let colors: [Color] // [primary, tertiary, fourth, fifth, secondary]

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.primary.opacity(0.03))
                    .frame(width: 120, height: 80)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.primary.opacity(0.04)))
                HStack(spacing: 4) {
                    ForEach(colors.indices, id: \.self) { i in
                        Circle()
                            .fill(colors[i])
                            .frame(width: 20, height: 20)
                            .overlay(Circle().stroke(Color.primary.opacity(0.06), lineWidth: 1))
                    }
                }
            }
            Text(name)
                .font(.custom("AlegreyaSansSC-Regular", size: 13))
                .foregroundColor(.primary)
        }
    }
}

/// Sketchy accent overlay to add a subtle hand-drawn feel
fileprivate struct SketchAccent: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [6], dashPhase: 0))
                .foregroundColor(Color.primary.opacity(0.04))
                .blendMode(.normal)
            // faint paper texture strip
            LinearGradient(colors: [Color.clear, Color.primary.opacity(0.01), Color.clear], startPoint: .top, endPoint: .bottom)
                .cornerRadius(12)
        }
        .allowsHitTesting(false)
    }
}







// MARK: - TermsScreen (Accordion Hybrid Cards)
struct TermsScreen: View {
    private let sections: [AccordionSection] = [
        AccordionSection(title: "Introduction", content:
            """
            These Terms and Conditions (“Terms”) govern your access to and use of the Spiral mobile application and related services (collectively, the “Service”) provided by the developer (“we”, “us”, or “Spiral”). By accessing or using the Service, you agree to be bound by these Terms. If you do not agree with any of these Terms, do not use the Service.
            """
        ),

        AccordionSection(title: "Eligibility", content:
            """
            (a) Minimum Age. Use of the Service is available only to individuals who are at least sixteen (16) years of age. By using the Service, you represent and warrant that you are at least sixteen years old. (b) Account Holders. Some features require an account. Account holders must provide accurate, current and complete information and maintain and promptly update the information as necessary.
            """
        ),

        AccordionSection(title: "Accounts; Security; Credentials", content:
            """
            (a) Account Creation. You may be required to create an account to access certain features. You are responsible for maintaining the confidentiality of your account credentials and for all activity that occurs under your account. (b) Security. You agree to notify us immediately of any unauthorized use of your account or any other breach of security, and ensure that you exit from your account at the end of each session. We are not liable for any loss or damage arising from your failure to comply. (c) Authorization. You agree that the account email and credentials are sufficient proof of authentication for purposes of performing actions in the Service.
            """
        ),

        AccordionSection(title: "Data Storage, Syncing, and Third-Party Services", content:
            """
            (a) Cloud Storage: Content you create, save, or upload is stored and synchronized in cloud services (including third-party providers such as Firebase) to enable cross-device access. (b) Data Transmission: You consent to the transfer and storage of your information on servers located in various jurisdictions. (c) No Sale of Personal Data: We do not sell your personal data. We may share information with third-party service providers that perform services on our behalf, but only in order to provide and improve the Service. (d) Analytics & Future Use: We may collect aggregated or anonymized usage data. We will not publish or share personally identifiable data without your consent, except as described in the Privacy Policy or as required by law.
            """
        ),

        AccordionSection(title: "Content; User Conduct; Restrictions", content:
            """
            (a) Your Content: You retain ownership over content you create and upload. By using the Service you grant us a worldwide, royalty-free, non-exclusive license to store, back up, display, and otherwise use that content as necessary to provide the Service. (b) Prohibited Content & Conduct: You agree not to create, upload, post, share, or otherwise transmit content that is unlawful, harmful, abusive, harassing, defamatory, threatening, discriminatory, promotes violence, self-harm, illegal activity, is sexually explicit, infringes third-party rights, or impersonates another. (c) Moderation: We may monitor, review, remove, or disable access to any content that violates these Terms at our discretion.
            """
        ),

        AccordionSection(title: "Intellectual Property", content:
            """
            (a) Our Rights: The Service, its design, features, and functionality are our exclusive property and are protected by intellectual property laws. (b) Your Rights: You retain ownership of content you submit, subject to the license granted above.
            """
        ),

        AccordionSection(title: "Payment, Subscriptions and Future Monetization", content:
            """
            (a) Monetization Reserved: We may implement paid features, subscriptions, in-app purchases, or other monetization models now or in the future. (b) Purchases & Billing: If you make purchases via app stores or payment processors, you agree to their terms and billing policies. All fees are non-refundable except as required by law. (c) Trial Periods: Free trials may convert to paid subscriptions unless canceled according to trial terms.
            """
        ),

        AccordionSection(title: "Termination; Suspension", content:
            """
            (a) Termination by You: You may stop using the Service at any time and may delete your account via Settings. (b) Termination by Us: We may suspend or terminate your access for breach of these Terms, suspected fraud, security issues, or other lawful reasons. (c) Effect: Termination does not limit other rights or remedies. Upon termination, existing copies of data may remain in backups or logs.
            """
        ),

        AccordionSection(title: "Disclaimers; No Warranty", content:
            """
            THE SERVICE IS PROVIDED “AS IS” AND “AS AVAILABLE” WITHOUT WARRANTIES OF ANY KIND. WE DISCLAIM ALL WARRANTIES, INCLUDING IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT. WE DO NOT GUARANTEE UNINTERRUPTED OR ERROR-FREE OPERATION.
            """
        ),

        AccordionSection(title: "Limitation of Liability", content:
            """
            TO THE MAXIMUM EXTENT PERMITTED BY LAW, WE ARE NOT LIABLE FOR INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL OR PUNITIVE DAMAGES, OR ANY LOSS OF PROFITS, REVENUE, DATA, OR USE. OUR AGGREGATE LIABILITY FOR DIRECT DAMAGES SHALL NOT EXCEED THE TOTAL AMOUNTS YOU PAID TO US IN THE TWELVE (12) MONTHS PRIOR TO THE EVENT GIVING RISE TO LIABILITY, OR ONE HUNDRED DOLLARS ($100), WHICHEVER IS GREATER.
            """
        ),

        AccordionSection(title: "Indemnification", content:
            """
            You agree to indemnify and hold harmless Spiral, its officers, directors, employees and agents from claims, losses, liabilities, damages, costs and expenses (including attorneys’ fees) arising from your use of the Service, violation of these Terms, or infringement of third-party rights.
            """
        ),

        AccordionSection(title: "Changes to Terms", content:
            """
            We may modify these Terms from time to time. If changes are material, we will attempt to provide notice (for example, via email or app notification). Continued use after notice constitutes acceptance of the updated Terms.
            """
        ),

        AccordionSection(title: "Governing Law; Dispute Resolution", content:
            """
            These Terms are governed by the laws of the United States without regard to conflict-of-law rules. Except where prohibited by law, disputes will be resolved in a court of competent jurisdiction or, at our option, binding arbitration where permitted.
            """
        ),

        AccordionSection(title: "Contact", content:
            """
            For questions about these Terms, please contact: support@spiral.app (replace with your real support address).
            """
        )
    ]

    @State private var openSections: Set<Int> = []
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack{
            Color.secondary.ignoresSafeArea()
            VStack{
                HStack {
                    NavigationLink(destination: Settings()){
                        Image(systemName: "x.square")
                            .foregroundColor(.black)
                            .font(.system(size: 30))
                            .padding()
                    }
                    Spacer()
                }
                ScrollView {
                    VStack(spacing: 14) {
                        header
                        ForEach(sections.indices, id: \.self) { idx in
                            AccordionCard(
                                index: idx,
                                isOpen: openSections.contains(idx),
                                section: sections[idx]
                            ) {
                                toggleSection(idx)
                            }
                        }
                        footer
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 20)
                }
            }
            .background(Color.secondary.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Terms & Conditions")
                .font(.custom("sippinOnSunshine", size: 28))
                .foregroundColor(.primary)
            Text("Effective date: November 7, 2025")
                .font(.custom("AlegreyaSansSC-Regular", size: 13))
                .foregroundColor(.primary.opacity(0.7))
        }
        .padding(.bottom, 6)
    }

    private var footer: some View {
        VStack(spacing: 8) {
            Divider().background(Color.primary.opacity(0.06))
            Text("If you have concerns or require additional information, please contact support@spiral.app.")
                .font(.custom("AlegreyaSansSC-Regular", size: 13))
                .foregroundColor(.primary.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.vertical, 18)
        }
    }

    private func toggleSection(_ idx: Int) {
        withAnimation(.easeInOut) {
            if openSections.contains(idx) { openSections.remove(idx) }
            else { openSections.insert(idx) }
        }
    }
}

fileprivate struct AccordionSection {
    let title: String
    let content: String
}

// MARK: - Accordion Card (Hybrid: formal text inside soft card)
fileprivate struct AccordionCard: View {
    let index: Int
    let isOpen: Bool
    let section: AccordionSection
    let onToggle: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(section.title)
                        .font(.custom("AlegreyaSansSC-Bold", size: 16))
                        .foregroundColor(.primary)
                    Text(subtitlePreview)
                        .font(.custom("AlegreyaSansSC-Regular", size: 12))
                        .foregroundColor(.primary.opacity(0.65))
                        .lineLimit(1)
                }
                Spacer()
                Image(systemName: isOpen ? "chevron.up" : "chevron.down")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary.opacity(0.8))
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.primary.opacity(0.04)))
            }
            .padding(14)
            .contentShape(Rectangle())
            .onTapGesture(perform: onToggle)

            if isOpen {
                Divider().background(Color.primary.opacity(0.06))
                ScrollView(.vertical, showsIndicators: false) {
                    Text(section.content)
                        .font(.custom("AlegreyaSansSC-Regular", size: 14))
                        .foregroundColor(.primary)
                        .padding(14)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(minHeight: 80, maxHeight: 380)
                .background(Color.secondary.opacity(0.02))
            }
        }
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.primary.opacity(0.02)))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.primary.opacity(0.04)))
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }

    private var subtitlePreview: String {
        let trimmed = section.content.trimmingCharacters(in: .whitespacesAndNewlines)
        let preview = trimmed.prefix(80)
        return String(preview) + (trimmed.count > 80 ? "…" : "")
    }
}



// MARK: - Logout Confirmation
struct LogoutScreen: View {
    @EnvironmentObject var user: AuthModel
    @State private var loading = false
    @State private var alertMessage: String?
    @State private var bannerShown = false
    @State private var bannerText = ""
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                NavigationLink(destination: Settings()){
                    Image(systemName: "x.square")
                        .foregroundColor(.black)
                        .font(.system(size: 30))
                        .padding()
                }
                Spacer()
            }
            
            SuccessBanner(message: bannerText, isShown: $bannerShown)
                .animation(.easeInOut(duration: 0.25), value: bannerShown)

            Text("Are you sure you want to log out?")
                .font(.headline)
                .padding(.horizontal)

            if loading {
                ProgressView().padding()
            } else {
                HStack(spacing: 12) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Text("Cancel")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray5))
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                    }

                    Button(action: { doSignOut() }) {
                        Text("Log Out")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.secondary)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }

            Spacer()
        }
        .navigationTitle("Log Out")
        .navigationBarBackButtonHidden(true)
        .alert(item: $alertMessage) { msg in
            Alert(title: Text("Error"), message: Text(msg), dismissButton: .default(Text("OK")))
        }
    }

    private func doSignOut() {
        loading = true
        // signOut() in your AuthModel is synchronous
        user.signOut()
        bannerText = "Logged out"
        withAnimation { bannerShown = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation { bannerShown = false }
            loading = false
            presentationMode.wrappedValue.dismiss()
        }
    }
}
// MARK: - Delete Account


struct DeleteAccountScreen: View {
    @EnvironmentObject var user: AuthModel
    @State private var loading = false
    @State private var alertMessage: String?
    @State private var bannerShown = false
    @State private var bannerText = ""
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            Color.red.opacity(0.9)     //  Scary red background
                .ignoresSafeArea()

            VStack(spacing: 20) {
                
                Text("⚠️ Delete Account")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.top)

                Text("This will **permanently delete** your account and all data.\nThis cannot be undone.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal)

                if loading {
                    ProgressView()
                        .tint(.white)
                        .padding()
                } else {
                    Button(action: { Task { await confirmDelete() } }) {
                        Text("DELETE ACCOUNT")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .padding(.horizontal)
                            .scaleEffect(1.05)
                    }

                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Text("Cancel")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.red)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                }

                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert(item: $alertMessage) { msg in
            Alert(title: Text("Error"), message: Text(msg), dismissButton: .default(Text("OK")))
        }
    }

    private func confirmDelete() async {
        loading = true
        do {
            try await user.deleteAccount()     // Remove account from Firebase
            try? await user.signOut()
        } catch {
            alertMessage = error.localizedDescription
        }
        loading = false
    }
}


// MARK: - String Identifiable for Alerts
extension String: Identifiable {
    public var id: String { self }
}

// MARK: - Previews
struct SettingsFunctions_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                NavigationLink("Change Username", destination: ChangeUsername().environmentObject(previewAuth()))
                NavigationLink("Change Name", destination: ChangeName().environmentObject(previewAuth()))
                NavigationLink("Change Email", destination: ChangeEmail().environmentObject(previewAuth()))
                NavigationLink("Change Password", destination: ChangePassword().environmentObject(previewAuth()))
                NavigationLink("Help", destination: HelpTutorial())
                NavigationLink("Terms", destination: TermsScreen())
                NavigationLink("Log Out", destination: LogoutScreen().environmentObject(previewAuth()))
                NavigationLink("Delete Account", destination: DeleteAccountScreen().environmentObject(previewAuth()))
            }
            .navigationTitle("Settings")
        }
    }

    static func previewAuth() -> AuthModel {
        let auth = AuthModel()
        auth.currentUser = AppUser(id: "preview", fullname: "Alan Grissette", email: "alan@example.com", userName: "alan")
        return auth
    }
}
