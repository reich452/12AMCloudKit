//
//  CameraViewController.swift
//  12AMCloudKit
//
//  Created by Nick Reichard on 6/20/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    // MARK: - TODO: No BANGS! & Call the CamearController (Same functions, but doesn't work)
    
    // MARK: - Properties
    
    fileprivate let captureSession = AVCaptureSession()
    fileprivate var camera: AVCaptureDevice!
    fileprivate var cameraPreviewLayer: AVCaptureVideoPreviewLayer!
    fileprivate var cameraCaptureOutput: AVCapturePhotoOutput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeCaptureSession()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.barTintColor = UIColor.clearBlur
    }
    
    func displayCapturedPhoto(capturedPhoto : UIImage) {
        
        let cameraPreviewViewController = storyboard?.instantiateViewController(withIdentifier: "CameraPreviewViewController") as! CameraPreviewViewController
        cameraPreviewViewController.capturedImage = capturedPhoto
        navigationController?.pushViewController(cameraPreviewViewController, animated: true)
    }
    
    // MARK: - Actions
    
    @IBAction func cameraToggleButton(_ sender: Any) {
        switchCameraInput()
    }
    
    @IBAction func takePicture(_ sender: Any) {
        
        takePicture()
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Main
    
    func initializeCaptureSession() {
        
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        camera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            let cameraCaptureInput = try AVCaptureDeviceInput(device: camera)
            cameraCaptureOutput = AVCapturePhotoOutput()
            
            captureSession.addInput(cameraCaptureInput)
            captureSession.addOutput(cameraCaptureOutput)
            
        } catch {
            print(error.localizedDescription)
        }
        
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        cameraPreviewLayer.frame = view.bounds
        cameraPreviewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.portrait
        
        view.layer.insertSublayer(cameraPreviewLayer, at: 0)
        
        captureSession.startRunning()
    }
    
    func takePicture() {
        // Many settings to customize
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        
        cameraCaptureOutput?.capturePhoto(with: settings, delegate: self)
    }
    
    // MARK: - Toggle
    
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
            print("Error: Cannot Capure newInput \(error.localizedDescription)")
        }
        
        self.captureSession.commitConfiguration()
    }
}

extension CameraViewController : AVCapturePhotoCaptureDelegate {
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        if let error = error {
            print(error.localizedDescription)
        } else {
            
            if let sampleBuffer = photoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer) {
                
                if let finalImage = UIImage(data: dataImage) {
                    
                    displayCapturedPhoto(capturedPhoto: finalImage)
                }
            }
        }
    }
}

// MARK: - Handle Positions

extension CameraViewController {
    
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


