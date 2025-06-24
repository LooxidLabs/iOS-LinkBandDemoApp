import SwiftUI
// BluetoothKitViewModel import 추가 - 어댑터 사용
import UniformTypeIdentifiers
import QuickLook
import UIKit

// MARK: - 기록된 파일 뷰

/// 센서 데이터 기록 파일들을 표시하고 관리하는 뷰
/// 파일 목록 표시, 미리보기, 공유, Files 앱 연동 등의 기능을 제공합니다.
/// 날짜별로 파일을 그룹화하여 체계적인 파일 관리를 지원합니다.
struct RecordedFilesView: View {
    /// Bluetooth 디바이스와 파일 관리를 담당하는 ViewModel
    @ObservedObject var bluetoothKit: BluetoothKitViewModel
    /// 시트 해제를 위한 환경 변수
    @Environment(\.dismiss) private var dismiss
    /// 미리보기할 파일의 URL
    @State private var selectedFileURL: URL?
    /// 공유 시트 표시 상태
    @State private var showingShareSheet = false
    /// QuickLook 미리보기 표시 상태
    @State private var showingQuickLook = false
    /// 공유할 항목들 (파일 URL 또는 데이터)
    @State private var shareItems: [Any] = []
    
    var body: some View {
        NavigationStack {
            Group {
                if bluetoothKit.recordedFiles.isEmpty {
                    // 기록된 파일이 없을 때 표시되는 빈 상태 뷰
                    ContentUnavailableView(
                        "기록 파일 없음",
                        systemImage: "folder",
                        description: Text("센서 데이터 기록을 시작하면 여기에 파일이 표시됩니다.")
                    )
                } else {
                    List {
                        // 파일 목록을 날짜별로 그룹화하여 표시
                        Section("파일") {
                            ForEach(groupedFiles.keys.sorted().reversed(), id: \.self) { dateString in
                                Section(dateString) {
                                    ForEach(groupedFiles[dateString] ?? [], id: \.self) { url in
                                        FileRowView(
                                            url: url,
                                            onTap: { previewFile(url) },
                                            onShare: { shareFile(url) }
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("기록된 파일")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    // Files 앱에서 기록 디렉토리 열기 버튼
                    if !bluetoothKit.recordedFiles.isEmpty {
                        Button(action: openInFiles) {
                            Image(systemName: "folder.badge.gearshape")
                        }
                        .help("기록 디렉토리 정보 열기")
                    }
                    
                    // 뷰 닫기 버튼
                    Button("완료") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                refreshFiles()
            }
            .refreshable {
                refreshFiles()
            }
            .sheet(isPresented: $showingShareSheet) {
                if !shareItems.isEmpty {
                    ShareSheet(items: shareItems)
                }
            }
            .sheet(isPresented: $showingQuickLook) {
                if let url = selectedFileURL {
                    QuickLookView(url: url)
                }
            }
        }
    }
    
    /// 파일을 날짜별로 그룹화하는 계산 프로퍼티
    /// 파일명에서 날짜 정보를 추출하여 "YYYY-MM-DD" 형식으로 그룹화
    /// 파일명 형식: YYYYMMDD_HHMMSS_type.ext
    private var groupedFiles: [String: [URL]] {
        Dictionary(grouping: bluetoothKit.recordedFiles) { url in
            let fileName = url.lastPathComponent
            // 파일명에서 날짜 추출 (YYYYMMDD_HHMMSS_type.ext 형식 가정)
            if let dateStr = fileName.components(separatedBy: "_").first,
               dateStr.count == 8 {
                let year = String(dateStr.prefix(4))
                let month = String(dateStr.dropFirst(4).prefix(2))
                let day = String(dateStr.dropFirst(6).prefix(2))
                return "\(year)-\(month)-\(day)"
            }
            return "기타"
        }
    }
    
    /// 전체 파일 크기를 계산하는 계산 프로퍼티
    /// 모든 기록된 파일의 총 크기를 사람이 읽기 쉬운 형태로 반환
    private var totalFileSize: String {
        let totalBytes = bluetoothKit.recordedFiles.compactMap { url in
            try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64
        }.reduce(0, +)
        
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: totalBytes)
    }
    
    /// 파일 목록을 새로고침하는 메서드
    /// recordedFiles는 @Published 프로퍼티이므로 자동으로 업데이트되지만
    /// 필요시 BluetoothKit에서 파일 목록을 명시적으로 새로고침 요청 가능
    private func refreshFiles() {
        // 현재는 자동 업데이트되므로 별도 처리 없음
        // 향후 필요시 bluetoothKit.refreshRecordedFiles() 같은 메서드 호출 가능
    }
    
    /// 파일 미리보기를 시작하는 메서드
    /// QuickLook을 사용하여 파일 내용을 미리보기로 표시
    /// - Parameter url: 미리보기할 파일의 URL
    private func previewFile(_ url: URL) {
        selectedFileURL = url
        showingQuickLook = true
    }
    
    /// 파일 공유를 시작하는 메서드
    /// iOS 공유 시트를 사용하여 파일을 다른 앱으로 공유
    /// - Parameter url: 공유할 파일의 URL
    private func shareFile(_ url: URL) {
        shareItems = [url]
        showingShareSheet = true
    }
    
    /// Files 앱에서 기록 디렉토리를 여는 메서드
    /// 여러 방법을 시도하여 최적의 방식으로 Files 앱 연동
    /// 실패시 대체 방법들을 순차적으로 시도
    private func openInFiles() {
        // 방법 1: shareddocuments URL 스킴으로 Files 앱 열기 시도
        if let appName = Bundle.main.appDisplayName {
            let filesURL = "shareddocuments://\(appName)"
            if let url = URL(string: filesURL), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url) { success in
                    if !success {
                        // 실패시 방법 2로 대체
                        self.openFilesAppFallback()
                    }
                }
                return
            }
        }
        
        // 방법 2: Files 앱을 직접 열기
        let filesAppURL = "files://"
        if let url = URL(string: filesAppURL), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url) { success in
                if !success {
                    // 실패시 방법 3으로 대체
                    self.showFilesInstructions()
                }
            }
        } else {
            // 방법 3: 사용법 안내 표시
            showFilesInstructions()
        }
    }
    
    /// Files 앱 열기 대체 방법들을 시도하는 메서드
    /// 기본 방법이 실패했을 때 호출되는 대체 접근 방식
    private func openFilesAppFallback() {
        // 대체 URL 스킴들로 Files 앱 열기 시도
        let alternativeURLs = [
            "com.apple.DocumentsApp://",
            "files://",
        ]
        
        for urlString in alternativeURLs {
            if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                return
            }
        }
        
        // 모든 방법이 실패하면 옵션 선택 다이얼로그 표시
        showFileAccessOptions()
    }
    
    /// 파일 접근 옵션을 선택할 수 있는 액션시트를 표시하는 메서드
    /// 사용자가 파일에 접근하는 다양한 방법을 제공
    private func showFileAccessOptions() {
        let alert = UIAlertController(
            title: "파일 접근",
            message: "기록된 파일에 접근하는 방법을 선택하세요:",
            preferredStyle: .actionSheet
        )
        
        // Files 앱 열기 옵션
        alert.addAction(UIAlertAction(title: "📁 Files 앱 열기", style: .default) { _ in
            if let url = URL(string: "files://") {
                UIApplication.shared.open(url)
            } else {
                self.showFilesInstructions()
            }
        })
        
        // 앱 내에서 파일 탐색 옵션
        alert.addAction(UIAlertAction(title: "📋 앱에서 파일 탐색", style: .default) { _ in
            self.showDocumentPicker()
        })
        
        // 사용법 안내 옵션
        alert.addAction(UIAlertAction(title: "❓ 사용법 보기", style: .default) { _ in
            self.showFilesInstructions()
        })
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        // iPad에서는 팝오버 설정 필요
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            if let popover = alert.popoverPresentationController {
                popover.sourceView = rootViewController.view
                popover.sourceRect = CGRect(x: rootViewController.view.bounds.midX, y: rootViewController.view.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            rootViewController.present(alert, animated: true)
        }
    }
    
    /// 시스템 문서 선택기를 표시하는 메서드
    /// iOS 기본 파일 선택기를 사용하여 기록 디렉토리 탐색
    private func showDocumentPicker() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.folder, .data])
        documentPicker.allowsMultipleSelection = false
        documentPicker.shouldShowFileExtensions = true
        
