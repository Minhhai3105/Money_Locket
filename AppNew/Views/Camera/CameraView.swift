import SwiftUI
import AVFoundation

struct CameraView: View {
    @ObservedObject var cameraVM: CameraViewModel
    @State private var isHeartShape = false
    @State private var showInputModal = false
    @State private var selectedTransactionType: TransactionType = .social_only
    @State private var animatePulse = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("MONEY LOCKET")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .tracking(3)
                        .foregroundColor(.yellow)
                    Text("Vừa chia sẻ vừa quản lý chi tiêu")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                Spacer()
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        isHeartShape.toggle()
                    }
                }) {
                    Image(systemName: isHeartShape ? "square.fill" : "heart.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                        .padding(12)
                        .background(Color.yellow)
                        .clipShape(Circle())
                        .shadow(color: Color.yellow.opacity(0.3), radius: 8)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 60)
            
            // Camera Feed container
            ZStack {
                if let image = cameraVM.capturedImage {
                    // Preview Frozen State
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 320, height: 320)
                        .clipShape(customMask)
                        .overlay(customMask.stroke(Color.yellow, lineWidth: 3))
                        .transition(.scale.combined(with: .opacity))
                } else {
                    // Live Feed State
                    Group {
                        if cameraVM.isSessionRunning {
                            CameraPreviewRepresentable(session: cameraVM.session)
                        } else {
                            // Rich visual representation on simulator
                            ZStack {
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "1F1C2C"), Color(hex: "928DAB")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                
                                VStack(spacing: 12) {
                                    Image(systemName: "camera.shutter.button.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.white.opacity(0.8))
                                        .scaleEffect(animatePulse ? 1.08 : 0.95)
                                        .onAppear {
                                            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                                                animatePulse = true
                                            }
                                        }
                                    
                                    Text("Simulated Viewfinder")
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            }
                        }
                    }
                    .frame(width: 320, height: 320)
                    .clipShape(customMask)
                    .overlay(customMask.stroke(Color.white.opacity(0.25), lineWidth: 2))
                    .overlay(
                        // Zoom Slider overlay
                        HStack {
                            Spacer()
                            CustomZoomSlider(zoomFactor: $cameraVM.zoomFactor)
                                .padding(.trailing, 16)
                        }
                    )
                }
            }
            .frame(width: 320, height: 320)
            .padding(.top, 10)
            
            Spacer()
            
            // Control Buttons Panel
            VStack(spacing: 24) {
                if cameraVM.capturedImage != nil {
                    // Post Capture buttons
                    VStack(spacing: 12) {
                        HStack(spacing: 14) {
                            // Thu Vào (+) Button
                            Button(action: {
                                selectedTransactionType = .income
                                showInputModal = true
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Thu Vào")
                                        .fontWeight(.bold)
                                }
                                .font(.system(size: 15, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(Color.green)
                                .cornerRadius(16)
                                .shadow(color: Color.green.opacity(0.3), radius: 8, y: 4)
                            }
                            
                            // Chi Ra (-) Button
                            Button(action: {
                                selectedTransactionType = .expense
                                showInputModal = true
                            }) {
                                HStack {
                                    Image(systemName: "minus.circle.fill")
                                    Text("Chi Ra")
                                        .fontWeight(.bold)
                                }
                                .font(.system(size: 15, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(Color.red)
                                .cornerRadius(16)
                                .shadow(color: Color.red.opacity(0.3), radius: 8, y: 4)
                            }
                        }
                        
                        // Send Social Only Button
                        Button(action: {
                            withAnimation {
                                cameraVM.sendSocialOnly()
                            }
                        }) {
                            HStack {
                                Text("Locket Gửi Bạn Bè")
                                    .fontWeight(.bold)
                                Image(systemName: "paperplane.fill")
                            }
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.yellow)
                            .cornerRadius(18)
                            .shadow(color: Color.yellow.opacity(0.4), radius: 10, y: 5)
                        }
                        
                        // Retake button
                        Button(action: {
                            withAnimation {
                                cameraVM.resetCamera()
                            }
                        }) {
                            Text("Chụp Lại")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.6))
                                .padding(.vertical, 6)
                        }
                    }
                    .padding(.horizontal, 28)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    // Shutter button
                    VStack(spacing: 8) {
                        Button(action: {
                            cameraVM.capturePhoto()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 80, height: 80)
                                
                                Circle()
                                    .stroke(Color.black, lineWidth: 2)
                                    .frame(width: 70, height: 70)
                                
                                Circle()
                                    .stroke(Color.white, lineWidth: 3)
                                    .frame(width: 88, height: 88)
                            }
                        }
                        
                        Text("Chạm để chụp")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    .padding(.bottom, 60)
                }
            }
            
            Spacer()
        }
        .background(Color.black.ignoresSafeArea())
        .sheet(isPresented: $showInputModal) {
            if let capturedImage = cameraVM.capturedImage {
                TransactionInputModal(
                    image: capturedImage,
                    type: selectedTransactionType,
                    onSave: { amount, category, notes in
                        cameraVM.saveTransaction(amount: amount, category: category, notes: notes, type: selectedTransactionType)
                        showInputModal = false
                        cameraVM.resetCamera()
                    }
                )
                .presentationDetents([.fraction(0.85), .large])
                .presentationDragIndicator(.visible)
            }
        }
    }
    
    private var customMask: AnyShape {
        if isHeartShape {
            return AnyShape(HeartShape())
        } else {
            return AnyShape(RoundedRectangle(cornerRadius: 36, style: .continuous))
        }
    }
}

// Extension to load hex colors easily for styling
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 1)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
