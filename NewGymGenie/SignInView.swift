//
//  SignInView.swift
//  NewGymGenie
//
//  Created by Jake Meissner on 4/26/23.
//

// SignInView.swift
import SwiftUI
import FirebaseAuth

struct SignInView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Email", text: $email)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(5.0)
                
                Button(action: signIn) {
                    Text("Sign In")
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
            .navigationBarTitle("Sign In", displayMode: .inline)
        }
    }
    
    func signIn() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                alertTitle = "Error"
                alertMessage = error.localizedDescription
                showingAlert = true
                return
            }
            
            guard authResult?.user != nil else {
                alertTitle = "Error"
                alertMessage = "User not found"
                showingAlert = true
                return
            }
            
            self.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}