        // 기록 디렉토리에서 시작하도록 설정
        documentPicker.directoryURL = bluetoothKit.recordingsDirectory
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(documentPicker, animated: true)
        }
    }
    
    /// 파일 접근 방법에 대한 안내를 표시하는 메서드
    /// 사용자가 수동으로 Files 앱을 통해 파일에 접근하는 방법 안내
    private func showFilesInstructions() {
        let appName = Bundle.main.appDisplayName ?? "Personal"
        
        let alert = UIAlertController(
            title: "파일 접근 방법",
            message: """
            📁 기록된 파일에 접근하는 방법:
            
            🔍 방법 1 - Files 앱 사용:
            1. "Files" 앱을 열어주세요
            2. "내 iPhone/iPad"를 탭하세요
            3. "\(appName)" 폴더를 찾으세요
            4. "Documents" 폴더를 열어주세요
            
            📤 방법 2 - 공유 기능:
            이 앱의 공유 버튼을 사용하여 파일을 다른 앱이나 클라우드 저장소로 직접 전송할 수 있습니다.
            
            💡 팁: 기록된 파일은 앱의 Documents 폴더에 안전하게 저장되며, 언제든지 이 앱을 통해 접근할 수 있습니다.
            """,
            preferredStyle: .alert
        )
        
        // Files 앱 열기 버튼
        alert.addAction(UIAlertAction(title: "Files 앱 열기", style: .default) { _ in
            if let settingsUrl = URL(string: "files://") {
                UIApplication.shared.open(settingsUrl)
            }
        })
        
        alert.addAction(UIAlertAction(title: "확인", style: .cancel))
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true)
        }
    }
}

// MARK: - Bundle Extension (Local)

/// Bundle 확장 - 앱 표시 이름을 가져오기 위한 로컬 확장
private extension Bundle {
    /// 앱의 표시 이름을 반환하는 계산 프로퍼티
    /// CFBundleDisplayName 또는 CFBundleName을 순서대로 시도
    var appDisplayName: String? {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
               object(forInfoDictionaryKey: "CFBundleName") as? String
    }
}

#Preview {
    RecordedFilesView(bluetoothKit: BluetoothKitViewModel())
} 