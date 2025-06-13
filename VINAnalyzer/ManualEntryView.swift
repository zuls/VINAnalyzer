//
//  ManualEntryView.swift
//  VINAnalyzer
//
//  Created by Zularbine Kamal on 6/13/25.
//

import SwiftUI
import Combine

struct ManualEntryView: View {
    @State private var vinInput = ""
    @State private var isValid = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    let onVINEntered: (String) -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                VStack(spacing: 15) {
                    Image(systemName: "keyboard")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("Enter VIN Manually")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Enter the 17-character Vehicle Identification Number")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("VIN")
                        .font(.headline)
                    
                    TextField("Enter 17-character VIN", text: $vinInput)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.allCharacters)
                        .disableAutocorrection(true)
                        .font(.system(.body, design: .monospaced))
                        .onChange(of: vinInput) { _, newValue in
                            vinInput = String(newValue.prefix(17).uppercased())
                            validateVIN()
                        }
                    
                    if !vinInput.isEmpty {
                        HStack {
                            Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(isValid ? .green : .red)
                            Text(isValid ? "Valid VIN format" : "Invalid VIN format")
                                .font(.caption)
                                .foregroundColor(isValid ? .green : .red)
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Button("Confirm VIN") {
                    if isValid {
                        onVINEntered(vinInput)
                    } else {
                        showError("Please enter a valid 17-character VIN")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isValid)
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .navigationTitle("Manual Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel", action: onCancel)
                }
            }
        }
        .alert("Invalid VIN", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func validateVIN() {
        isValid = VINValidator.isValidVIN(vinInput)
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }
}


