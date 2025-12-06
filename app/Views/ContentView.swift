//
//  ContentView.swift
//  app
//
//  Created by Kunal Sharma on 05/12/25.
//

import SwiftUI
import Combine
import VisionKit
import AVFoundation
import GoogleSignIn

struct ContentView: View {
    @State private var scannedCode: String = "Scan the QR code behind your book"
    // @StateObject private var gyroManager = GyroscopeManager()
    @State private var currentEmoji: String = "✌️"
    @State private var showEmoji: Bool = false
    @State private var emojiOffset: CGFloat = 0
    @Binding var isLoggedIn: Bool
    @ObservedObject var subjectsManager: SubjectsManager
    @State private var selectedSubject: Subject?
    @State private var showInvalidAlert: Bool = false
    @State private var showConfirmationDialog: Bool = false
    @State private var pendingSubjectName: String = ""
    @State private var pendingQRCode: String = ""
    @State private var showSubjectsList: Bool = false
    @State private var iconsAnimated: Bool = false
    
    // New states for UX
    @State private var isScanningSubject: Bool = false
    
    // Side Menu State
    @State private var showSideMenu: Bool = false
    @State private var showCollegeApp: Bool = false
    
    let userName: String
    let emojis = ["✌️", "👋", "😴", "🤓", "👀", "📚", "🫡", "❤️", "🔥", "🙄"]
    let timer = Timer.publish(every: 10.0, on: .main, in: .common).autoconnect()
    
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Good night"
        }
    }
    
    var body: some View {
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 40) {
                // Greeting
                ZStack {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(greeting),")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.black)
                            Text(userName)
                                .font(.system(size: 32, weight: .regular))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 60)
                    .offset(y: iconsAnimated ? -40 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: iconsAnimated)
                    
                    HStack {
                        // Hamburger Menu Button
                        Button(action: {
                            withAnimation {
                                showSideMenu = true
                            }
                        }) {
                            Image(systemName: "line.3.horizontal")
                                .font(.system(size: 24))
                                .foregroundColor(.gray)
                        }
                        .offset(y: iconsAnimated ? -180 : UIScreen.main.bounds.height - 60)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: iconsAnimated)
                        
                        Spacer()
                        
                        // Sign Out Button
                        Button(action: signOut) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 24))
                                .foregroundColor(.gray)
                        }
                        .offset(y: iconsAnimated ? -180 : UIScreen.main.bounds.height - 60)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: iconsAnimated)
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 60)
                }
                
                // Scanner Section
                ZStack {
                    // Emoji popping up from right side
                    Text(currentEmoji)
                        .font(.system(size: 100)) // Bigger
                        .rotationEffect(.degrees(15)) // Tilted
                        .offset(x: showEmoji ? 120 : 80, y: -160) // Pop out to the right and higher up
                        .opacity(showEmoji ? 1 : 0)
                        .scaleEffect(showEmoji ? 1.0 : 0.5)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showEmoji)
                        .zIndex(0)
                    
                    // Scanner Frame
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray, lineWidth: 2)
                            .frame(width: 300, height: 300)
                            .background(Color.white)
                            .cornerRadius(20)
                        
                        ScannerViewWrapper(scannedCode: $scannedCode, onScan: handleScan)
                            .frame(width: 300, height: 300)
                            .cornerRadius(20)
                        
                        // Loading Overlay
                        if isScanningSubject {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                                .scaleEffect(1.5)
                                .padding(50)
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(8)
                        }
                    }
                    .zIndex(1)
                }
                
                // Scanned Text
                Text(scannedCode)
                    .foregroundColor(.black)
                    .font(.headline)
            }
            
            // Side Menu Overlay
            SideMenuView(
                isShowing: $showSideMenu,
                onSelectSubject: {
                    showSubjectsList = true
                },
                onSelectStudyPlan: {
                    // Future implementation
                },
                onSelectCollegeApp: {
                    showCollegeApp = true
                }
            )
            .zIndex(2)
        }
        .onReceive(timer) { _ in
            triggerRandomEmoji()
        }
        .onAppear {
            triggerRandomEmoji()
            // Animate icons sliding up from bottom
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                iconsAnimated = true
            }
            
            // Sync user to DB
            if let email = UserDefaults.standard.string(forKey: "userEmail") {
                Task {
                    await subjectsManager.syncUser(email: email, name: userName)
                }
            }
        }
        .confirmationDialog("Add Subject?", isPresented: $showConfirmationDialog, titleVisibility: .visible) {
            Button("Yes, add \(pendingSubjectName)") {
                confirmAddSubject()
            }
            Button("Cancel", role: .cancel) {
                // Reset pending data
                pendingSubjectName = ""
                pendingQRCode = ""
            }
        } message: {
            Text("Do you want to add '\(pendingSubjectName)' to your subjects?")
        }
        .sheet(item: $selectedSubject) { subject in
            NavigationView {
                SubjectDetailView(subjectsManager: subjectsManager, subject: subject)
            }
        }
        .alert("Invalid Book", isPresented: $showInvalidAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("This is not a valid ncert book")
        }
        .sheet(isPresented: $showSubjectsList) {
            SubjectsListView(subjectsManager: subjectsManager)
        }
        .sheet(isPresented: $showCollegeApp) {
            CollegeAppView(subjectsManager: subjectsManager)
        }
        .sheet(item: $selectedSubject) { subject in
            NavigationView {
                SubjectDetailView(subjectsManager: subjectsManager, subject: subject)
            }
        }
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        withAnimation {
            isLoggedIn = false
        }
    }
    
    func handleScan(code: String) {
        // Prevent duplicate scans or scans while loading
        guard !isScanningSubject else { return }
        
        isScanningSubject = true
        scannedCode = code
        
        print("🔍 Scanned QR Code: \(code)")
        
        // Check if valid subject
        Task {
            if let subjectName = await subjectsManager.checkSubjectExists(qrCode: code) {
                // Show confirmation dialog
                await MainActor.run {
                    pendingSubjectName = subjectName
                    pendingQRCode = code
                    showConfirmationDialog = true
                    isScanningSubject = false
                }
            } else {
                print("❌ No subject found for QR code: \(code)")
                await MainActor.run {
                    showInvalidAlert = true
                    isScanningSubject = false
                }
            }
        }
        
        triggerRandomEmoji()
    }
    
    func confirmAddSubject() {
        isScanningSubject = true
        
        Task {
            let success = await subjectsManager.addUserToSubject(qrCode: pendingQRCode)
            
            await MainActor.run {
                isScanningSubject = false
                
                if success {
                    // Clear pending data
                    pendingSubjectName = ""
                    pendingQRCode = ""
                    
                    // Simply redirect to subjects page
                    showSubjectsList = true
                }
            }
        }
    }
    
    func triggerRandomEmoji() {
        // Reset
        showEmoji = false
        
        // Delay slightly to change emoji and pop up
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            currentEmoji = emojis.randomElement() ?? "✌️"
            showEmoji = true
            
            // Hide after 8 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
                showEmoji = false
            }
        }
    }
}

