import SwiftUI
import UIKit
import AudioToolbox

// MARK: - Haptics
enum Haptics {
    static func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    static func warning() { UINotificationFeedbackGenerator().notificationOccurred(.warning) }
    static func light()   { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
}

// MARK: - Fonts
extension Font {
    static func arabicHeadline(_ size: CGFloat, weight: Weight = .bold) -> Font {
        let preferredArabicNames = ["SF Arabic", "Cairo", "GE SS Two", "DINNextLTArabic"]
        if let name = preferredArabicNames.first(where: { UIFont(name: $0, size: size) != nil }) {
            return .custom(name, size: size).weight(weight)
        } else {
            return .system(size: size, weight: weight, design: .rounded)
        }
    }
}

// MARK: - Colors
extension Color {
    static let burntBrown = Color(red: 92/255, green: 58/255, blue: 46/255)

    /// Initialize from hex like "#FF4500" or "FF4500"
    extension Color {
        /// Use like: Color(hexString: "8D87C0")
        init(hexString: String) {
            let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
            var int: UInt64 = 0
            Scanner(string: hex).scanHexInt64(&int)

            let a, r, g, b: UInt64
            switch hex.count {
            case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
            case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
            case 8: (r, g, b, a) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
            default: (a, r, g, b) = (255, 0, 0, 0)
            }

            self.init(.sRGB,
                      red:   Double(r) / 255,
                      green: Double(g) / 255,
                      blue:  Double(b) / 255,
                      opacity: Double(a) / 255)
        }
    }

// MARK: - Home (صفحة البداية)
struct ContentView: View {
    // سكيل الأزرار
    @State private var startButtonScale: CGFloat = 1.0
    @State private var iconButtonScale: CGFloat = 1.0

    // تنقل/عروض
    @State private var goToGame = false
    @State private var showingCardPage = false

    // ألوان حسب تصميمك
    let circleColor = Color("8D87C0")
    let iconColor   = Color("F1B438")

    private func animateButton(scale: inout CGFloat, isPressed: Bool) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            scale = isPressed ? 0.95 : 1.0
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // الخلفية
                Image("Ima")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()

                ZStack {
                    Image("Z")
                        .padding(.top, -359)
                        .padding(.leading, -68)
                    Spacer()
                }
                .ignoresSafeArea()

                VStack {
                    Image("TXT")
                        .padding(.top, 50)

                    Spacer()

                    // زر ابدأ → يفتح GameScreen
                    Button {
                        animateButton(scale: &startButtonScale, isPressed: true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            animateButton(scale: &startButtonScale, isPressed: false)
                            goToGame = true
                        }
                    } label: {
                        Text("ابدأ")
                            .font(.largeTitle.weight(.heavy))
                            .foregroundStyle(.white)
                            .frame(width: 200, height: 72)
                            .background(customOrange)
                            .cornerRadius(55)
                            .shadow(color: .black.opacity(0.4), radius: 6, x: 0, y: 4)
                    }
                    .scaleEffect(startButtonScale)

                    Spacer().frame(height: 20)

                    // زر الأيقونة → يفتح CardPage كفل سكرين
                    Button {
                        animateButton(scale: &iconButtonScale, isPressed: true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            animateButton(scale: &iconButtonScale, isPressed: false)
                            showingCardPage = true
                        }
                    } label: {
                        Image(systemName: "book.fill")
                            .font(.title)
                            .foregroundStyle(.white)
                            .frame(width: 200, height: 72)
                            .background(customPurple)
                            .cornerRadius(55)
                            .shadow(color: .black.opacity(0.4), radius: 6, x: 0, y: 4)
                    }
                    .scaleEffect(iconButtonScale)

                    Spacer()
                }
                .padding(.bottom, -200)

