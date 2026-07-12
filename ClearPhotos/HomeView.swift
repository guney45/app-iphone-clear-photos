import SwiftUI

/// Ana ekran: kaynak, sıralama ve filtre seçip oturumu başlatırsın.
struct HomeView: View {
    @EnvironmentObject private var service: PhotoLibraryService
    @EnvironmentObject private var store: ReviewStore

    @State private var selectedSourceID: String = "all"
    @State private var sort: SortOption = .sizeDescending
    @State private var filter: MediaKindFilter = .all
    @State private var reviewMode: ReviewMode = .cards

    @State private var isBuilding = false
    @State private var buildDone = 0
    @State private var buildTotal = 0

    @State private var deck: SwipeDeckViewModel?
    @State private var gridEntries: [AssetEntry]?
    @State private var navMode: ReviewMode = .cards
    @State private var goToReview = false
    @State private var emptyMessage: String?

    @State private var activeSheet: ActiveSheet?

    @State private var busyDays: [DaySummary] = []
    @State private var busyLoading = false

    private enum ActiveSheet: Int, Identifiable, Equatable {
        case settings, trash
        var id: Int { rawValue }
    }

    private var selectedSource: MediaSource? {
        service.sources.first { $0.id == selectedSourceID }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 26) {
                        statsHeader
                        if store.pendingCount > 0 {
                            pendingCard
                        }
                        if service.authorizationStatus == .limited {
                            limitedBanner
                        }
                        busyDaysSection
                        sourceSection
                        sortSection
                        filterSection
                        modeSection
                        skipToggle
                        Color.clear.frame(height: 90)
                    }
                    .padding(20)
                }

                VStack {
                    Spacer()
                    startButton
                }

                if isBuilding {
                    buildingOverlay
                }
            }
            .navigationTitle("ClearPhotos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        activeSheet = .settings
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .navigationDestination(isPresented: $goToReview) {
                switch navMode {
                case .cards:
                    if let deck { SwipeDeckView(vm: deck) }
                case .grid:
                    if let gridEntries { GridReviewView(entries: gridEntries) }
                }
            }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .settings: SettingsView()
                case .trash: TrashReviewView()
                }
            }
            .task { await loadBusyDays() }
            .onChange(of: store.busyDayThreshold) { _ in Task { await loadBusyDays() } }
            .onChange(of: activeSheet) { newValue in if newValue == nil { Task { await loadBusyDays() } } }
            .alert("Kart bulunamadı", isPresented: Binding(
                get: { emptyMessage != nil },
                set: { if !$0 { emptyMessage = nil } })) {
                Button("Tamam", role: .cancel) {}
            } message: {
                Text(emptyMessage ?? "")
            }
        }
    }

    // MARK: - İstatistik başlığı

    private var statsHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Şimdiye kadar açtığın yer")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(formattedBytes(store.totalFreedBytes))
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.keep)
            HStack(spacing: 16) {
                Label("\(store.totalDeletedCount) silindi", systemImage: "trash")
                Label("\(store.totalKeptCount) saklandı", systemImage: "checkmark")
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Bekleyen silme kartı

    private var pendingCard: some View {
        Button {
            activeSheet = .trash
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "trash.circle.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(Theme.delete)
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(store.pendingCount) öğe silinmeyi bekliyor")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text("\(formattedBytes(store.pendingTotalBytes)) açabilirsin · dokun ve sil")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.85))
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(.white.opacity(0.7))
            }
            .padding(16)
            .background(Theme.delete.opacity(0.18), in: RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.delete.opacity(0.4), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private var limitedBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(Theme.skip)
            Text("Sınırlı erişim açık. Tüm fotoğraflarını yönetmek için Ayarlar'dan \"Tam Erişim\" ver.")
                .font(.footnote)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.skip.opacity(0.15), in: RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Yoğun günler

    private var busyDaysSection: some View {
        Group {
            if busyLoading {
                HStack(spacing: 8) {
                    ProgressView().controlSize(.small).tint(.white)
                    Text("Yoğun günler taranıyor…").font(.caption).foregroundStyle(.secondary)
                }
            } else if !busyDays.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    sectionTitle("Yoğun günler", subtitle: "Çok fotoğraf çektiğin günler — dokunup sadece o günü incele")
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(busyDays.prefix(20)) { day in
                                busyDayCard(day)
                            }
                        }
                        .padding(.horizontal, 2)
                    }
                }
            }
        }
    }

    private func busyDayCard(_ day: DaySummary) -> some View {
        Button {
            startDaySession(day)
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                Image(systemName: "calendar")
                    .font(.headline)
                    .foregroundStyle(Theme.accent)
                Text(day.title)
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                Text("\(day.count) öğe")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
            }
            .frame(width: 130, alignment: .leading)
            .padding(14)
            .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Kaynak seçimi

    private var sourceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Kaynak", subtitle: "Hangi fotoğraflar?")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(service.sources) { source in
                        chip(title: source.title,
                             systemImage: source.systemImage,
                             isSelected: source.id == selectedSourceID) {
                            selectedSourceID = source.id
                        }
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }

    // MARK: - Sıralama

    private var sortSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Sıralama", subtitle: "İlk hangi fotoğraf gelsin?")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(SortOption.allCases) { option in
                        chip(title: option.title,
                             systemImage: option.systemImage,
                             isSelected: option == sort) {
                            sort = option
                        }
                    }
                }
                .padding(.horizontal, 2)
            }
            if sort.requiresSize {
                Text("İpucu: \"Boyut ↓\" seçiliyken en büyük dosyan ilk kartta gelir — en hızlı yer açma yolu.")
                    .font(.caption)
                    .foregroundStyle(Theme.keep)
            }
        }
    }

    // MARK: - Filtre

    private var filterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Tür", subtitle: nil)
            HStack(spacing: 10) {
                ForEach(MediaKindFilter.allCases) { kind in
                    chip(title: kind.title,
                         systemImage: kind.systemImage,
                         isSelected: kind == filter) {
                        filter = kind
                    }
                }
            }
        }
    }

    // MARK: - Görünüm (kart / ızgara)

    private var modeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Görünüm", subtitle: "Nasıl inceleyeyim?")
            HStack(spacing: 10) {
                ForEach(ReviewMode.allCases) { mode in
                    chip(title: mode.title,
                         systemImage: mode.systemImage,
                         isSelected: mode == reviewMode) {
                        reviewMode = mode
                    }
                }
            }
            if reviewMode == .grid {
                Text("Izgara: küçük fotoğrafları hızlıca göz gezdir, dokunup çoklu seç, basılı tutunca büyür. Başkalarına ait fotoğrafları elle ayıklamak için ideal.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Zaten incelenenler

    private var skipToggle: some View {
        Toggle(isOn: $store.skipReviewed) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Daha önce incelediklerimi atla")
                    .font(.subheadline)
                Text("Karar verdiğin öğeler tekrar gösterilmez")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .tint(Theme.accent)
        .padding(16)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Başlat

    private var startButton: some View {
        Button {
            Task { await startSession(source: selectedSource) }
        } label: {
            HStack {
                Image(systemName: "play.fill")
                Text("Başla")
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Theme.accent, in: RoundedRectangle(cornerRadius: 18))
            .foregroundStyle(.white)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
        .disabled(isBuilding || selectedSource == nil)
    }

    private var buildingOverlay: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
            VStack(spacing: 16) {
                ProgressView()
                    .controlSize(.large)
                    .tint(.white)
                Text(sort.requiresSize ? "Dosya boyutları okunuyor…" : "Hazırlanıyor…")
                    .font(.headline)
                if sort.requiresSize && buildTotal > 0 {
                    Text("\(buildDone) / \(buildTotal)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(28)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        }
    }

    // MARK: - Yardımcılar

    private func sectionTitle(_ title: String, subtitle: String?) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.headline)
            if let subtitle {
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    private func chip(title: String, systemImage: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                Text(title)
            }
            .font(.subheadline.weight(.medium))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                isSelected ? Theme.accent : Color.white.opacity(0.08),
                in: Capsule()
            )
            .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Oturumlar

    private func loadBusyDays() async {
        guard service.hasAccess else { return }
        busyLoading = true
        busyDays = await service.busyDays(threshold: store.busyDayThreshold)
        busyLoading = false
    }

    private func startDaySession(_ day: DaySummary) {
        let daySource = MediaSource(id: "day-\(day.id)",
                                    title: day.title,
                                    systemImage: "calendar",
                                    collection: nil,
                                    dateInterval: day.interval)
        Task { await startSession(source: daySource) }
    }

    private func startSession(source: MediaSource?) async {
        guard let source else { return }
        isBuilding = true
        buildDone = 0
        buildTotal = 0

        var entries = await service.buildEntries(source: source, filter: filter, sort: sort) { done, total in
            buildDone = done
            buildTotal = total
        }

        // Silme listesindekileri her zaman atla (zaten karar verildi, ana ekrandan erişilir).
        entries = entries.filter { !store.isPending($0.id) }
        if store.skipReviewed {
            entries = entries.filter { !store.isReviewed($0.id) }
        }

        isBuilding = false

        guard !entries.isEmpty else {
            emptyMessage = store.skipReviewed
                ? "Bu seçimde incelenmemiş öğe kalmadı. \"Daha önce incelediklerimi atla\" seçeneğini kapatıp tekrar deneyebilirsin."
                : "Bu seçimde gösterilecek öğe bulunamadı."
            return
        }

        navMode = reviewMode
        switch reviewMode {
        case .cards:
            deck = SwipeDeckViewModel(entries: entries, service: service, store: store)
        case .grid:
            gridEntries = entries
        }
        goToReview = true
    }
}
