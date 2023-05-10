//
//  SignUpView.swift
//  GymGenie
//
//  Created by Jake Meissner on 4/3/23.
//

// SignUpView.swift
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

struct SignUpView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var username: String = ""
    @State private var name: String = ""
    @State private var country: String = ""
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Name", text: $name)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)
                
                TextField("Username", text: $username)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)
                
                TextField("Country", text: $country)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)
                
                TextField("Email", text: $email)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(5.0)
                
                Button(action: signUp) {
                    Text("Sign Up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.green)
                        .cornerRadius(15.0)
                }
            }
            .padding()
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .navigationBarTitle("Sign Up", displayMode: .inline)
        }
    }
    
    func signUp() {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                alertTitle = "Error"
                alertMessage = error.localizedDescription
                showingAlert = true
                return
            }
            
            guard let user = authResult?.user else {
                alertTitle = "Error"
                alertMessage = "User not found"
                showingAlert = true
                return
            }
            
            let userData = User(id: user.uid, name: name, username: username, country: country, following: 0, followers: 0)
            let db = Firestore.firestore()
            
            do {
                try db.collection("users").document(user.uid).setData(from: userData)
                self.presentationMode.wrappedValue.dismiss()
            } catch {
                alertTitle = "Error"
                alertMessage = "Failed to save user data"
                showingAlert = true
            }
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}














