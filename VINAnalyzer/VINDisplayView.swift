//
//  VINDisplayView.swift
//  VINAnalyzer
//
//  Created by Zularbine Kamal on 6/13/25.
//

import UIKit
import SwiftUI
import Combine
import CoreData
import LocalAuthentication
import MessageUI
import SafariServices

import AVFoundation

struct VINDisplayView: View {
    let vin: String
    let onRescan: () -> Void
    let onSave: () -> Void
    
    @State private var showCopiedAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("VIN Successfully Scanned")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                .padding(.top, 20)
                
                // VIN Display
                VStack(spacing: 15) {
                    Text("Vehicle Identification Number")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(vin)
                        .font(.system(.title, design: .monospaced))
                        .fontWeight(.bold)
                        .padding(20)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.green, lineWidth: 2)
                        )
                        .contextMenu {
                            Button(action: copyVIN) {
                                Label("Copy VIN", systemImage: "doc.on.doc")
                            }
                        }
                }
                
                // VIN Information
                VINInfoView(vin: vin)
                
                // Action Buttons
                VStack(spacing: 15) {
                    Button(action: copyVIN) {
                        Label("Copy VIN", systemImage: "doc.on.doc")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button(action: onSave) {
                        Label("Save VIN", systemImage: "square.and.arrow.down")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Scan Another VIN", action: onRescan)
                        .frame(maxWidth: .infinity)
                        .buttonStyle(.bordered)
                }
                .padding(.horizontal, 20)
                
                Spacer(minLength: 20)
            }
        }
        .alert("VIN Copied!", isPresented: $showCopiedAlert) {
            Button("OK") { }
        }
    }
    
    private func copyVIN() {
        UIPasteboard.general.string = vin
        showCopiedAlert = true
    }
}

struct VINInfoView: View {
    let vin: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("VIN Information")
                .font(.headline)
                .padding(.bottom, 5)
            
            VStack(spacing: 8) {
                InfoRow(title: "World Manufacturer", value: worldManufacturer)
                InfoRow(title: "Vehicle Descriptor", value: vehicleDescriptor)
                InfoRow(title: "Check Digit", value: String(vin.dropFirst(8).first ?? " "))
                InfoRow(title: "Model Year", value: modelYear)
                InfoRow(title: "Plant Code", value: String(vin.dropFirst(10).first ?? " "))
                InfoRow(title: "Serial Number", value: String(vin.suffix(6)))
            }
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 20)
    }
    
    private var worldManufacturer: String {
        String(vin.prefix(3))
    }
    
    private var vehicleDescriptor: String {
        String(vin.dropFirst(3).prefix(5))
    }
    
    private var modelYear: String {
        // Simplified model year decoding
        let yearChar = vin.dropFirst(9).first ?? " "
        return String(yearChar)
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .font(.system(.body, design: .monospaced))
        }
    }
}
