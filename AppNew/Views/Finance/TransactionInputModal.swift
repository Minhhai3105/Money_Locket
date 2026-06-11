import SwiftUI

struct TransactionInputModal: View {
    let image: UIImage
    let type: TransactionType
    let onSave: (Double, String, String) -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var amountString = ""
    @State private var selectedCategory = "Dining"
    @State private var notes = ""
    
    let categories = [
        ("Dining", "fork.knife", Color.orange),
        ("Shopping", "bag.fill", Color.blue),
        ("Transport", "car.fill", Color.purple),
        ("Friends", "person.2.fill", Color.pink),
        ("Others", "ellipsis.circle.fill", Color.gray)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Preview Header
                    HStack(spacing: 16) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 84, height: 84)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(Color.white.opacity(0.15), lineWidth: 1.5)
                            )
                            .shadow(radius: 5)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(type == .income ? "GHI THU NHẬP (+)" : "GHI CHI TIÊU (-)")
                                .font(.system(.subheadline, design: .rounded))
                                .fontWeight(.black)
                                .foregroundColor(type == .income ? .green : .red)
                                .tracking(1)
                            
                            Text("Ảnh locket của bạn sẽ được gắn kèm giao dịch này.")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // Currency Input Box
                    VStack(alignment: .leading, spacing: 8) {
                        Text("SỐ TIỀN THỰC THẾ")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                            .tracking(1)
                        
                        HStack(spacing: 8) {
                            Text("₫")
                                .font(.system(size: 38, weight: .bold, design: .rounded))
                                .foregroundColor(type == .income ? .green : .red)
                            
                            TextField("0", text: $amountString)
                                .keyboardType(.numberPad)
                                .font(.system(size: 38, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .onChange(of: amountString) { newValue in
                                    let clean = newValue.filter { "0123456789".contains($0) }
                                    amountString = formatVND(clean)
                                }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    // Category Grid
                    VStack(alignment: .leading, spacing: 12) {
                        Text("CHỌN DANH MỤC")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                            .tracking(1)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(categories, id: \.0) { cat in
                                    Button(action: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedCategory = cat.0
                                        }
                                    }) {
                                        VStack(spacing: 8) {
                                            ZStack {
                                                Circle()
                                                    .fill(selectedCategory == cat.0 ? cat.2 : Color.white.opacity(0.08))
                                                    .frame(width: 46, height: 46)
                                                
                                                Image(systemName: cat.1)
                                                    .font(.system(size: 18, weight: .bold))
                                                    .foregroundColor(selectedCategory == cat.0 ? .white : .primary)
                                            }
                                            
                                            Text(cat.0)
                                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                                .foregroundColor(selectedCategory == cat.0 ? .white : .secondary)
                                        }
                                        .frame(width: 82, height: 92)
                                        .background(selectedCategory == cat.0 ? Color.white.opacity(0.08) : Color.clear)
                                        .cornerRadius(18)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 18)
                                                .stroke(selectedCategory == cat.0 ? cat.2.opacity(0.5) : Color.clear, lineWidth: 1.5)
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Note Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("GHI CHÚ GIAO DỊCH")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                            .tracking(1)
                        
                        TextField("Nhập ghi chú (ví dụ: Ăn trưa cùng bạn bè...)", text: $notes)
                            .font(.system(size: 15))
                            .padding(16)
                            .background(Color(.systemBackground))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)
                    
                    // Save Button
                    Button(action: {
                        let numericString = amountString.filter { "0123456789".contains($0) }
                        let amount = Double(numericString) ?? 0.0
                        onSave(amount, selectedCategory, notes)
                    }) {
                        HStack {
                            Text("Lưu & Đăng Locket")
                                .fontWeight(.bold)
                            Image(systemName: "checkmark.circle.fill")
                        }
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(amountString.isEmpty ? Color.gray : Color.yellow)
                        .cornerRadius(18)
                        .shadow(color: amountString.isEmpty ? Color.clear : Color.yellow.opacity(0.3), radius: 8, y: 4)
                    }
                    .disabled(amountString.isEmpty)
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
                .padding(.vertical)
            }
            .background(Color(.black).ignoresSafeArea())
            .preferredColorScheme(.dark)
            .navigationTitle("Chi Tiết Giao Dịch")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Hủy") {
                        dismiss()
                    }
                    .foregroundColor(.yellow)
                }
            }
        }
    }
    
    private func formatVND(_ cleanString: String) -> String {
        guard let doubleVal = Double(cleanString) else { return "" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        return formatter.string(from: NSNumber(value: doubleVal)) ?? ""
    }
}
