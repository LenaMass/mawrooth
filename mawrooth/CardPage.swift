import SwiftUI

// MARK: - Utility Functions
func cardPageUndoAction() {
    print("Undo Action Button Tapped!")
}

// MARK: - MawroothCardView (grid card)
struct MawroothCardView: View {
    let item: MawroothItem
    
    let purpleOverlayColor = Color(hex: "8D87C0")
    let iconColor = Color(hex: "F1B438")
    let messageTextColor = Color(hex: "F1B438")
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Base Image
            Image("BGmessage")
                .resizable()
                .scaledToFill()
                .frame(width: 170, height: 170)
                .clipped()
            
            // Purple Overlay
            purpleOverlayColor.opacity(0.7)
                .frame(width: 170, height: 170)
                .cornerRadius(15)

            // Text Content
            VStack(alignment: .trailing, spacing: 5) {
                // Flag Icon
                HStack {
                    Image("FlagG")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .padding(.leading, 12)
                        .padding(.top, 12)
                    Spacer()
                }

                // Message Text (short, clipped for grid)
                Text(item.message)
                    .font(.arabicHeadline(17, weight: .bold))
                    .foregroundColor(messageTextColor)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(5)
                    .minimumScaleFactor(0.8)
                    .padding(.horizontal, 12)
                
                Spacer()
            }
            .frame(width: 170, height: 170)
        }
        .frame(width: 170, height: 170)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)
    }
}

// MARK: - CardPage View
struct CardPage: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var mawroothStore: MawroothDataStore
    
    let purpleColor = Color(hex: "8D87C0")
    let yellowIconColor = Color(hex: "F1B438")
    
    let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 15)
    ]
    
    // 🔹 Currently selected card for popup
    @State private var selectedItem: MawroothItem? = nil

    private func headerBackIcon(
        systemName: String = "chevron.backward",
        color: Color,
        size: CGFloat = 30,
        weight: Font.Weight = .semibold
    ) -> some View {
        Image(systemName: systemName)
            .font(.system(size: size, weight: weight))
            .foregroundColor(color)
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ZStack(alignment: .top) {
                    // Background full-screen
                    Image("BG")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .ignoresSafeArea()
                    
                    // Main vertical layout (header + content)
                    VStack(spacing: 0) {
                        // 🔝 Custom header, positioned using safe area insets
                        HStack(spacing: 0) {
                            headerBackIcon(color: purpleColor)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    dismiss()
                                }
                            
                            Spacer()
                            
                            Image("cardTitle")
                                .resizable()
                                .scaledToFit()
                                .padding(.horizontal, 100)
                            
                            // Balance the width of the back arrow
                            Spacer()
                                .frame(width: 35)
                        }
                        .padding(.top, geo.safeAreaInsets.top) // below notch/status bar
                        .padding(.horizontal, 20)
                    
                        // 🔽 Scroll content starts *below* header
                        ScrollView {
                            VStack(spacing: 10) {
                                Spacer().frame(height: 30) // space between header & first row
                                
                                if mawroothStore.savedItems.isEmpty {
                                    Text("لا يوجد موروث محفوظ حتى الآن")
                                        .font(.arabicHeadline(20, weight: .bold))
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.gray)
                                        .padding(.top, 150)
                                        .frame(maxWidth: .infinity)
                                } else {
                                    LazyVGrid(columns: columns, spacing: 15) {
                                        ForEach(mawroothStore.savedItems) { item in
                                            // 🔹 Tap card to show full popup
                                            MawroothCardView(item: item)
                                                .onTapGesture {
                                                    withAnimation(.spring(response: 0.35,
                                                                          dampingFraction: 0.8)) {
                                                        selectedItem = item
                                                    }
                                                }
                                        }
                                    }
                                    .padding(.horizontal, 25)
                                }
                            }
                            .padding(.bottom, 40)
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .scrollIndicators(.hidden)
                    }
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
                    
                    // 🔸 POPUP OVERLAY FOR FULL CARD
                    if let selected = selectedItem {
                        ZStack {
                            // Dimmed background
                            Color.black.opacity(0.45)
                                .ignoresSafeArea()
                            
                            // Full card popup
                            VStack(alignment: .trailing, spacing: 16) {
                                // Optional flag / icon row
                                HStack {
                                    Spacer()
                                    Image("FlagG")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 26)
                                }
                                
                                // Full message text (no lineLimit)
                                Text(selected.message)
                                    .font(.arabicHeadline(20, weight: .bold))
                                    .foregroundColor(Color(hex: "F1B438"))
                                    .multilineTextAlignment(.trailing)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                // (Optional) time/date info if you ever want it:
                                // Text(selected.timeTaken)
                                //     .font(.system(size: 14, weight: .regular))
                                //     .foregroundColor(.white.opacity(0.8))
                                //     .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(20)
                            .background(
                                ZStack {
                                    Image("BGmessage")
                                        .resizable()
                                        .scaledToFill()
                                        .clipped()
                                    Color(hex: "8D87C0").opacity(0.75)
                                }
                            )
                            .cornerRadius(20)
                            .shadow(color: .black.opacity(0.4), radius: 18, x: 0, y: 10)
                            .padding(.horizontal, 30)
                            .frame(maxWidth: 500) // nicer on iPad as well
                            .transition(.scale.combined(with: .opacity))
                        }
                        // Tap ANYWHERE to dismiss
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                                selectedItem = nil
                            }
                        }
                        .zIndex(1) // Make sure it's above everything else
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

// MARK: - Preview
#Preview {
    let previewStore = MawroothDataStore()
    
    previewStore.savedItems = [
        MawroothItem(message: "السعودية هي أكبر دولة في العالم من دون أنهار.", date: Date().addingTimeInterval(-86400), timeTaken: "الزمن: 24 ثانية"),
        MawroothItem(message: "تم ادراج القهوه السعوديه في عام 2024 ضمن قائمة التراث الإنساني غير المادي في اليونسكو، لتصبح إحدى علامات الهوية الوطنية المميزة للمملكة.", date: Date().addingTimeInterval(-3600), timeTaken: "الزمن: 45 ثانية"),
        MawroothItem(message: "يُستخدم زيت الورد الطائفي في صناعة عطور عالمية من قبل علامات تجارية مرموقة مثل ديور ، جيرلان، نينا ريتشي", date: Date(), timeTaken: "الزمن: 12 ثانية"),
        MawroothItem(message: "يقام مهرجان الملك عبد العزيز للإبل سنوياً على مقربة من الرياض، ويعتبر المهرجان الأكبر من نوعه على مستوى العالم.", date: Date().addingTimeInterval(-100000), timeTaken: "الزمن: 30 ثانية"),
        MawroothItem(message: "يعدّ جبل السودة الواقع في جنوب المملكة أحد أكثر الجبال إرتفاعاً في شبه الجزيرة العربية",
                     date: Date().addingTimeInterval(-200000), timeTaken: "الزمن: 55 ثانية")
    ]
    
    return NavigationStack {
        CardPage()
            .environmentObject(previewStore)
    }
}

