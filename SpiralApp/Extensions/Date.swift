//
//  Date.swift
//  SpiralApp
//
//  Created by Alan Grissette on 10/16/25.
//

import Foundation
import SwiftUI

extension Date {
    
    func get (_ components : Calendar.Component..., calendar : Calendar = Calendar.current ) -> DateComponents{
        return calendar.dateComponents(Set(components), from: self)
        
        func get (_ component: Calendar.Component, calendar : Calendar = Calendar.current ) -> Int {
            return calendar.component(component, from: self)
            
            
            
        }
    }
}

//You can plug the date into the calender to get the time components 
