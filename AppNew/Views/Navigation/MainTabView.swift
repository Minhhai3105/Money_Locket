import SwiftUI

enum AppTab: Int, CaseIterable {
    case camera = 0
    case wallet = 1
    case chat = 2
    case profile = 3
    
    var iconName: String {
        switch self {
        case .camera: return "camera.fill"
        case .wallet: return "creditcard.fill"
        case .chat: return "bubble.left.and.bubble.right.fill"
        case .profile: return "person.2.fill"
        }
    }
    
    var title: String {
        switch self {
        case .camera: return "Locket"
        case .wallet: return "Ví"
        case .chat: return "Trò Chuyện"
        case .profile: return "Bạn Bè"
        }
    }
}

struct MainTabView: View {
    @State private var activeTab: AppTab = .camera
    
    @StateObject private var cameraVM = CameraViewModel()
    @StateObject private var walletVM = WalletViewModel()
    @StateObject private var chatVM = ChatViewModel()
    @StateObject private var friendsVM = FriendsViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch activeTab {
                case .camera:
                    CameraView(cameraVM: cameraVM)
                case .wallet:
                    WalletDashboardView(walletVM: walletVM)
                case .chat:
                    ChatListView(chatVM: chatVM)
                case .profile:
                    FriendsListView(friendsVM: friendsVM)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Translucent Floating Tabbar overlay
            floatingTabBar
                .padding(.bottom, 34)
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .background(Color.black.ignoresSafeArea())
    }
    
    private var floatingTabBar: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        activeTab = tab
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.iconName)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(activeTab == tab ? .yellow : .white.opacity(0.45))
                            .scaleEffect(activeTab == tab ? 1.25 : 1.0)
                        
                        Text(tab.title)
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(activeTab == tab ? .white : .white.opacity(0.4))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
            }
        }
        .padding(.horizontal, 10)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.6), radius: 12, x: 0, y: 8)
        )
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.12), lineWidth: 1.2)
        )
        .padding(.horizontal, 24)
    }
}