                // NavigationLink المخفي للتنقل للعبة
                NavigationLink("", isActive: $goToGame) { GameScreen() }
                    .opacity(0)
            }
            .fullScreenCover(isPresented: $showingCardPage) {
                CardPage()
            }
            .navigationTitle("الصفحة الرئيسية")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Game Screen
struct GameScreen: View {
    @StateObject private var vm = GameVM()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            if let bg = UIImage(named: "bgGame") {
                Image(uiImage: bg)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .overlay(
                        LinearGradient(
                            colors: [Color.black.opacity(0.1), Color.purple.opacity(0.1)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
            } else {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
            }

            VStack(spacing: 12) {
                // شريط علوي
                HStack(spacing: 12) {
                    Button {
                        vm.stopTimer()
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.backward")
                            .font(.title3.weight(.semibold))
                    }

                    Spacer()

                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                        Text(vm.timeString)
                            .font(.system(.subheadline, design: .rounded).monospacedDigit())
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(Capsule().fill(Color.purple.opacity(0.15)))

                    Button { vm.restart() } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }
                    .disabled(vm.lockBoard)
                }
                .tint(.purple)
                .padding(.horizontal)
                .padding(.top, 6)
                .overlay(
                    Text("طابق الكروت")
                        .font(.arabicHeadline(22))
                        .offset(y: -10)
                )

                // الشبكة 3x3 (8 بطاقات + فخ)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                    ForEach(vm.cards) { card in
                        CardView(card: card)
                            .onTapGesture { vm.tap(card) }
                            .disabled(card.isMatched || card.isFaceUp || vm.lockBoard || vm.timeRemaining == 0)
                            .aspectRatio(2/3, contentMode: .fit)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 6)

                // فوتر
                HStack {
                    Text("مُطابَقات: \(vm.matchedPairs)/\(vm.totalPairs)")
                    Spacer()
                    if vm.timeRemaining == 0 { Text("انتهى الوقت!").foregroundStyle(.red) }
                }
                .font(.callout)
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
        }
        .onDisappear { vm.stopTimer() }
        .alert(vm.endTitle, isPresented: $vm.showEnd) {
            Button("موافق") { DispatchQueue.main.async { vm.restart() } }
        } message: { Text(vm.endMessage) }
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Model / ViewModel
struct GCard: Identifiable, Equatable {
    let id = UUID()
    let pairId: Int?          // nil = فخ/جوكر
    let imageName: String
    var isFaceUp = false
    var isMatched = false

    var isTrap: Bool { pairId == nil }
}

final class GameVM: ObservableObject {
    @Published var cards: [GCard] = []
    @Published var timeRemaining = 60
    @Published var lockBoard = false
    @Published var showEnd = false
    @Published var endTitle = ""
    @Published var endMessage = ""

    private var timer: Timer?

    private let faces: [String] = [
        "char_sheikh_orange",
        "char_sheikh_green",
        "char_female_teal",
        "char_female_beige"
    ]

    var totalPairs: Int {
        Set(cards.compactMap { $0.pairId }).count
    }
    var matchedPairs: Int {
        let matchedByPair = Dictionary(grouping: cards.filter { $0.isMatched && !$0.isTrap }) { $0.pairId! }
        return matchedByPair.values.reduce(0) { $0 + ($1.count == 2 ? 1 : 0) }
    }
    var timeString: String {
        let m = timeRemaining / 60, s = timeRemaining % 60
        return String(format: "%d:%02d", m, s)
    }

    init() { restart() }

    func restart() {
        stopTimer()
        timeRemaining = 60
        lockBoard = false
        showEnd = false

        var deck: [GCard] = []
        for (i, name) in faces.enumerated() {
            deck.append(GCard(pairId: i, imageName: name))
            deck.append(GCard(pairId: i, imageName: name))
        }
        deck.shuffle()

        var grid = Array(deck.prefix(8))
        let trap = GCard(pairId: nil, imageName: "trap_card")
        let insertAt = Int.random(in: 0...8)
        grid.insert(trap, at: insertAt)

        cards = grid

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
                if self.matchedPairs == self.totalPairs { self.finish(won: true) }
            } else {
                self.lockBoard = true
                self.finish(won: false)
            }
        }
    }

    func stopTimer() { timer?.invalidate(); timer = nil }

