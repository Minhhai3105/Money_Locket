import SwiftUI

struct FriendsListView: View {
    @ObservedObject var friendsVM: FriendsViewModel
    @State private var showWidgetSettings = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom Header
                headerView
                
                // Search Bar
                searchBar
                
                ScrollView {
                    VStack(spacing: 24) {
                        if !friendsVM.searchQuery.isEmpty {
                            // Search Results
                            searchResultsSection
                        } else {
                            // Pending Requests
                            if !friendsVM.pendingRequests.isEmpty {
                                pendingRequestsSection
                            }
                            
                            // Friends List
                            friendsListSection
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 120) // Tabbar spacing buffer
                }
            }
            .background(Color.black.ignoresSafeArea())
            .navigationBarHidden(true)
            .preferredColorScheme(.dark)
            .sheet(isPresented: $showWidgetSettings) {
                WidgetSettingsView(friendsVM: friendsVM)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Bạn Bè")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("Vòng lặp bạn thân trên màn hình chính")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            Spacer()
            
            Button(action: { showWidgetSettings = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "w.square.fill")
                        .font(.system(size: 16))
                    Text("Widget")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                }
                .foregroundColor(.black)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.yellow)
                .cornerRadius(12)
                .shadow(color: Color.yellow.opacity(0.3), radius: 8)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 12)
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Tìm kiếm theo tên hoặc tài khoản...", text: $friendsVM.searchQuery)
                .font(.system(size: 15))
                .foregroundColor(.white)
            
            if !friendsVM.searchQuery.isEmpty {
                Button(action: { friendsVM.searchQuery = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.08))
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
    
    private var searchResultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("KẾT QUẢ TÌM KIẾM")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)
                .tracking(1)
                .padding(.horizontal, 24)
            
            if friendsVM.searchResults.isEmpty {
                Text("Không tìm thấy kết quả nào phù hợp.")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 24)
            } else {
                ForEach(friendsVM.searchResults) { user in
                    HStack(spacing: 16) {
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 46, height: 46)
                            .overlay(
                                Text(String(user.username.first ?? "U").uppercased())
                                    .foregroundColor(.yellow)
                                    .fontWeight(.bold)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.displayName ?? user.username)
                                .font(.system(size: 15, weight: .bold))
                            Text("@\(user.username)")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            friendsVM.addFriend(username: user.username)
                        }) {
                            Text("Kết bạn")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Color.yellow)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                }
            }
        }
    }
    
    private var pendingRequestsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("YÊU CẦU KẾT BẠN PENDING")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)
                .tracking(1)
                .padding(.horizontal, 24)
            
            ForEach(friendsVM.pendingRequests) { user in
                HStack(spacing: 16) {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 46, height: 46)
                        .overlay(
                            Text(String(user.username.first ?? "U").uppercased())
                                .foregroundColor(.yellow)
                                .fontWeight(.bold)
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.displayName ?? user.username)
                            .font(.system(size: 15, weight: .bold))
                        Text("@\(user.username)")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        friendsVM.acceptFriendRequest(user)
                    }) {
                        Text("Đồng ý")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.yellow)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 6)
            }
        }
    }
    
    private var friendsListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("BẠN BÈ HIỆN TẠI (\(friendsVM.friends.count))")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)
                .tracking(1)
                .padding(.horizontal, 24)
            
            if friendsVM.friends.isEmpty {
                Text("Chưa có bạn bè nào. Tìm kiếm và thêm bạn ngay!")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
            } else {
                ForEach(friendsVM.friends) { friend in
                    HStack(spacing: 16) {
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 48, height: 48)
                            .overlay(
                                Text(String(friend.username.first ?? "U").uppercased())
                                    .foregroundColor(.yellow)
                                    .fontWeight(.bold)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(friend.displayName ?? friend.username)
                                .font(.system(size: 15, weight: .bold))
                            Text("@\(friend.username)")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.yellow)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                }
            }
        }
    }
}
