import SwiftUI
// BluetoothKitViewModel import 추가 - 어댑터 사용

// MARK: - 배치 데이터 통계 뷰

/// 센서 데이터의 실시간 통계를 표시하는 뷰
/// 연결된 각 센서의 현재 값과 연결/기록 상태를 카드 형태로 표시합니다.
struct BatchDataStatsView: View {
    /// Bluetooth 디바이스와 센서 데이터 관리를 담당하는 ViewModel
    @ObservedObject var bluetoothKit: BluetoothKitViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // 헤더 영역 - 제목과 기록 상태 표시
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.orange)
                
                Text("센서 데이터 통계")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                // 기록 중일 때 표시되는 인디케이터
                if bluetoothKit.isRecording {
                    Image(systemName: "record.circle.fill")
                        .foregroundColor(.red)
                        .scaleEffect(1.1) // pulse 대신 약간 큰 크기로 표시
                }
            }
            
            Divider()
            
            // 연결 상태에 따른 콘텐츠 분기
            if !bluetoothKit.isConnected {
                emptyStateView
            } else {
                // 센서별 통계 카드 목록 (데이터가 있는 센서만 표시)
                LazyVStack(spacing: 12) {
                    if bluetoothKit.latestEEGReading != nil {
                        sensorStatCard(for: "EEG", icon: "brain.head.profile", color: .purple)
                    }
                    
                    if bluetoothKit.latestPPGReading != nil {
                        sensorStatCard(for: "PPG", icon: "heart.fill", color: .red)
                    }
                    
                    if bluetoothKit.latestAccelerometerReading != nil {
                        sensorStatCard(for: "ACC", icon: "move.3d", color: .blue)
                    }
                    
                    if bluetoothKit.latestBatteryReading != nil {
                        sensorStatCard(for: "배터리", icon: "battery.75", color: .green)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    /// 연결되지 않았거나 센서 데이터가 없을 때 표시되는 빈 상태 뷰
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text("센서 데이터 없음")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text("디바이스에 연결하고 데이터 수신을 시작하면 통계가 여기에 표시됩니다.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
    
    /// 개별 센서의 통계 정보를 표시하는 카드
    /// - Parameters:
    ///   - sensorType: 센서 타입 문자열 (예: "EEG", "PPG")
    ///   - icon: 센서를 나타내는 SF Symbol 이름
    ///   - color: 센서별 테마 색상
    /// - Returns: 센서 데이터와 상태 정보를 표시하는 카드 뷰
    private func sensorStatCard(for sensorType: String, icon: String, color: Color) -> some View {
        VStack(spacing: 12) {
            // 센서 타입 헤더 - 아이콘과 이름, 데이터 타입 표시
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
                
                Text(sensorType)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("실시간 데이터")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // 현재 센서 값들을 그리드 형태로 표시
            sensorDataView(for: sensorType, color: color)
            
            // 연결 및 기록 상태 정보
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("연결 상태")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(bluetoothKit.connectionStatusDescription)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("기록 상태")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(bluetoothKit.isRecording ? "기록 중" : "대기")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(bluetoothKit.isRecording ? .red : .gray)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
    
    /// 센서 타입에 따라 해당하는 센서 데이터를 그리드 형태로 표시
    /// - Parameters:
    ///   - sensorType: 표시할 센서 타입
    ///   - color: 센서별 테마 색상
    /// - Returns: 센서 데이터를 그리드로 표시하는 뷰
    @ViewBuilder
    private func sensorDataView(for sensorType: String, color: Color) -> some View {
        switch sensorType {
        case "EEG":
            // EEG 2채널 데이터 표시
            if let eeg = bluetoothKit.latestEEGReading {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                    StatItem(title: "CH1", value: String(format: "%.1f µV", eeg.channel1), color: color)
                    StatItem(title: "CH2", value: String(format: "%.1f µV", eeg.channel2), color: color)
                }
            }
            
        case "PPG":
            // PPG RED/IR 채널 데이터 표시
            if let ppg = bluetoothKit.latestPPGReading {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                    StatItem(title: "Red", value: "\(ppg.red)", color: color)
                    StatItem(title: "IR", value: "\(ppg.ir)", color: color)
                }
            }
            
        case "ACC":
            // 가속도계 X/Y/Z축 데이터 표시
            if let accel = bluetoothKit.latestAccelerometerReading {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                    StatItem(title: "X", value: "\(accel.x)", color: color)
                    StatItem(title: "Y", value: "\(accel.y)", color: color)
                    StatItem(title: "Z", value: "\(accel.z)", color: color)
                }
            }
            
        case "배터리":
            // 배터리 잔량 데이터 표시
            if let battery = bluetoothKit.latestBatteryReading {
                StatItem(title: "배터리", value: "\(battery.level)%", color: color)
            }
            
        default:
            EmptyView()
        }
    }
}

// MARK: - 통계 항목 컴포넌트

/// 개별 센서 값을 표시하는 작은 통계 항목 컴포넌트
/// 제목과 값을 세로로 배치하고 센서별 테마 색상을 적용합니다.
struct StatItem: View {
    /// 통계 항목의 제목 (예: "CH1", "X축")
    let title: String
    /// 표시할 센서 값
    let value: String
    /// 테마 색상
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            // 항목 제목
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            // 센서 값
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .padding(.horizontal, 6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(color.opacity(0.3), lineWidth: 0.5)
                )
        )
    }
}

// MARK: - 미리보기

#Preview {
    BatchDataStatsView(bluetoothKit: BluetoothKitViewModel())
        .padding()
} 