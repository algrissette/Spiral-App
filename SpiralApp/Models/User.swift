// AppUser.swift
import Foundation

struct AppUser: Identifiable, Codable {
    var id: String
    var fullname: String
    var email: String
    var userName: String
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullname) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return ""
    }
}
