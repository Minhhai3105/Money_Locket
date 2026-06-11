import SwiftUI

struct ChatListView: View {
    @ObservedObject var chatVM: ChatViewModel
    
    var body: some View {
        NavigationView {
            content
                .background(Color.black.ignoresSafeArea())
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarHidden(true)
                .preferredColorScheme(.dark)
        }
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            header
            if chatVM.conversations.isEmpty {
                emptyState
                    .frame(maxHeight: .infinity)
            } else {
                conversationsList
            }
        }
    }
    
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Trò Chuyện")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("Trò chuyện cùng nhóm bạn locket")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            Spacer()
            Button(action: {}) {
                Image(systemName: "plus.message.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.black)
                    .padding(10)
                    .background(Color.yellow)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 16)
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 48))
                .foregroundColor(.white.opacity(0.15))
            Text("Chưa có tin nhắn nào. Bắt đầu ngay!")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
    }
    
    private var conversationsList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(chatVM.conversations) { convo in
                    NavigationLink(destination: ChatDetailView(chatVM: chatVM, conversation: convo)) {
                        ChatRowView(convo: convo)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 120) // Tabbar buffer
        }
    }
}

private struct ChatRowView: View {
    let convo: Conversation
    
    var body: some View {
        HStack(spacing: 16) {
            avatar
            info
            Spacer()
            trailing
        }
        .padding(14)
        .background(Color.white.opacity(0.02))
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.04), lineWidth: 1)
        )
    }
    
    private var avatar: some View {
        Group {
            if let avatar = convo.friend.avatarUrl, let url = URL(string: avatar) {
                AsyncImage(url: url) { (image: Image) in
                    image.resizable()
                         .scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 54, height: 54)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white.opacity(0.1), lineWidth: 1.5))
            } else {
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 54, height: 54)
                    .overlay(
                        Text(initials)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.yellow)
                    )
            }
        }
    }
    
    private var info: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(convo.friend.displayName ?? convo.friend.username)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text(convo.lastMessage)
                .font(.system(size: 13))
                .foregroundColor(.gray)
                .lineLimit(1)
                .multilineTextAlignment(.leading)
        }
    }
    
    private var trailing: some View {
        VStack(alignment: .trailing, spacing: 6) {
            Text(convo.formattedTime)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            
            Circle()
                .fill(Color.yellow)
                .frame(width: 8, height: 8)
        }
    }
    
    private var initials: String {
        let first = convo.friend.displayName?.first ?? convo.friend.username.first ?? "U"
        return String(first).uppercased()
    }
}
