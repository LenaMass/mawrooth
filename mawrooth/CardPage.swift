import SwiftUI

// MARK: - Utility Functions
func cardPageUndoAction() {
    print("Undo Action Button Tapped!")
}

// NOTE: Color and Font extensions are removed as requested (assuming they exist in other files).
// NOTE: MawroothItem and MawroothDataStore are assumed to be in a separate file (e.g., MawroothModels.swift)
// and are not defined here to avoid "Invalid redeclaration" errors.

// MARK: - MawroothCardView (Color changed, stroke removed)
struct MawroothCardView: View {
    let item: MawroothItem
    
    // Assuming Color(hex: ...) and Font.arabicHeadline(...) are available via other files
    let purpleOverlayColor = Color(hex: "8D87C0")
    let iconColor = Color(hex: "F1B438")
    // 🔑 Changed message text color to the yellow-orange icon color
    let messageTextColor = Color(hex: "F1B438")
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // 1. Base Image
            Image("BGmessage")
                .resizable()
                .scaledToFill()
                .frame(width: 170, height: 170)
                .clipped()
            
            // 2. Purple Overlay on top of the image
            purpleOverlayColor.opacity(0.7)
                .frame(width: 170, height: 170)
                .cornerRadius(15)

            // Text Content
            VStack(alignment: .trailing, spacing: 5) {
                // Top Flag Icon
                HStack {
                    Image("flag_icon_green")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 20)
                        .padding(.leading, 12)
                        .padding(.top, 12)
                    Spacer()
                }

                // Message Text (Bold and F1B438 Color)
                Text(item.message)
                    // 🔑 Applied bold font and Arabic headline style
                    .font(.arabicHeadline(17, weight: .bold))
                    // 🔑 Applied the new yellow-orange color
                    .foregroundColor(messageTextColor)
                    
                    .multilineTextAlignment(.trailing)
                    .lineLimit(5)
                    .minimumScaleFactor(0.8)
                    .padding(.horizontal, 12)
                
                Spacer() // Pushes content up
                
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
    
    // Assuming Color(hex: ...) is available via other files
    let purpleColor = Color(hex: "8D87C0")
    let yellowIconColor = Color(hex: "F1B438")
    
    // Grid items for a two-column layout
    let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 15)
    ]

    private func customToolbarButton(systemName: String, color: Color, size: CGFloat = 28, weight: Font.Weight = .semibold) -> some View {
        Image(systemName: systemName)
            .font(.system(size: size, weight: weight))
            .foregroundColor(color)
    }

    var body: some View {
        NavigationStack {
            
            ZStack {
                // 1. BACKGROUND LAYER (for the entire page)
                Image("BG")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // 2. SAVED MAWROOTH GRID LIST
                ScrollView {
                    VStack(spacing: 20) {
                        // ADJUSTED SPACER HEIGHT: Pushes content further down
                        Spacer().frame(height: 150)
                        
                        if mawroothStore.savedItems.isEmpty {
                            Text("لا يوجد موروث محفوظ حتى الآن")
                                .font(.arabicHeadline(20, weight: .bold))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                                .padding(.top, 100)
                                .frame(maxWidth: .infinity)
                        } else {
                            // Display items in a LazyVGrid
                            LazyVGrid(columns: columns, spacing: 15) {
                                ForEach(mawroothStore.savedItems) { item in
                                    MawroothCardView(item: item)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .scrollIndicators(.hidden)
            }
            .toolbar {
                // Left Button (Back)
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        customToolbarButton(systemName: "chevron.backward", color: purpleColor, size: 24)
                            .offset(y: 10)
                            .padding(.leading, 0)
                    }
                }
                
                // Center Title - IMAGE
                ToolbarItem(placement: .principal) {
                    Image("cardTitle")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 40)
                        .offset(y: 35)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }
}

// MARK: - Preview Provider
#Preview {
    // Injecting sample data for the preview
    let previewStore = MawroothDataStore()
    
    previewStore.savedItems = [
        MawroothItem(message: "السعودية هي أكبر دولة في العالم من دون أنهار.", date: Date().addingTimeInterval(-86400), timeTaken: "الزمن: 24 ثانية"),
        MawroothItem(message: "تم ادراج القهوه السعوديه في عام 2024 ضمن قائمة التراث الإنساني غير المادي في اليونسكو، لتصبح إحدى علامات الهوية الوطنية المميزة للمملكة.", date: Date().addingTimeInterval(-3600), timeTaken: "الزمن: 45 ثانية"),
        MawroothItem(message: "يُستخدم زيت الورد الطائفي في صناعة عطور عالمية من قبل علامات تجارية مرموقة مثل ديور ، جيرلان، نينا ريتشي", date: Date(), timeTaken: "الزمن: 12 ثانية"),
        MawroothItem(message: "يقام مهرجان الملك عبد العزيز للإبل سنوياً على مقربة من الرياض، ويعتبر المهرجان الأكبر من نوعه على مستوى العالم.", date: Date().addingTimeInterval(-100000), timeTaken: "الزمن: 30 ثانية"),
        MawroothItem(message: "يعدّ جبل السودة الواقع في جنوب المملكة أحد أكثر الجبال إرتفاعاً في شبه الجزيرة العربية",
                     date: Date().addingTimeInterval(-200000), timeTaken: "الزمن: 55 ثانية")
    ]
    
    return Color.white
        .fullScreenCover(isPresented: .constant(true)) {
            CardPage()
                .environmentObject(previewStore)
        }
}
