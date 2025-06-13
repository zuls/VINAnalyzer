//
//  ScannerOverlayView.swift
//  VINAnalyzer
//
//  Created by Zularbine Kamal on 6/13/25.
//

import UIKit
import SwiftUI

struct ScannerOverlayView: View {
    @ObservedObject var viewModel: ScannerViewModel
    let onManualEntry: () -> Void
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Top instruction area
                VStack(spacing: 10) {
                    Text("Scan Vehicle VIN")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(instructionText)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 50)
                
                Spacer()
                
                // Scanning frame
                ScanningFrameView()
                    .frame(width: 280, height: 80)
                
                Spacer()
                
                // Bottom controls
                VStack(spacing: 20) {
                    // Status indicator
                    StatusIndicatorView(status: viewModel.scanningStatus)
                    
                    // Control buttons
                    HStack(spacing: 30) {
                        // Torch button
                        Button(action: { viewModel.torchEnabled.toggle() }) {
                            Image(systemName: viewModel.torchEnabled ? "flashlight.on.fill" : "flashlight.off.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                        
                        // Manual entry button
                        Button("Enter Manually") {
                            onManualEntry()
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .clipShape(Capsule())
                    }
                }
                .padding(.bottom, 50)
            }
        }
    }
    
    private var instructionText: String {
        switch viewModel.scanningStatus {
        case .ready:
            return "Position the VIN barcode within the frame"
        case .scanning:
            return "Scanning... Hold steady"
        case .success:
            return "VIN captured successfully!"
        case .failed:
            return "Scan failed. Please try again"
        case .timeout:
            return "Scan timeout. Try again or enter manually"
        }
    }
}

struct ScanningFrameView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Frame corners
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.green, lineWidth: 3)
                .background(Color.clear)
            
            // Scanning line animation
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.clear, Color.green, Color.clear]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 2)
                .offset(x: isAnimating ? 140 : -140)
                .animation(
                    Animation.linear(duration: 2.0).repeatForever(autoreverses: true),
                    value: isAnimating
                )
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct StatusIndicatorView: View {
    let status: ScannerViewModel.ScanningStatus
    
    var body: some View {
        HStack(spacing: 8) {
            statusIcon
            Text(statusText)
                .font(.headline)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(statusColor.opacity(0.8))
        .clipShape(Capsule())
    }
    
    @ViewBuilder
    private var statusIcon: some View {
        switch status {
        case .ready:
            Image(systemName: "camera.viewfinder")
                .foregroundColor(.white)
        case .scanning:
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(0.8)
        case .success:
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.white)
        case .failed, .timeout:
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.white)
        }
    }
    
    private var statusText: String {
        switch status {
        case .ready: return "Ready to scan"
        case .scanning: return "Scanning..."
        case .success: return "Success!"
        case .failed: return "Failed"
        case .timeout: return "Timeout"
        }
    }
    
    private var statusColor: Color {
        switch status {
        case .ready: return .blue
        case .scanning: return .orange
        case .success: return .green
        case .failed, .timeout: return .red
        }
    }
}

