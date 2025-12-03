//
//  Widget.swift
//  SpiralApp
//
//  Created by Alan Grissette on 11/3/25.
//

import Foundation
import SwiftUI

struct AddWidget: View {
    @State private var showSideBar = false
    @State private var showClearTaskMenu = false
    @State private var refreshTrigger = false
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.secondary
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Navbar(
                    showSidebar: $showSideBar,
                    refreshTrigger: $refreshTrigger,
                    headerText: "Widget"
                )
                
                // Main Content
                VStack {
                    Spacer()
                    
                    Image(systemName: "app.badge")
                        .font(.system(size: 80))
                        .foregroundColor(.primary)
                        .padding()
                    
                    Text("This Page is Not Ready Yet")
                        .font(.custom("AlegreyaSansSC-Bold", size: 20))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Text("Check back soon for widget customization!")
                        .font(.custom("AlegreyaSansSC-Regular", size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
extension AddWidget {
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

// MARK: - Preview
#Preview {
    AddWidget()
        .environmentObject(AuthModel())
}
