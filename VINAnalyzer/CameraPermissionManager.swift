//
//  CameraPermissionManager.swift
//  VINAnalyzer
//
//  Created by Zularbine Kamal on 6/13/25.
//

import AVFoundation
import SwiftUI

class CameraPermissionManager: ObservableObject {
    @Published var permissionStatus: AVAuthorizationStatus = .notDetermined
    @Published var showPermissionAlert = false
    
    init() {
        checkPermissionStatus()
    }
    
    func checkPermissionStatus() {
        permissionStatus = AVCaptureDevice.authorizationStatus(for: .video)
    }
    
    func requestCameraAccess() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                self?.permissionStatus = granted ? .authorized : .denied
                if !granted {
                    self?.showPermissionAlert = true
                }
            }
        }
    }
}
