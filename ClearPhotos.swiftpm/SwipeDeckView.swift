import SwiftUI
import UIKit

/// Kart destesi: sağa/sola/yukarı kaydırarak karar verdiğin ana ekran.
struct SwipeDeckView: View {
    @ObservedObject var vm: SwipeDeckViewModel
    @EnvironmentObject private var store: ReviewStore
    @Environment(\.dismiss) private var dismiss

    @StateObject private var videoLoader = VideoLoader()

    @State private var drag: CGSize = .zero
    @State private var showTrash = false

    private let hThreshold: CGFloat = 110
    private let vThreshold: CGFloat = 130

    private enum Swipe { case keep, delete, skip }

    private var currentIsVideo: Bool { vm.current?.isVideo == true }

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            if vm.isFinished {
                finishedView
            } else {
                VStack(spacing: 0) {
                    deck
                    if currentIsVideo {
                        videoControls
                    }
                    actionButtons
                }
            }
        }
        .navigationTitle(vm.isFinished ? "Bitti" : "\(vm.reviewedCount)/\(vm.totalCount)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if store.pendingCount > 0 {
                    Button {
                        showTrash = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "trash.fill")
                            Text("\(store.pendingCount)")
                        }
                        .font(.subheadline.bold())
                        .foregroundStyle(Theme.delete)
                    }
                }
            }
        }
        .sheet(isPresented: $showTrash) {
            TrashReviewView()
        }
        .onAppear(perform: syncVideo)
        .onChange(of: vm.current?.id) { _ in syncVideo() }
        .onDisappear { videoLoader.teardown() }
    }

    private func syncVideo() {
        if let current = vm.current, current.isVideo {
            videoLoader.load(asset: current.asset)
        } else {
            videoLoader.teardown()
        }
    }

    // MARK: - Deste

    private var deck: some View {
        ZStack {
            if let next = vm.next {
                CardView(entry: next, isTop: false)
                    .id(next.id)
                    .scaleEffect(0.94)
                    .offset(y: 18)
                    .opacity(0.9)
            }

            if let current = vm.current {
                CardView(entry: current, isTop: true, player: currentIsVideo ? videoLoader.player : nil)
                    .id(current.id)
                    .offset(drag)
                    .rotationEffect(.degrees(Double(drag.width / 18)))
                    .overlay(stampOverlay)
                    .gesture(
                        DragGesture()
                            .onChanged { value in drag = value.translation }
                            .onEnded { value in handleDragEnd(value.translation) }
                    )
            }
        }
        .padding(20)
    }

    private var stampOverlay: some View {
        let keepOpacity = Double(max(0, min(1, drag.width / hThreshold)))
        let deleteOpacity = Double(max(0, min(1, -drag.width / hThreshold)))
        let skipOpacity = Double(max(0, min(1, -drag.height / vThreshold)))
        return ZStack {
            stampLabel("SAKLA", color: Theme.keep)
                .opacity(abs(drag.width) > abs(drag.height) ? keepOpacity : 0)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            stampLabel("SİL", color: Theme.delete)
                .opacity(abs(drag.width) > abs(drag.height) ? deleteOpacity : 0)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            stampLabel("ATLA", color: Theme.skip)
                .opacity(abs(drag.height) >= abs(drag.width) ? skipOpacity : 0)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .padding(30)
    }

    private func stampLabel(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 34, weight: .heavy))
            .foregroundStyle(color)
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(color, lineWidth: 4))
            .rotationEffect(.degrees(-14))
    }

    // MARK: - Video kontrolleri (kart dışında; kaydırmayla çakışmaz)

    private var videoControls: some View {
        VStack(spacing: 6) {
            Slider(
                value: Binding(
                    get: { min(videoLoader.currentTime, max(videoLoader.duration, 0.1)) },
                    set: { videoLoader.seek(to: $0) }
                ),
                in: 0...max(videoLoader.duration, 1),
                onEditingChanged: { editing in
                    videoLoader.isScrubbing = editing
                }
            )
            .tint(Theme.accent)

            HStack(spacing: 16) {
                Button {
                    videoLoader.togglePlayPause()
                } label: {
                    Image(systemName: videoLoader.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title3)
                }
                Text("\(formattedDuration(videoLoader.currentTime)) / \(formattedDuration(videoLoader.duration))")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    videoLoader.isMuted.toggle()
                } label: {
                    Image(systemName: videoLoader.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                        .font(.title3)
                }
            }
            .foregroundStyle(.white)
        }
        .padding(.horizontal, 28)
        .padding(.top, 4)
    }

    // MARK: - Butonlar

    private var actionButtons: some View {
        HStack {
            circleButton(icon: "xmark", color: Theme.delete, size: 68) { perform(.delete) }
            Spacer()
            VStack(spacing: 14) {
                smallButton(icon: "arrow.uturn.backward", color: .white.opacity(0.85), enabled: vm.canUndo) {
                    withAnimation(.spring(response: 0.3)) { vm.undo() }
                }
                smallButton(icon: "arrow.up", color: Theme.skip, enabled: true) { perform(.skip) }
            }
            Spacer()
            circleButton(icon: "checkmark", color: Theme.keep, size: 68) { perform(.keep) }
        }
        .padding(.horizontal, 36)
        .padding(.top, 8)
        .padding(.bottom, 24)
    }

    private func circleButton(icon: String, color: Color, size: CGFloat, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .bold))
                .foregroundStyle(color)
                .frame(width: size, height: size)
                .background(Circle().fill(.white.opacity(0.08)))
                .overlay(Circle().stroke(color.opacity(0.6), lineWidth: 2))
        }
    }

    private func smallButton(icon: String, color: Color, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(enabled ? color : .gray)
                .frame(width: 46, height: 46)
                .background(Circle().fill(.white.opacity(0.06)))
        }
        .disabled(!enabled)
    }

    // MARK: - Bitti

    private var finishedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 72))
                .foregroundStyle(Theme.keep)
            Text("Bu yığını bitirdin 🎉")
                .font(.title2.bold())

            if store.pendingCount > 0 {
                Text("\(store.pendingCount) öğe silinmek üzere işaretli\n\(formattedBytes(store.pendingTotalBytes)) yer açabilirsin")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)

                Button {
                    showTrash = true
                } label: {
                    Text("Silinecekleri İncele ve Sil")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Theme.delete, in: RoundedRectangle(cornerRadius: 16))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 24)
            } else {
                Text("Silmek için işaretlenen bir şey yok.")
                    .foregroundStyle(.secondary)
            }

            Button("Ana Ekrana Dön") { dismiss() }
                .padding(.top, 4)
        }
        .padding(24)
    }

    // MARK: - Kaydırma mantığı

    private func handleDragEnd(_ translation: CGSize) {
        let h = translation.width
        let v = translation.height
        if abs(h) > abs(v) {
            if h > hThreshold { perform(.keep); return }
            if h < -hThreshold { perform(.delete); return }
        } else {
            if v < -vThreshold { perform(.skip); return }
        }
        withAnimation(.spring(response: 0.3)) { drag = .zero }
    }

    private func perform(_ swipe: Swipe) {
        let target: CGSize
        switch swipe {
        case .keep:   target = CGSize(width: 800, height: 0)
        case .delete: target = CGSize(width: -800, height: 0)
        case .skip:   target = CGSize(width: 0, height: -1000)
        }
        haptic(for: swipe)
        withAnimation(.easeOut(duration: 0.26)) { drag = target }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
            switch swipe {
            case .keep:   vm.keepCurrent()
            case .delete: vm.deleteCurrent()
            case .skip:   vm.skipCurrent()
            }
            drag = .zero
        }
    }

    private func haptic(for swipe: Swipe) {
        let style: UIImpactFeedbackGenerator.FeedbackStyle
        switch swipe {
        case .keep:   style = .soft
        case .delete: style = .rigid
        case .skip:   style = .light
        }
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}
