import SwiftUI
import AudioToolbox

// NOTE: MawroothItem and MawroothDataStore MUST be defined in a separate file (e.g., MawroothModels.swift)
// and have been REMOVED from this file to fix the "Invalid redeclaration" errors.

// MARK: - 1. Haptics + Arabic Font + Colors (Keep these utilities)
enum Haptics {
    static func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    static func warning() { UINotificationFeedbackGenerator().notificationOccurred(.warning) }
    static func light(){ UIImpactFeedbackGenerator(style: .light).impactOccurred() }
}

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

extension Color {
    // Defines the hex color initializer (required by PopUpMessageView)
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (r, g, b, a) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    static let burntBrown = Color(red: 92/255, green: 58/255, blue: 46/255)
}


// MARK: - 2. PopUp Helper Structures (Keep these)
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// MARK: - 3. PopUpMessageView (WINNER VERSION - Includes Save Button)
struct PopUpMessageView: View {
    @Environment(\.dismiss) var dismiss

    let popUpTitle: String
    let titleColor: Color
    let titleFontSize: CGFloat
    let displayMessage: String
    let messageColor: Color
    let messageFontSize: CGFloat
    
    // Action to perform on save
    let saveAction: () -> Void

    let backgroundColor = Color(hex: "8D87C0")
    let saveButtonColor = Color(hex: "F1B438")
    let textcolor = Color(hex: "EE6428")
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()

            VStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(backgroundColor)
                    .frame(width: 320, height: 450)
                    .overlay(
                        VStack(spacing: 0) {
                            
                            // A. TOP SECTION
                            ZStack(alignment: .topLeading) {
                                Image("BGmessage")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .clipped()
                                    
                                // Close Button (Dismisses the Pop-up)
                                Button {
                                    dismiss()
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(saveButtonColor)
                                        .background(Color.white.opacity(0.8))
                                        .clipShape(Circle())
                                        .padding(.top, 60)
                                        .padding(.leading, 15)
                                }
                            }
                            .frame(height: 180)
                            .cornerRadius(30, corners: [.topLeft, .topRight])
                            
                            // B. TITLE AND MESSAGE TEXT AREA
                            VStack(spacing: 15) {
                                Text(popUpTitle)
                                    .font(.system(size: titleFontSize, weight: .bold))
                                    .foregroundColor(titleColor)
                                    .padding(.top, 10)
                                    
                                Text(displayMessage)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(messageColor)
                                    .font(.system(size: messageFontSize))
                                    .padding(.horizontal, 15)
                                    .padding(.bottom, 10)
                            }
                            .frame(height: 150)
                            
                            Spacer()
                            
                            // C. SAVE BUTTON (WINNER ACTION)
                            Button(action: saveAction) {
                                Text("احفظ موروثك")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(textcolor)
                                    .frame(width: 200, height: 55)
                                    .background(saveButtonColor)
                                    .cornerRadius(55)
                            }
                            .padding(.bottom, 30)
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .shadow(radius: 20)
            }
        }
    }
}

// MARK: - 4. LossPopUpMessageView (LOSER VERSION - NO Save Button)
struct LossPopUpMessageView: View {
    @Environment(\.dismiss) var dismiss

    let popUpTitle: String
    let titleColor: Color
    let titleFontSize: CGFloat
    let displayMessage: String
    let messageColor: Color
    let messageFontSize: CGFloat
    
    // Action to perform when loss pop-up closes (e.g., restart game)
    let closeAction: () -> Void

    let backgroundColor = Color(hex: "8D87C0")
    let closeButtonColor = Color(hex: "F1B438") // Use the same color for consistency
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()

            VStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(backgroundColor)
                    .frame(width: 320, height: 450)
                    .overlay(
                        VStack(spacing: 0) {
                            
                            // A. TOP SECTION
                            ZStack(alignment: .topLeading) {
                                Image("BGmessage")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .clipped()
                                    
                                // Close Button (Performs the close action)
                                Button {
                                    closeAction() // Perform restart/close action
                                    dismiss()    // Dismiss the pop-up
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(closeButtonColor)
                                        .background(Color.white.opacity(0.8))
                                        .clipShape(Circle())
                                        .padding(.top, 60)
                                        .padding(.leading, 15)
                                }
                            }
                            .frame(height: 180)
                            .cornerRadius(30, corners: [.topLeft, .topRight])
                            
                            // B. TITLE AND MESSAGE TEXT AREA
                            VStack(spacing: 15) {
                                Text(popUpTitle)
                                    .font(.system(size: titleFontSize, weight: .bold))
                                    .foregroundColor(titleColor)
                                    .padding(.top, 10)
                                    
                                Text(displayMessage)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(messageColor)
                                    .font(.system(size: messageFontSize))
                                    .padding(.horizontal, 15)
                                    .padding(.bottom, 10)
                            }
                            .frame(height: 150)
                            
                            Spacer()
                            
                            // 🔑 NO SAVE BUTTON HERE
                            
                            Spacer() // Push content up slightly
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .shadow(radius: 20)
            }
        }
    }
}


