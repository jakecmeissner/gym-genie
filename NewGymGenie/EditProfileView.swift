//
//  EditProfileView.swift
//  NewGymGenie
//
//  Created by Jake Meissner on 4/17/23.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import Combine

struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var editProfileViewModel = EditProfileViewModel()
    @State private var selectedCountryIndex: Int
    @State private var cancellables = Set<AnyCancellable>()

    init(selectedCountryIndex: Int = 0) {
        self._selectedCountryIndex = State(initialValue: selectedCountryIndex)
    }
    
    private var initialCountryIndex: Int {
        countryObjects.firstIndex(where: { $0.name == editProfileViewModel.country }) ?? 0
    }

    static func createCountryObjects() -> [Country] {
        let unsortedCountries = Locale.Region.isoRegions.map { Locale.current.localizedString(forRegionCode: $0.identifier) ?? $0.identifier }
        let unitedStatesName = Locale.current.localizedString(forRegionCode: "US") ?? "United States"
        let sortedCountries = unsortedCountries.filter { $0 != unitedStatesName }.sorted()
        let countries = [unitedStatesName] + sortedCountries
        return countries.map { Country(name: $0) }
    }
    
    let countryObjects = EditProfileView.createCountryObjects()
    
    var body: some View {
        VStack {
            header
            
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Full Name")
                        .font(Font.custom("Poppins-Light", size: 16))
                        .foregroundColor(color3)
                    
                    TextField("Full Name", text: $editProfileViewModel.name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Text("Username")
                        .font(Font.custom("Poppins-Light", size: 16))
                        .foregroundColor(color3)
                    
                    TextField("Username", text: $editProfileViewModel.username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Text("Country")
                        .font(Font.custom("Poppins-Light", size: 16))
                        .foregroundColor(color3)
                    
                    Picker("Country", selection: $selectedCountryIndex) {
                        ForEach(countryObjects) { country in
                            Text(country.name).tag(countryObjects.firstIndex(of: country)!)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: selectedCountryIndex, perform: { _ in
                        editProfileViewModel.country = countryObjects[selectedCountryIndex].name
                    })
                }
                .padding(.horizontal)
            }
            
            Button(action: {
                editProfileViewModel.updateUserProfile { success in
                    if success {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }) {
                Text("Save")
                    .font(Font.custom("Poppins-Bold", size: 16))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(color3.clipShape(RoundedRectangle(cornerRadius: 10)))
            }
            .padding(.top)
            
            Spacer()
        }
        .onAppear {
            editProfileViewModel.fetchUserData()
            editProfileViewModel.$country
                .sink { country in
                    selectedCountryIndex = countryObjects.firstIndex(where: { $0.name == country }) ?? 0
                }
                .store(in: &cancellables)
        }
        .navigationBarHidden(true) // Hide the default iOS back button
        .padding(.bottom, 150) // Add this line
    }
    
    var header: some View {
        let headerGradient = LinearGradient(gradient: Gradient(colors: [color1, color2, color3]), startPoint: .leading, endPoint: .trailing)
        
        return VStack {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.white)
                }
                .padding(.leading)
                
                Spacer()
                
                Text("Edit Profile")
                    .font(Font.custom("Poppins-Regular", size: 24))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity) // Center the text horizontally
                
                Spacer()
            }
            .padding(.top, 30)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity)
        .background(headerGradient.edgesIgnoringSafeArea(.top))
    }
}

struct Country: Identifiable, Equatable {
    let id = UUID()
    let name: String
}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView(selectedCountryIndex: 0)
    }
}





