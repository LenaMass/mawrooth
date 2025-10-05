//
//  Untitled.swift
//  mawrooth
//
//  Created by Lyan on 13/04/1447 AH.
//
import SwiftUI
import AudioToolbox

// MARK: - Haptics + Arabic Font
enum Haptics {
    static func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    static func warning() { UINotificationFeedbackGenerator().notificationOccurred(.warning) }
    static func light()   { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
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
    static let burntBrown = Color(red: 92/255, green: 58/255, blue: 46/255)
}

// =================== ROOT ===================
struct gamePage: View {
    var body: some View {
        NavigationStack { StartScreen() }
    }
}

// =================== START SCREEN ===================
struct StartScreen: View {
    var body: some View {
        ZStack {
            if UIImage(named: "bgFirst") != nil {
                Image("bgFirst").resizable().scaledToFill().ignoresSafeArea()
            } else {
                Color(UIColor.systemBackground).ignoresSafeArea()
            }
            LinearGradient(colors: [.clear, .black.opacity(0.12)],
                           startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer(minLength: 40)

                if UIImage(named: "logoMorouth") != nil {
                    Image("logoMorouth").resizable().scaledToFit().frame(width: 180)
                } else {
                    Text("مورّوث").font(.arabicHeadline(40))
                }

                Spacer()

                NavigationLink {
                    GameScreen()
                } label: {
                    Text("ابدأ")
                        .font(.arabicHeadline(22))
                        .padding(.vertical, 14)
                        .padding(.horizontal, 48)
                        .background(Capsule().fill(Color.orange))
                        .foregroundStyle(.white)
                        .shadow(radius: 8, y: 4)
                }

                Spacer(minLength: 24)
            }
            .padding()
        }
        .navigationBarHidden(true)
    }
}

// =================== GAME SCREEN ===================
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
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            } else {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
            }
            
            VStack(spacing: 12) {
                // Top bar
                HStack(spacing: 12) {
                    Button {
                        vm.stopTimer()
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.backward").font(.title3.weight(.semibold))
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

                // GRID 3x3 (ثمانية لعب + فخ واحد)
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

                // Footer
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
        .navigationBarBackButtonHidden(true)
        .onDisappear { vm.stopTimer() }
        .alert(vm.endTitle, isPresented: $vm.showEnd) {
            Button("موافق") {
                // إعادة التشغيل عند ضغط موافق
                DispatchQueue.main.async { vm.restart() }
            }
        } message: { Text(vm.endMessage) }
    }
}

// =================== MODEL / VIEWMODEL ===================
struct GCard: Identifiable, Equatable {
    let id = UUID()
    let pairId: Int?          // nil = ليس له زوج (فخ/جوكر)
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
        // 🚫 لا إعادة تلقائية — يعيد فقط لما المستخدم يضغط "موافق"
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
            // ظهر الكرت ندوّره 180 لما يكون FaceUp عشان يختفي بالشكل الصحيح
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
                                .resizable()
                                .scaledToFit()
                                .frame(height: 42)
                        } else {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 38, weight: .bold))
                                .foregroundStyle(Color.burntBrown)
                        }
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
            // وجه الكرت يكون مستقيم لما ينفتح، ومقلوب -180 لما يكون مقفول
            .rotation3DEffect(.degrees(card.isFaceUp ? 0 : -180), axis: (x: 0, y: 1, z: 0))
            .opacity(card.isFaceUp ? 1 : 0)
        }
        // 👇 شيل دوران الحاوية العامة (هو اللي كان يقلب النص)
        // .rotation3DEffect(... )  ← احذفيه من الحاوية
        .animation(.easeInOut(duration: 0.3), value: card.isFaceUp)
    }
}

