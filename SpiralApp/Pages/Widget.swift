//
//  Widget.swift
//  SpiralApp
//
//  Created by Alan Grissette on 11/3/25.
//

import Foundation
import SwiftUI

struct AddWidget : View {
    
    
    var body : some View {
        @State var showSideBar = false
        Navbar(showSidebar: $showSideBar, headerText: "Widget")
        Text("This Page is not ready Yet")
    }
    
}
