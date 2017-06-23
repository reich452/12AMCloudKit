//
//  CameraController.swift
//  12AMCloudKit
//
//  Created by Nick Reichard on 6/20/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import Foundation
import AVFoundation

struct CameraController {
    
    // MARK: - TODO: Call this in the CameraViewController
    
    static let shared = CameraController()
    let captureSession = AVCaptureSession()
    
    func switchCameraInput() {
        self.captureSession.beginConfiguration()
        
        var existingConnection: AVCaptureDeviceInput?
        var newInput: AVCaptureDeviceInput?
        var newCamera: AVCaptureDevice?
        
        for connection in self.captureSession.inputs {
            guard let input = connection as? AVCaptureDeviceInput else { return }
            if input.device.hasMediaType(AVMediaTypeVideo) {
                existingConnection = input
            }
        }
        self.captureSession.removeInput(existingConnection)
        
        if let oldCamera = existingConnection {
            if oldCamera.device.position == .back {
                newCamera = self.cameraWithPosition(position: .front)
            } else {
                newCamera = self.cameraWithPosition(position: .back)
            }
        }
        
        do {                                        // TODO: Safley unwrap newCamera
            newInput = try AVCaptureDeviceInput(device: newCamera)
            self.captureSession.addInput(newInput)
        } catch {
            print("Error: Cannot Capure NewInput \(error.localizedDescription)")
        }
        
        self.captureSession.commitConfiguration()
    }
}

extension CameraController {
    
    func cameraWithPosition(position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        // A query for finding and monitoring available capture devices
        let discovery = AVCaptureDeviceDiscoverySession(deviceTypes: [AVCaptureDeviceType.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .unspecified) as AVCaptureDeviceDiscoverySession
        
        for device in discovery.devices as [AVCaptureDevice] {
            if device.position == position {
                return device
            }
        }
        return nil
    }
}
