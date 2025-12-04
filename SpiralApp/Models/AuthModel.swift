//
//  AuthModel.swift
//  iBullet
//
//  Created by Alan Grissette on 9/10/25.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthModel: ObservableObject {
    
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: AppUser?
    
    private let authenticator = Auth.auth()
    private let db = Firestore.firestore()
    
    init() {
        Task { @MainActor in
            await fetchUser()
        }
    }


    // MARK: - Fetch Current User
    func fetchUser() async {
        guard let uid = authenticator.currentUser?.uid else { return }
        
        do {
            let doc = try await db.collection("users").document(uid).getDocument()
            self.currentUser = try doc.data(as: AppUser.self)
            self.userSession = authenticator.currentUser
        } catch {
            print(" Failed to fetch user: \(error.localizedDescription)")
        }
    }

    
    func userExists(userName: String) async throws -> Bool {
        let querySnapshot = try await db.collection("users")
            .whereField("userName", isEqualTo: userName)
            .getDocuments()
        
        return !querySnapshot.documents.isEmpty
    }
    // MARK: - Create Account
    func createAccount(email: String, password: String, name: String, username: String) async throws {
        do {
            let authResult = try await authenticator.createUser(withEmail: email, password: password)
             self.userSession = authResult.user
            
            let user = AppUser(
                id: authResult.user.uid,
                fullname: name,
                email: email,
                userName: username
            )
            
            let encodedUser = try Firestore.Encoder().encode(user)
            
            do {
                try await db.collection("users").document(user.id).setData(encodedUser)
                 self.currentUser = user
            } catch {
                // Firestore save failed, so delete the user in Auth to rollback
                do {
                    try await authenticator.currentUser?.delete()
                    self.userSession = nil
                } catch {
                    print("Also failed to delete auth user after Firestore error: \(error.localizedDescription)")
                }
                throw AccountCreationError.firestoreSaveFailed
            }
        } catch let error as AccountCreationError {
            throw error  // Pass custom errors through
        } catch {
            throw AccountCreationError.generalFailure
        }
    }

    // Define user-friendly error types

    enum AccountCreationError: LocalizedError {
        case firestoreSaveFailed
        case generalFailure
        
        var errorDescription: String? {
            switch self {
            case .firestoreSaveFailed:
                return "Oops! We couldn't save your account details. Please try again."
            case .generalFailure:
                return "Account may already exist under this email. Try again later or try a new email!"
            }
        }
    }

    // MARK: - Sign In
    enum AuthError: Error {
        case usernameNotFound
        case incorrectPassword
        
        var errorDescription : String? {
            switch self{
            case .usernameNotFound:
                return "Username Not found"
            case .incorrectPassword:
                return "Password Not found"
            }
      
        }
    }

    // MARK: - Sign In
    func signIn(identifier: String, password: String) async throws {
        do {
            let emailToUse: String

            // Check if identifier looks like an email
            if identifier.contains("@") {
                emailToUse = identifier
            } else {
                // Treat as username — look up the email in Firestore
                let query = try await Firestore.firestore()
                    .collection("users")
                    .whereField("userName", isEqualTo: identifier)
                    .getDocuments()

                guard let document = query.documents.first else {
                    throw AuthError.usernameNotFound
                }

                emailToUse = document.get("email") as? String ?? ""
            }

            // Sign in with the resolved email
            let result = try await Auth.auth().signIn(withEmail: emailToUse, password: password)
          self.userSession = result.user
            await fetchUser()

        } catch {
            print("❌ Sign-in failed: \(error.localizedDescription)")
            throw error
        }
    }


    // MARK: - Sign Out
    func signOut() {
        do {
            try authenticator.signOut()
            self.userSession = nil
            self.currentUser = nil
        } catch {
            print("❌ Sign-out failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Delete Account
    func deleteAccount() async {
        guard let user = authenticator.currentUser else {
            print("❌ No authenticated user.")
            return
        }
        
        do {
            // 1. Delete Firestore user document
            try await db.collection("users").document(user.uid).delete()
            
            // 2. Delete Firebase Auth account
            try await user.delete()
            
            // 3. Clear local state
            self.userSession = nil
            self.currentUser = nil
            
            print("✅ Account deleted successfully.")
        } catch {
            print("Failed to delete account: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Update Username
    func updateUsername(to newUsername: String) async throws {
        guard let uid = userSession?.uid else { return }

        // Check if username already exists
        let exists = try await userExists(userName: newUsername)
        if exists { throw NSError(domain: "UsernameTaken", code: 0) }

        try await db.collection("users").document(uid).updateData(["userName": newUsername])
        self.currentUser?.userName = newUsername
    }


    // MARK: - Update Full Name
    func updateName(to newName: String) async throws {
        guard let uid = userSession?.uid else { return }

        try await db.collection("users").document(uid).updateData(["fullname": newName])
        self.currentUser?.fullname = newName
    }


    // MARK: - Update Email (Requires Re-auth)
    func updateEmail(currentPassword: String, newEmail: String) async throws {
        guard let user = authenticator.currentUser,
              let currentEmail = user.email else { return }

        // Re-authenticate
        let credential = EmailAuthProvider.credential(withEmail: currentEmail, password: currentPassword)
        try await user.reauthenticate(with: credential)

        // Update Auth Email
        try await user.updateEmail(to: newEmail)

        // Update Firestore Email
        try await db.collection("users").document(user.uid).updateData(["email": newEmail])

        self.currentUser?.email = newEmail
    }


    // MARK: - Update Password (Requires Re-auth)
    func updatePassword(currentPassword: String, newPassword: String) async throws {
        guard let user = authenticator.currentUser,
              let email = user.email else { return }

        // Re-authenticate
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        try await user.reauthenticate(with: credential)

        // Update Password
        try await user.updatePassword(to: newPassword)
    }

}

