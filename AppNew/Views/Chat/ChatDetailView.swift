import SwiftUI

struct ChatDetailView: View {
    @ObservedObject var chatVM: ChatViewModel
    let conversation: Conversation
    
    @State private var messageText = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Chat Header
            chatHeader
            
            // Message Feed
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(convoMessages) { message in
                            messageBubble(for: message)
                                .id(message.id)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }
                .onAppear {
                    scrollToBottom(proxy: proxy)
                }
                .onChange(of: convoMessages.count) { _ in
                    scrollToBottom(proxy: proxy)
                }
            }
            
            // Text Input Box
            inputArea
        }
        .background(Color.black.ignoresSafeArea())
        .navigationBarHidden(true)
        .preferredColorScheme(.dark)
    }
    
    private var convoMessages: [Message] {
        chatVM.conversations.first(where: { $0.id == conversation.id })?.messages ?? []
    }
    
    private var chatHeader: some View {
        HStack(spacing: 16) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.yellow)
            }
            
            // Avatar
            if let avatar = conversation.friend.avatarUrl, let url = URL(string: avatar) {
                AsyncImage(url: url) { image in
                    image.resizable()
                         .scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(conversation.friend.displayName?.first ?? conversation.friend.username.first ?? "U").uppercased())
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.yellow)
                    )
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(conversation.friend.displayName ?? conversation.friend.username)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("@\(conversation.friend.username)")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "phone.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(.horizontal)
        .padding(.top, 60)
        .padding(.bottom, 12)
        .background(Color.white.opacity(0.02))
        .overlay(
            VStack {
                Spacer()
                Divider().background(Color.white.opacity(0.06))
            }
        )
    }
    
    private func messageBubble(for msg: Message) -> some View {
        let isMe = msg.senderId == UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        
        return HStack {
            if isMe { Spacer() }
            
            VStack(alignment: isMe ? .trailing : .leading, spacing: 4) {
                if let text = msg.textContent {
                    Text(text)
                        .font(.system(size: 15))
                        .foregroundColor(isMe ? .black : .white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(isMe ? Color.yellow : Color.white.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                
                Text(msg.formattedTime)
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }
            
            if !isMe { Spacer() }
        }
    }
    
    private var inputArea: some View {
        HStack(spacing: 12) {
            Button(action: {}) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.yellow)
                    .padding(10)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Circle())
            }
            
            TextField("Nhập tin nhắn...", text: $messageText)
                .font(.system(size: 15))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.08))
                .cornerRadius(24)
                .foregroundColor(.white)
            
            if !messageText.isEmpty {
                Button(action: {
                    chatVM.sendMessage(text: messageText, to: conversation.id)
                    messageText = ""
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .padding(12)
                        .background(Color.yellow)
                        .clipShape(Circle())
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .padding(.bottom, 24)
        .background(Color.white.opacity(0.02))
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        if let last = convoMessages.last {
            withAnimation {
                proxy.scrollTo(last.id, anchor: .bottom)
            }
        }
    }
}
