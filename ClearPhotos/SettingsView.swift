import SwiftUI

/// Ayarlar: yoğun gün eşiği, inceleme ve silme listesi yönetimi, istatistik sıfırlama.
struct SettingsView: View {
    @EnvironmentObject private var store: ReviewStore
    @EnvironmentObject private var service: PhotoLibraryService
    @Environment(\.dismiss) private var dismiss

    @State private var confirmResetReviewed = false
    @State private var confirmClearPending = false
    @State private var confirmResetStats = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Stepper(value: $store.busyDayThreshold, in: 20...2000, step: 10) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Yoğun gün eşiği")
                            Text("\(store.busyDayThreshold) öğe ve üzeri")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Yoğun gün önerisi")
                } footer: {
                    Text("Bir günde bu sayıdan çok fotoğraf/video varsa, o gün ana ekranda önerilir. (Örneğin özel günlerde çekilen yüzlerce fotoğraf.)")
                }

                Section {
                    Toggle("Daha önce incelediklerimi atla", isOn: $store.skipReviewed)
                        .tint(Theme.accent)
                    Button(role: .destructive) {
                        confirmResetReviewed = true
                    } label: {
                        Label("İnceleme geçmişini sıfırla", systemImage: "arrow.counterclockwise")
                    }
                    .confirmationDialog("İnceleme geçmişi sıfırlansın mı?",
                                        isPresented: $confirmResetReviewed,
                                        titleVisibility: .visible) {
                        Button("Sıfırla", role: .destructive) { store.resetReviewedHistory() }
                        Button("Vazgeç", role: .cancel) {}
                    } message: {
                        Text("Sakladığın öğeler tekrar karşına çıkabilir. İstatistikler etkilenmez.")
                    }
                } header: {
                    Text("İnceleme")
                }

                Section {
                    HStack {
                        Text("Bekleyen silme")
                        Spacer()
                        Text("\(store.pendingCount) öğe · \(formattedBytes(store.pendingTotalBytes))")
                            .foregroundStyle(.secondary)
                    }
                    Button(role: .destructive) {
                        confirmClearPending = true
                    } label: {
                        Label("Silme listesini boşalt (silmeden)", systemImage: "trash.slash")
                    }
                    .disabled(store.pendingCount == 0)
                    .confirmationDialog("Silme listesi boşaltılsın mı?",
                                        isPresented: $confirmClearPending,
                                        titleVisibility: .visible) {
                        Button("Boşalt (silmeden)", role: .destructive) { store.clearPending() }
                        Button("Vazgeç", role: .cancel) {}
                    } message: {
                        Text("Öğeler SİLİNMEZ; yalnızca \"silinecek\" işareti kaldırılır.")
                    }
                } header: {
                    Text("Silme listesi")
                }

                Section {
                    HStack {
                        Text("Toplam açılan yer")
                        Spacer()
                        Text(formattedBytes(store.totalFreedBytes)).foregroundStyle(Theme.keep)
                    }
                    HStack {
                        Text("Silinen / Saklanan")
                        Spacer()
                        Text("\(store.totalDeletedCount) / \(store.totalKeptCount)").foregroundStyle(.secondary)
                    }
                    Button(role: .destructive) {
                        confirmResetStats = true
                    } label: {
                        Label("İstatistikleri sıfırla", systemImage: "chart.bar.xaxis")
                    }
                    .confirmationDialog("İstatistikler sıfırlansın mı?",
                                        isPresented: $confirmResetStats,
                                        titleVisibility: .visible) {
                        Button("Sıfırla", role: .destructive) { store.resetStats() }
                        Button("Vazgeç", role: .cancel) {}
                    }
                } header: {
                    Text("İstatistik")
                }

                Section {
                    HStack {
                        Text("Gizlilik")
                        Spacer()
                        Text("Her şey cihazda").foregroundStyle(.secondary)
                    }
                } footer: {
                    Text("ClearPhotos hiçbir veriyi internete göndermez.")
                }
            }
            .navigationTitle("Ayarlar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") { dismiss() }
                }
            }
        }
    }
}
