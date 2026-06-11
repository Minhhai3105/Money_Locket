import SwiftUI
import Combine

class FriendsViewModel: ObservableObject {
    @Published var friends: [User] = []
    @Published var pendingRequests: [User] = []
    @Published var searchResults: [User] = []
    @Published var searchQuery: String = "" {
        didSet {
            performSearch()
        }
    }
    
    // Config properties for widget
    @Published var selectedWidgetFriend: User? = nil
    @Published var widgetUpdateFrequency = "Real-time"
    
    init() {
        loadMockFriends()
    }
    
    func acceptFriendRequest(_ user: User) {
        DispatchQueue.main.async {
            self.pendingRequests.removeAll { $0.id == user.id }
            self.friends.append(user)
            self.selectedWidgetFriend = user
            self.updateWidgetPreferences()
        }
    }
    
    func addFriend(username: String) {
        // Mock sending request
        print("Friend request sent to @\(username)")
    }
    
    func updateWidgetPreferences() {
        print("Widget settings updated. Selected Friend: \(selectedWidgetFriend?.username ?? "All Friends"). Frequency: \(widgetUpdateFrequency)")
        // In full app, write to shared AppGroup UserDefaults to sync with WidgetKit
    }
    
    private func performSearch() {
        guard !searchQuery.isEmpty else {
            searchResults = []
            return
        }
        
        let allPossibleUsers = [
            User(id: UUID(), username: "tuan_anh", displayName: "Tuấn Anh", avatarUrl: "https://picsum.photos/150/150?random=11", createdAt: Date()),
            User(id: UUID(), username: "phuong_thao", displayName: "Phương Thảo", avatarUrl: "https://picsum.photos/150/150?random=12", createdAt: Date()),
            User(id: UUID(), username: "huy_hoang", displayName: "Huy Hoàng", avatarUrl: "https://picsum.photos/150/150?random=13", createdAt: Date())
        ]
        
        searchResults = allPossibleUsers.filter {
            $0.username.lowercased().contains(searchQuery.lowercased()) ||
            ($0.displayName?.lowercased().contains(searchQuery.lowercased()) ?? false)
        }
    }
    
    private func loadMockFriends() {
        let f1 = User(id: UUID(), username: "linh_dan", displayName: "Linh Đan", avatarUrl: "https://picsum.photos/150/150?random=1", createdAt: Date())
        let f2 = User(id: UUID(), username: "minh_quan", displayName: "Minh Quân", avatarUrl: "https://picsum.photos/150/150?random=2", createdAt: Date())
        let f3 = User(id: UUID(), username: "huong_giang", displayName: "Hương Giang", avatarUrl: "https://picsum.photos/150/150?random=3", createdAt: Date())
        
        self.friends = [f1, f2, f3]
        self.selectedWidgetFriend = f1
        
        let p1 = User(id: UUID(), username: "viet_bach", displayName: "Việt Bách", avatarUrl: "https://picsum.photos/150/150?random=4", createdAt: Date())
        let p2 = User(id: UUID(), username: "khanh_linh", displayName: "Khánh Linh", avatarUrl: "https://picsum.photos/150/150?random=5", createdAt: Date())
        
        self.pendingRequests = [p1, p2]
    }
}
