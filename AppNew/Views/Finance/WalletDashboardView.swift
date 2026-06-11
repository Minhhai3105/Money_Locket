import SwiftUI
import Charts

struct WalletDashboardView: View {
    @ObservedObject var walletVM: WalletViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Overall Financial Summary
                    summaryCards
                    
                    // Breakdown Category Chart
                    chartSection
                    
                    // Recent Transactions
                    recentTransactionsSection
                }
                .padding(.top, 10)
                .padding(.bottom, 120) // spacing to avoid overlapping floating tab bar
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .navigationTitle("Ví Locket")
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Action to export or filter transactions
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.yellow)
                    }
                }
            }
        }
    }
    
    private var summaryCards: some View {
        VStack(spacing: 12) {
            // Balance Card with Gradient overlay
            VStack(alignment: .leading, spacing: 6) {
                Text("Số Dư Hiện Tại")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
                    .tracking(1)
                
                Text(walletVM.formattedBalance)
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.yellow.opacity(0.15), Color.orange.opacity(0.05)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.yellow.opacity(0.25), lineWidth: 1)
            )
            
            // Income vs Expense Row
            HStack(spacing: 12) {
                // Income
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 6, height: 6)
                        Text("THU NHẬP")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                            .tracking(0.5)
                    }
                    
                    Text(walletVM.formattedIncome)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(Color.white.opacity(0.04))
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
                
                // Expense
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 6, height: 6)
                        Text("CHI TIÊU")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                            .tracking(0.5)
                    }
                    
                    Text(walletVM.formattedExpense)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.red)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(Color.white.opacity(0.04))
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("PHÂN TÍCH CHI TIÊU")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
                .tracking(1)
            
            if walletVM.chartData.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chart.pie.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.white.opacity(0.15))
                    Text("Chưa có giao dịch chi tiêu tháng này")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 30)
            } else {
                HStack(spacing: 20) {
                    Chart(walletVM.chartData) { item in
                        SectorMark(
                            angle: .value("Amount", item.amount),
                            innerRadius: .ratio(0.68),
                            angularInset: 2.0
                        )
                        .foregroundStyle(item.color)
                        .cornerRadius(6)
                    }
                    .frame(width: 140, height: 140)
                    
                    // Custom legends
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(walletVM.chartData, id: \.self) { item in
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(item.color)
                                    .frame(width: 8, height: 8)
                                
                                Text(item.category)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Spacer()
                                
                                Text(walletVM.formatCurrency(item.amount))
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.03))
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
    
    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("LỊCH SỬ LOCKET")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
                .tracking(1)
                .padding(.horizontal, 24)
            
            if walletVM.transactions.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 28))
                        .foregroundColor(.white.opacity(0.15))
                    Text("Chưa có ảnh locket nào được gửi.")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(walletVM.transactions) { transaction in
                        HStack(spacing: 16) {
                            // Embedded camera capture thumbnail
                            if let photoUrl = transaction.photoUrl, let url = URL(string: photoUrl) {
                                AsyncImage(url: url) { image in
                                    image.resizable()
                                         .scaledToFill()
                                } placeholder: {
                                    ZStack {
                                        Color.white.opacity(0.08)
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
                                    }
                                }
                                .frame(width: 58, height: 58)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                            } else {
                                Image(systemName: "photo")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white.opacity(0.3))
                                    .frame(width: 58, height: 58)
                                    .background(Color.white.opacity(0.08))
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(transaction.notes?.isEmpty == false ? transaction.notes! : transaction.category)
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                
                                HStack(spacing: 6) {
                                    Image(systemName: "clock")
                                        .font(.system(size: 10))
                                    Text(transaction.formattedDate)
                                }
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if transaction.type != .social_only {
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text((transaction.type == .income ? "+" : "-") + walletVM.formatCurrency(transaction.amount) + " ₫")
                                        .font(.system(size: 15, weight: .black, design: .rounded))
                                        .foregroundColor(transaction.type == .income ? .green : .red)
                                    
                                    Text(transaction.category)
                                        .font(.system(size: 10, weight: .bold, design: .rounded))
                                        .foregroundColor(.white.opacity(0.4))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.white.opacity(0.08))
                                        .cornerRadius(6)
                                }
                            } else {
                                Text("Social 📷")
                                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.white.opacity(0.06))
                                    .cornerRadius(8)
                            }
                        }
                        .padding(12)
                        .background(Color.white.opacity(0.02))
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.white.opacity(0.04), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}
