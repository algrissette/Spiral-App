import SwiftUI

struct Validator {
    
    
    
    // Validate full name: must contain at least one space (assuming first + last)
    static func validName(_ fullName: String) -> String {
        if fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Full name cannot be empty."
        }
        if fullName.rangeOfCharacter(from: .whitespaces) == nil {
            return "Please enter your full name."
        }
        return ""
    }
    
    
    static func validateUsername(userName: String, checkAuth: AuthModel) async throws -> String? {
        if try await checkAuth.userExists(userName: userName) {
            // Username exists, so it is taken
            return "Username is already taken"
        }
        // Username does NOT exist, so it's available (return nil means no error)
        return nil
    }

    
    // Validate username: non-empty, no spaces
    static func validUsername(_ userName: String) -> String {
        if userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Username cannot be empty."
        }
        if userName.rangeOfCharacter(from: .whitespaces) != nil {
            return "Username cannot contain spaces."
        }
        return ""
    }
    
    // Validate email using regex
    static func validEmail(_ email: String) -> String {
        let regex = #"^\S+@\S+\.\S+$"#
        if email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Email cannot be empty."
        }
        if email.range(of: regex, options: .regularExpression) == nil {
            return "Please enter a valid email address."
        }
        return ""
    }
    
    // Validate password: min 8 chars, at least 2 digits
    static func validPassword(_ password: String) -> String {
        let hasMinLength = password.count >= 8
        let digits = CharacterSet.decimalDigits
        let digitCount = password.unicodeScalars.filter { digits.contains($0) }.count
        let hasTwoDigits = digitCount >= 1
        
        if !hasMinLength {
            return "Password must be at least 8 characters long."
        }
        if !hasTwoDigits {
            return "Password must contain at least 1 digit."
        }
        return ""
    }
    
    // Check if passwords match
    static func matchingPasswords(_ passwordOne: String, _ passwordTwo: String) -> String {
        if passwordOne != passwordTwo {
            return "Passwords do not match."
        }
        return ""
    }
    
    // Validate entire sign up — returns true only if all validations pass
    // If any validation fails, it sets the provided error message reference
    static func validSignUp(
        fullName: String,
        userName: String,
        emailOne: String,
        emailTwo: String,
        passwordOne: String,
        passwordTwo: String,
        checkAuth: AuthModel
    ) async -> (Bool, String) {
        
        if let usernameError = try? await validateUsername(userName: userName, checkAuth: checkAuth) {
            return (false, usernameError)
        }
        
        let nameError = validName(fullName)
        if !nameError.isEmpty { return (false, nameError) }
        
        let localUsernameError = validUsername(userName)
        if !localUsernameError.isEmpty { return (false, localUsernameError) }
        
        let emailError = validEmail(emailOne)
        if !emailError.isEmpty { return (false, emailError) }
        
        if emailOne != emailTwo {
            return (false, "Email addresses do not match.")
        }
        
        let passwordError = validPassword(passwordOne)
        if !passwordError.isEmpty { return (false, passwordError) }
        
        let matchError = matchingPasswords(passwordOne, passwordTwo)
        if !matchError.isEmpty { return (false, matchError) }
        
        return (true, "")
    }
}
