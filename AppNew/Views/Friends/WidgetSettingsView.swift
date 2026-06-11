import SwiftUI

struct WidgetSettingsView: View {
    @ObservedObject var friendsVM: FriendsViewModel
    @Environment(\.dismiss) var dismiss
    
    let frequencies = ["Real-time", "Every 15 mins", "Hourly", "Daily"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 28) {
                    
                    // 1. Mock Widget Preview Panel
                    VStack(spacing: 12) {
                        Text("XEM TRƯỚC MÀN HÌNH CHÍNH")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                            .tracking(1)
                        
                        // Outer simulated iPhone home screen background
                        ZStack {
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "0F2027"), Color(hex: "203A43"), Color(hex: "2C5364")]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                ))
                                .frame(width: 200, height: 200)
                                .shadow(radius: 10)
                            
                            // App Widget Frame
                            VStack(spacing: 6) {
                                ZStack {
                                    // Widget image
                                    if let urlString = friendsVM.selectedWidgetFriend?.avatarUrl, let url = URL(string: urlString) {
                                        AsyncImage(url: url) { image in
                                            image.resizable()
                                                 .scaledToFill()
                                        } placeholder: {
                                            Color.gray.opacity(0.3)
                                        }
                                        .frame(width: 130, height: 130)
                                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                                    } else {
                                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                                            .fill(Color.white.opacity(0.12))
                                            .frame(width: 130, height: 130)
                                            .overlay(
                                                Image(systemName: "photo")
                                                    .font(.system(size: 26))
                                                    .foregroundColor(.white.opacity(0.4))
                                            )
                                    }
                                    
                                    // Heart Shape Mask badge if widget is configured
                                    VStack {
                                        Spacer()
                                        HStack {
                                            Spacer()
                                            Image(systemName: "heart.fill")
                                                .font(.system(size: 10))
                                                .foregroundColor(.yellow)
                                                .padding(6)
                                                .background(Color.black.opacity(0.6))
                                                .clipShape(Circle())
                                                .padding(8)
                                        }
                                    }
                                }
                                .frame(width: 130, height: 130)
                                
                                // Widget Name badge
                                Text(friendsVM.selectedWidgetFriend?.displayName ?? "Tất cả bạn bè")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                            }
                        }
                        .frame(width: 200, height: 200)
                    }
                    .padding(.top, 16)
                    
                    // 2. Select Active Friend to show on widget
                    VStack(alignment: .leading, spacing: 12) {
                        Text("BẠN BÈ HIỂN THỊ TRÊN WIDGET")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                            .tracking(1)
                            .padding(.horizontal, 24)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                // "All Friends" Option
                                Button(action: {
                                    withAnimation {
                                        friendsVM.selectedWidgetFriend = nil
                                        friendsVM.updateWidgetPreferences()
                                    }
                                }) {
                                    VStack(spacing: 8) {
                                        Circle()
                                            .fill(friendsVM.selectedWidgetFriend == nil ? Color.yellow : Color.white.opacity(0.08))
                                            .frame(width: 50, height: 50)
                                            .overlay(
                                                Image(systemName: "person.2.fill")
                                                    .foregroundColor(friendsVM.selectedWidgetFriend == nil ? .black : .white)
                                            )
                                        
                                        Text("Tất Cả")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(friendsVM.selectedWidgetFriend == nil ? .white : .secondary)
                                    }
                                    .frame(width: 76, height: 86)
                                }
                                
                                // Specific Friend Options
                                ForEach(friendsVM.friends) { friend in
                                    Button(action: {
                                        withAnimation {
                                            friendsVM.selectedWidgetFriend = friend
                                            friendsVM.updateWidgetPreferences()
                                        }
                                    }) {
                                        VStack(spacing: 8) {
                                            Circle()
                                                .fill(friendsVM.selectedWidgetFriend?.id == friend.id ? Color.yellow : Color.white.opacity(0.08))
                                                .frame(width: 50, height: 50)
                                                .overlay(
                                                    Text(String(friend.username.first ?? "U").uppercased())
                                                        .foregroundColor(friendsVM.selectedWidgetFriend?.id == friend.id ? .black : .white)
                                                        .fontWeight(.bold)
                                                )
                                            
                                            Text(friend.displayName ?? friend.username)
                                                .font(.system(size: 11, weight: .semibold))
                                                .foregroundColor(friendsVM.selectedWidgetFriend?.id == friend.id ? .white : .secondary)
                                                .lineLimit(1)
                                        }
                                        .frame(width: 76, height: 86)
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                    
                    // 3. Update Frequency settings
                    VStack(alignment: .leading, spacing: 12) {
                        Text("TẦN SUẤT CẬP NHẬT DỮ LIỆU")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                            .tracking(1)
                            .padding(.horizontal, 24)
                        
                        VStack(spacing: 0) {
                            ForEach(frequencies, id: \.self) { freq in
                                Button(action: {
                                    withAnimation {
                                        friendsVM.widgetUpdateFrequency = freq
                                        friendsVM.updateWidgetPreferences()
                                    }
                                }) {
                                    HStack {
                                        Text(freq)
                                            .foregroundColor(.white)
                                            .font(.system(size: 15))
                                        Spacer()
                                        if friendsVM.widgetUpdateFrequency == freq {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.yellow)
                                                .fontWeight(.bold)
                                        }
                                    }
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 16)
                                    .background(Color.white.opacity(0.02))
                                }
                                
                                if freq != frequencies.last {
                                    Divider().background(Color.white.opacity(0.06))
                                }
                            }
                        }
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                        .padding(.horizontal, 24)
                    }
                }
                .padding(.vertical)
            }
            .background(Color.black.ignoresSafeArea())
            .preferredColorScheme(.dark)
            .navigationTitle("Thiết Lập Widget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Xong") {
                        dismiss()
                    }
                    .foregroundColor(.yellow)
                }
            }
        }
    }
}