struct ScannerViewWrapper: UIViewControllerRepresentable {
    @Binding var scannedCode: String
    var onScan: (String) -> Void
    
    func makeUIViewController(context: Context) -> ScannerViewController {
        let scannerViewController = ScannerViewController()
        scannerViewController.delegate = context.coordinator
        return scannerViewController
    }
    
    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {
        // Nothing needed here
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, ScannerViewControllerDelegate {
        var parent: ScannerViewWrapper
        var lastScanTime: Date = Date(timeIntervalSince1970: 0)
        
        init(_ parent: ScannerViewWrapper) {
            self.parent = parent
        }
        
        func didScanCode(_ code: String) {
            let now = Date()
            
            // Only scan every 5 seconds
            guard now.timeIntervalSince(lastScanTime) >= 5.0 else { return }
            
            lastScanTime = now
            parent.scannedCode = code
            parent.onScan(code)
        }
    }
}

protocol ScannerViewControllerDelegate: AnyObject {
    func didScanCode(_ code: String)
}

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    weak var delegate: ScannerViewControllerDelegate?
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if captureSession?.canAddInput(videoInput) == true {
            captureSession?.addInput(videoInput)
        } else {
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession?.canAddOutput(metadataOutput) == true {
            captureSession?.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let previewLayer = previewLayer {
            previewLayer.frame = view.layer.bounds
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            delegate?.didScanCode(stringValue)
        }
    }
}

#Preview {
    ContentView(isLoggedIn: .constant(true), subjectsManager: SubjectsManager(), userName: "Preview User")
}
