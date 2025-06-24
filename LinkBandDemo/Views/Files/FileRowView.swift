import SwiftUI
import UIKit
import QuickLook

// MARK: - 파일 행 뷰

/// 개별 기록 파일을 목록에서 표시하는 행 컴포넌트
/// 파일명, 타입, 크기, 수정 날짜 등을 표시하고 미리보기 및 공유 기능을 제공합니다.
struct FileRowView: View {
    /// 표시할 파일의 URL
    let url: URL
    /// 파일을 탭했을 때 실행될 클로저 (미리보기)
    let onTap: () -> Void
    /// 공유 버튼을 탭했을 때 실행될 클로저
    let onShare: () -> Void
    /// 파일 속성 정보 (크기, 수정 날짜 등)
    @State private var fileAttributes: [FileAttributeKey: Any]?
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                // 파일 정보 영역
                VStack(alignment: .leading, spacing: 4) {
                    // 파일명 표시
                    Text(url.lastPathComponent)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    // 파일 메타 정보 (타입, 날짜, 크기)
                    HStack {
                        // 파일 타입 태그
                        Text(fileType)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(fileTypeColor.opacity(0.2))
                            .foregroundColor(fileTypeColor)
                            .cornerRadius(4)
                        
                        // 수정 날짜
                        if let modDate = modificationDate {
                            Text(FileHelper.dateFormatter.string(from: modDate))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // 파일 크기
                        Text(fileSize)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // 공유 버튼
                Button(action: onShare) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.blue)
                        .font(.title3)
                }
                .buttonStyle(.plain)
            }
        }
        .buttonStyle(.plain)
        .onAppear {
            loadFileAttributes()
        }
    }
    
    /// 파일 확장자와 이름을 기반으로 파일 타입을 결정하는 계산 프로퍼티
    private var fileType: String {
        switch url.pathExtension.lowercased() {
        case "csv":
            // CSV 파일의 경우 파일명에서 센서 타입 추출
            if url.lastPathComponent.contains("eeg") {
                return "EEG"
            } else if url.lastPathComponent.contains("ppg") {
                return "PPG"
            } else if url.lastPathComponent.contains("accel") {
                return "ACCEL"
            } else {
                return "CSV"
            }
        case "json":
            return "RAW"
        default:
            return "FILE"
        }
    }
    
    /// 파일 타입에 따른 색상을 반환하는 계산 프로퍼티
    private var fileTypeColor: Color {
        switch fileType {
        case "EEG": return .purple
        case "PPG": return .red
        case "ACCEL": return .blue
        case "RAW": return .orange
        default: return .gray
        }
    }
    
    /// 파일 크기를 사람이 읽기 쉬운 형태로 변환하는 계산 프로퍼티
    private var fileSize: String {
        guard let size = fileAttributes?[.size] as? Int64 else {
            return "알 수 없음"
        }
        
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useBytes, .useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
    
    /// 파일의 수정 날짜를 반환하는 계산 프로퍼티
    private var modificationDate: Date? {
        return fileAttributes?[.modificationDate] as? Date
    }
    
    /// 파일 속성 정보를 로드하는 메서드
    private func loadFileAttributes() {
        fileAttributes = try? FileManager.default.attributesOfItem(atPath: url.path)
    }
}

// MARK: - 헬퍼 뷰들

/// iOS 공유 시트를 SwiftUI에서 사용하기 위한 UIViewControllerRepresentable
struct ShareSheet: UIViewControllerRepresentable {
    /// 공유할 항목들
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        // 사용하지 않을 활동 타입들 제외
        controller.excludedActivityTypes = [
            .assignToContact,
            .addToReadingList,
            .postToFacebook,
            .postToTwitter,
            .postToWeibo,
            .postToVimeo,
            .postToTencentWeibo,
            .postToFlickr
        ]
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

/// QuickLook 미리보기를 SwiftUI에서 사용하기 위한 UIViewControllerRepresentable
struct QuickLookView: UIViewControllerRepresentable {
    /// 미리보기할 파일의 URL
    let url: URL
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let controller = QuickLookViewController(url: url)
        return UINavigationController(rootViewController: controller)
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}

/// QuickLook 미리보기를 관리하는 UIViewController
class QuickLookViewController: UIViewController, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    /// 미리보기할 파일의 URL
    private let url: URL
    /// QuickLook 미리보기 컨트롤러
    private var previewController: QLPreviewController!
    
    /// QuickLookViewController 초기화
    /// - Parameter url: 미리보기할 파일의 URL
    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // QuickLook 컨트롤러 설정
        previewController = QLPreviewController()
        previewController.dataSource = self
        previewController.delegate = self
        
        // 자식 뷰 컨트롤러로 추가
        addChild(previewController)
        view.addSubview(previewController.view)
        previewController.view.frame = view.bounds
        previewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        previewController.didMove(toParent: self)
        
        // 네비게이션 설정
        navigationItem.title = url.lastPathComponent
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(dismissView)
        )
    }
    
    /// 뷰를 해제하는 메서드
    @objc private func dismissView() {
        dismiss(animated: true)
    }
    
    // MARK: - QLPreviewControllerDataSource
    
    /// 미리보기할 항목의 개수를 반환
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    /// 지정된 인덱스의 미리보기 항목을 반환
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return url as QLPreviewItem
    }
}

// MARK: - 파일 헬퍼

/// 파일 관련 유틸리티 기능을 제공하는 구조체
struct FileHelper {
    /// 날짜와 시간을 표시하기 위한 DateFormatter
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}

#Preview {
    let sampleURL = URL(fileURLWithPath: "/tmp/sample_eeg_data.csv")
    FileRowView(url: sampleURL, onTap: {}, onShare: {})
} 