    func tap(_ card: GCard) {
        guard let i = cards.firstIndex(of: card),
              !cards[i].isMatched, !cards[i].isFaceUp,
              !lockBoard, timeRemaining > 0 else { return }

        if cards[i].isTrap {
            cards[i].isFaceUp = true
            triggerTrap()
            return
        }

        cards[i].isFaceUp = true
        let up = cards.indices.filter { cards[$0].isFaceUp && !cards[$0].isMatched && !cards[$0].isTrap }

        if up.count == 2 {
            lockBoard = true
            let a = up[0], b = up[1]
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                if self.cards[a].pairId == self.cards[b].pairId {
                    self.cards[a].isMatched = true
                    self.cards[b].isMatched = true
                    Haptics.success()
                } else {
                    self.cards[a].isFaceUp = false
                    self.cards[b].isFaceUp = false
                    Haptics.light(); Haptics.warning()
                }
                self.lockBoard = false
                if self.matchedPairs == self.totalPairs { self.finish(won: true) }
            }
        }
    }

    private func triggerTrap() {
        Haptics.warning()
        lockBoard = true
        stopTimer()
        endTitle = "وقعتِ بالفخ!"
        endMessage = "خسرت يبوي😜"
        showEnd = true
    }

    private func finish(won: Bool) {
        stopTimer()
        showEnd = true
        if won {
            endTitle = "مبروك!"
            endMessage = "طابقتِ كل الكروت 🎉"
            Haptics.success()
        } else {
            endTitle = "انتهى الوقت"
            endMessage = "جربي مرة ثانية ⏰"
            Haptics.warning()
        }
    }
}

// MARK: - Card View
struct CardView: View {
    let card: GCard

    var body: some View {
        ZStack {
            // BACK
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.orange.opacity(0.6), lineWidth: 2)
                    )

                if let ui = UIImage(named: "logo_card") {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFit()
                        .padding(10)
                } else {
                    Image(systemName: "square.grid.3x3.fill").font(.title)
                }
            }
            .rotation3DEffect(.degrees(card.isFaceUp ? 180 : 0), axis: (x: 0, y: 1, z: 0))
            .opacity(card.isFaceUp ? 0 : 1)

            // FRONT
            ZStack {
                if card.isTrap {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.burntBrown.opacity(0.12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.burntBrown.opacity(0.9), lineWidth: 2)
                        )
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 38, weight: .bold))
                            .foregroundStyle(Color.burntBrown)
                        Text("حكمك طاح وقيمك راح")
                            .font(.arabicHeadline(16))
                            .foregroundStyle(Color.burntBrown)
                        Text("وقعت بالفخ")
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(Color.burntBrown.opacity(0.9))
                    }
                    .padding(.vertical, 10)
                } else if let ui = UIImage(named: card.imageName) {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                } else {
                    RoundedRectangle(cornerRadius: 14).fill(.white)
                    VStack(spacing: 6) {
                        Image(systemName: "photo").font(.title)
                        Text(card.imageName).font(.caption2)
                    }
                }
            }
            .rotation3DEffect(.degrees(card.isFaceUp ? 0 : -180), axis: (x: 0, y: 1, z: 0))
            .opacity(card.isFaceUp ? 1 : 0)
        }
        .animation(.easeInOut(duration: 0.3), value: card.isFaceUp)
    }
}

// MARK: - CardPage (صفحة المعلومات الكاملة)
struct CardPage: View {
    @Environment(\.dismiss) var dismiss

    let circleColor = Color(hex: "8D87C0")
    let iconColor   = Color(hex: "F1B438")

    private func customToolbarButton(systemName: String) -> some View {
        ZStack {
            Circle().fill(circleColor).frame(width: 40, height: 40)
            Image(systemName: systemName)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(iconColor)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Image("BG")
                    .resizable()
                    .ignoresSafeArea()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        customToolbarButton(systemName: "chevron.backward")
                    }
                }
                ToolbarItem(placement: .principal) {
                    Image("cardTitle").padding(.top, 100)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
