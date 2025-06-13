//
//  ContentView.swift
//  VINAnalyzer
//
//  Created by Zularbine Kamal on 6/13/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ScannerViewModel()
    @StateObject private var permissionManager = CameraPermissionManager()
    @State private var showingManualEntry = false
    
    var body: some View {
        Group {
            if let vin = viewModel.scannedVIN {
                VINDisplayView(
                    vin: vin,
                    onRescan: {
                        viewModel.resetScanner()
                    },
                    onSave: {
                        // Implement save functionality
                        print("Saving VIN: \(vin)")
                    }
                )
            } else {
                scannerView
            }
        }
        .sheet(isPresented: $showingManualEntry) {
            ManualEntryView(
                onVINEntered: { vin in
                    viewModel.scannedVIN = vin
                    showingManualEntry = false
                },
                onCancel: {
                    showingManualEntry = false
                }
            )
        }
        .alert("Camera Access Required", isPresented: $permissionManager.showPermissionAlert) {
            Button("Settings") {
                openAppSettings()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please enable camera access in Settings to scan VIN codes.")
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage ?? "Unknown error occurred")
        }
    }
    
    @ViewBuilder
    private var scannerView: some View {
        switch permissionManager.permissionStatus {
        case .authorized:
            ZStack {
                BarcodeScannerView(viewModel: viewModel)
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        viewModel.startScanning()
                    }
                    .onDisappear {
                        viewModel.stopScanning()
                    }
                
                ScannerOverlayView(viewModel: viewModel){
                    showingManualEntry = true
                }
            }
            
        case .denied, .restricted:
            CameraPermissionDeniedView {
                openAppSettings()
            }
            
        case .notDetermined:
            CameraPermissionRequestView {
                permissionManager.requestCameraAccess()
            }
            
        @unknown default:
            EmptyView()
        }
    }
    
    private func openAppSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

// MARK: - Permission Views

struct CameraPermissionRequestView: View {
    let onRequestPermission: () -> Void
    
    var body: some View {
        VStack(spacing: 25) {
            Image(systemName: "camera.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            VStack(spacing: 15) {
                Text("Camera Access Required")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("This app needs camera access to scan VIN barcodes from your vehicle.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }
            
            Button("Allow Camera Access") {
                onRequestPermission()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(40)
    }
}

struct CameraPermissionDeniedView: View {
    let onOpenSettings: () -> Void
    
    var body: some View {
        VStack(spacing: 25) {
            Image(systemName: "camera.fill.badge.ellipsis")
                .font(.system(size: 80))
                .foregroundColor(.red)
            
            VStack(spacing: 15) {
                Text("Camera Access Denied")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Please enable camera access in Settings to use the VIN scanner.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }
            
            Button("Open Settings") {
                onOpenSettings()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(40)
    }
}