// =================== ROOT ===================
struct gamePage: View {
    // 🔑 Inject the store since it will be used across screens
    // The MawroothDataStore definition is assumed to be in a separate file.
    @StateObject private var mawroothStore = MawroothDataStore()

    var body: some View {
        NavigationStack {
            GameScreen()
                // 🔑 Provide the store to GameScreen and all subsequent views
                .environmentObject(mawroothStore)
        }
    }
}

// =================== GAME SCREEN (Updated to use EnvironmentObject) ===================
struct GameScreen: View {
    @StateObject private var vm = GameVM()
    @Environment(\.dismiss) private var dismiss
    // 🔑 Inject the Data Store as an EnvironmentObject
    @EnvironmentObject var mawroothStore: MawroothDataStore

    var body: some View {
        ZStack {
            // Background Layer
            if let bg = UIImage(named: "BG") {
                Image(uiImage: bg)
                    .resizable()
                    .scaledToFill()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .overlay(
                        LinearGradient(
                            colors: [Color.black.opacity(0.1), Color.purple.opacity(0.1)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            } else {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
            }
            
            // Game Content
            VStack(spacing: 12) {
                // Top bar...
                HStack(spacing: 12) {
                    Button { vm.stopTimer(); dismiss() } label: { Image(systemName: "chevron.backward").font(.title3.weight(.semibold)) }
                    Spacer()
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                        Text(vm.timeString).font(.system(.subheadline, design: .rounded).monospacedDigit())
                    }
                    .padding(.vertical, 6).padding(.horizontal, 10).background(Capsule().fill(Color.purple.opacity(0.15)))

                    Button { vm.restart() } label: { Image(systemName: "arrow.counterclockwise") }
                    .disabled(vm.lockBoard)
                }
                .tint(.purple).padding(.horizontal).padding(.top, 6).overlay(
                    Text("طابق الكروت").font(.arabicHeadline(22)).offset(y: -10)
                )

                // GRID 3x3
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                    ForEach(vm.cards) { card in
                        CardView(card: card)
                            .onTapGesture { vm.tap(card) }
                            .disabled(card.isMatched || card.isFaceUp || vm.lockBoard || vm.timeRemaining == 0)
                            .aspectRatio(2/3, contentMode: .fit)
                    }
                }
                .padding(.horizontal).padding(.bottom, 6)

                // Footer
                HStack {
                    Text("مُطابَقات: \(vm.matchedPairs)/\(vm.totalPairs)")
                    Spacer()
                }
                .font(.callout)
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onDisappear { vm.stopTimer() }
        
        // WIN POP-UP (Updated to use mawroothStore.save)
        .fullScreenCover(isPresented: $vm.showWinPopUp) {
            PopUpMessageView(
                popUpTitle: "إنجاز عظيم!",
                titleColor: Color.yellow,
                titleFontSize: 24,
                displayMessage: "تم ادراج القهوه السعوديه في عام 2024 ضمن قائمة التراث الإنساني غير المادي في اليونسكو، لتصبح إحدى علامات الهوية الوطنية المميزة للمملك.",
                messageColor: .white,
                messageFontSize: 16,
                saveAction: {
                    // Calculate time spent and save
                    let timeSpent = 60 - vm.timeRemaining
                    let timeRecord = "الزمن: \(timeSpent) ثانية"
                    let messageToSave = "إنجاز رائع! تم حفظ الإنجاز في \(timeSpent) ثانية."
                    
                    // 🔑 Perform the save operation using the injected store
                    mawroothStore.save(message: messageToSave, timeTaken: timeRecord)

                    vm.showWinPopUp = false
                    vm.restart()
                }
            )
        }
        
        // LOSS POP-UP
        .fullScreenCover(isPresented: $vm.showLossPopUp) {
            LossPopUpMessageView(
                popUpTitle: "العوض بالجايات!",
                titleColor: .red,
                titleFontSize: 30,
                displayMessage: "",
                messageColor: .white,
                messageFontSize: 16,
                closeAction: {
                    // This action runs when the user taps the close button
                    vm.showLossPopUp = false
                    vm.restart()
                }
            )
        }
    }
}

// =================== MODEL / VIEWMODEL ===================
struct GCard: Identifiable, Equatable {
    let id = UUID()
    let pairId: Int?// nil = ليس له زوج (فخ/جوكر)
    let imageName: String
    var isFaceUp = false
    var isMatched = false

    var isTrap: Bool { pairId == nil }
}

final class GameVM: ObservableObject {
    @Published var cards: [GCard] = []
    @Published var timeRemaining = 60
    @Published var lockBoard = false
    @Published var showWinPopUp = false
    @Published var showLossPopUp = false
    @Published var endTitle = ""
    @Published var endMessage = ""

    private var timer: Timer?

    private let faces: [String] = [
        "char_sheikh_orange", "char_sheikh_green", "char_female_teal", "char_female_beige"
    ]
    
    private let trapPenaltySeconds = 10

    var totalPairs: Int { Set(cards.compactMap { $0.pairId }).count }
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
        showWinPopUp = false
        showLossPopUp = false
        
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

        // TRAP BEHAVIOR
        if cards[i].isTrap {
            DispatchQueue.main.async {
                self.lockBoard = true
                self.cards[i].isFaceUp = true
                Haptics.warning()
                self.timeRemaining = max(0, self.timeRemaining - self.trapPenaltySeconds)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if self.timeRemaining == 0 {
                    self.lockBoard = true
                    self.finish(won: false)
                    return
                }
                DispatchQueue.main.async {
                    if let idx = self.cards.firstIndex(where: { $0.id == card.id }) { self.cards[idx].isFaceUp = false }
                    self.lockBoard = false
                }
            }
            return
        }

        // normal matching flow...
        cards[i].isFaceUp = true
        let up = cards.indices.filter { $0 < self.cards.count && self.cards[$0].isFaceUp && !self.cards[$0].isMatched && !self.cards[$0].isTrap }


        if up.count == 2 {
            lockBoard = true
            let a = up[0], b = up[1]
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                if self.cards[a].pairId == self.cards[b].pairId {
                    self.cards[a].isMatched = true; self.cards[b].isMatched = true
                    Haptics.success()
                } else {
                    self.cards[a].isFaceUp = false; self.cards[b].isFaceUp = false
                    Haptics.light(); Haptics.warning()
                }
                self.lockBoard = false
                if self.matchedPairs == self.totalPairs { self.finish(won: true) }
            }
        }
    }

    private func finish(won: Bool) {
        stopTimer()
        lockBoard = true
        
        if won {
            // WIN: Show custom win pop-up
            self.showWinPopUp = true
            Haptics.success()
        } else {
            // LOSS: Show custom loss pop-up
            self.showLossPopUp = true
            Haptics.warning()
        }
    }
}

// =================== CARD VIEW ===================
struct CardView: View {
    let card: GCard
    
    var body: some View {
        ZStack {
            // ------- BACK (ظهر الكرت) -------
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

            // ------- FRONT (وجه الكرت) -------
            ZStack {
                if card.isTrap {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.burntBrown.opacity(0.12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.burntBrown.opacity(0.9), lineWidth: 2)
                        )
                    VStack(spacing: 8) {
                        if let trapImg = UIImage(named: card.imageName) {
                            Image(uiImage: trapImg)
                                .resizable().scaledToFit().frame(height: 42)
                        } else {
                            Image(systemName: "exclamationmark.triangle.fill").font(.system(size: 38, weight: .bold)).foregroundStyle(Color.burntBrown)
                        }
                        Text("حكمك طاح وقيمك راح").font(.arabicHeadline(16)).foregroundStyle(Color.burntBrown)
                        Text("وقعت بالفخ").font(.system(.caption, design: .rounded)).foregroundStyle(Color.burntBrown.opacity(0.9))
                    }
                    .padding(.vertical, 10)
                } else if let ui = UIImage(named: card.imageName) {
                    Image(uiImage: ui).resizable().scaledToFit().clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
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
