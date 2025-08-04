import SwiftUI

// MARK: - 향상된 상태 카드 뷰

/// LinkBand 디바이스의 Bluetooth 연결 상태와 제어 기능을 표시하는 향상된 상태 카드
/// 연결 상태에 따라 다른 UI를 제공하며, 디바이스 스캔, 연결, 자동 재연결 등의 기능을 포함합니다.
struct EnhancedStatusCardView: View {
    /// Bluetooth 디바이스 관리를 담당하는 ViewModel
    @ObservedObject var bluetoothKit: BluetoothKitViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            connectionHeader
            
            if !bluetoothKit.isConnected {
                disconnectedContent
            } else {
                connectedContent
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(cardBackground)
    }
    
    /// 연결 상태와 기록 상태를 표시하는 헤더 섹션
    private var connectionHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    Text(bluetoothKit.connectionStatusDescription)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Image(systemName: connectionIcon)
                        .font(.system(size: 20))
                        .foregroundColor(connectionColor)
                        .symbolEffect(.bounce, value: bluetoothKit.connectionState)
                }
                
                // 연결된 경우 샘플링 레이트 정보 표시
                if bluetoothKit.isConnected {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("샘플링 레이트")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("PPG 250Hz")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("EEG 50Hz")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("ACC 25Hz")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 4)
                }
            }
            
            Spacer()
            
            recordingIndicator
        }
        .frame(maxWidth: .infinity)
    }
    
    /// 데이터 기록 중임을 표시하는 인디케이터
    @ViewBuilder
    private var recordingIndicator: some View {
        if bluetoothKit.isRecording {
            VStack {
                Image(systemName: "record.circle.fill")
                    .foregroundColor(.red)
                    .symbolEffect(.pulse)
                Text("기록")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
            }
        }
    }
    
    /// 연결되지 않은 상태에서 표시되는 콘텐츠 (스캔, 자동 재연결, 디바이스 목록)
    private var disconnectedContent: some View {
        VStack(spacing: 16) {
            scanControls
            Divider()
            autoReconnectToggle
            deviceList
        }
    }
    
    /// 디바이스 스캔 시작/중지를 위한 제어 버튼
    private var scanControls: some View {
        VStack(spacing: 12) {
            if bluetoothKit.isScanning {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                
                Button("스캔 중지") {
                    bluetoothKit.stopScan()
                }
                .buttonStyle(.bordered)
                .tint(.red)
            } else {
                Button("스캔 시작") {
                    bluetoothKit.startScan()
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    /// 자동 재연결 기능 활성화/비활성화 토글
    private var autoReconnectToggle: some View {
        HStack {
            Image(systemName: "arrow.clockwise")
                .foregroundColor(.blue)
                .font(.subheadline)
            
            Text("자동 재연결")
                .font(.subheadline)
            
            Spacer()
            
            Toggle("", isOn: $bluetoothKit.isAutoReconnectEnabled)
                .labelsHidden()
                .onChange(of: bluetoothKit.isAutoReconnectEnabled) { newValue in
                    bluetoothKit.setAutoReconnect(enabled: newValue)
                }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 4)
    }
    
    /// 스캔으로 발견된 디바이스 목록 표시
    @ViewBuilder
    private var deviceList: some View {
        if !bluetoothKit.scannedDevices.isEmpty {
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("발견된 디바이스")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                ForEach(0..<bluetoothKit.scannedDevices.count, id: \.self) { index in
                    let device = bluetoothKit.scannedDevices[index]
                    deviceRow(for: device)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    /// 개별 디바이스 항목을 표시하는 행
    /// - Parameter device: 표시할 디바이스 정보
    /// - Returns: 디바이스 이름과 연결 버튼을 포함하는 뷰
    private func deviceRow(for device: DeviceInfo) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(device.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            Button("연결") {
                bluetoothKit.connect(to: device)
            }
            .buttonStyle(.bordered)
            .tint(.blue)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(deviceRowBackground)
    }
    
    /// 디바이스 행의 배경 스타일
    private var deviceRowBackground: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.blue.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.blue.opacity(0.2), lineWidth: 1)
            )
    }
    
    /// 연결된 상태에서 표시되는 콘텐츠 (데이터 전송률 인디케이터)
    private var connectedContent: some View {
        VStack(spacing: 16) {
            Divider()
            dataRateIndicators
        }
    }
    
    /// 각 센서별 데이터 전송률을 표시하는 인디케이터들
    private var dataRateIndicators: some View {
        HStack {
            DataRateIndicator(
                title: "EEG",
                hasData: bluetoothKit.latestEEGReading != nil,
                icon: "brain.head.profile"
            )
            
            Spacer()
            
            DataRateIndicator(
                title: "PPG",
                hasData: bluetoothKit.latestPPGReading != nil,
                icon: "heart.fill"
            )
            
            Spacer()
            
            DataRateIndicator(
                title: "ACCEL",
                hasData: bluetoothKit.latestAccelerometerReading != nil,
                icon: "move.3d"
            )
            
            Spacer()
            
            DataRateIndicator(
                title: "BATT",
                hasData: bluetoothKit.latestBatteryReading != nil,
                icon: "battery.75"
            )
        }
        .frame(maxWidth: .infinity)
    }
    
    /// 상태 카드의 배경 스타일 (둥근 모서리와 그림자 효과)
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.gray.opacity(0.1))
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    /// 연결 상태에 따른 아이콘 반환
    /// - Returns: 현재 연결 상태를 나타내는 SF Symbol 이름
    private var connectionIcon: String {
        switch bluetoothKit.connectionState {
        case .disconnected:
            return "wave.3.right.circle"
        case .scanning:
            return "magnifyingglass.circle"
        case .connecting:
            return "arrow.triangle.2.circlepath.circle"
        case .connected:
            return "wave.3.right.circle.fill"
        case .reconnecting:
            return "arrow.clockwise.circle"
        case .failed:
            return "exclamationmark.triangle.fill"
        }
    }
    
    /// 연결 상태에 따른 색상 반환
    /// - Returns: 현재 연결 상태를 나타내는 SwiftUI Color
    private var connectionColor: Color {
        switch bluetoothKit.connectionState {
        case .disconnected:
            return .gray
        case .scanning:
            return .blue
        case .connecting, .reconnecting:
            return .orange
        case .connected:
            return .green
        case .failed:
            return .red
        }
    }
}

/// 개별 센서의 데이터 수신 상태를 표시하는 인디케이터 컴포넌트
/// 센서별로 아이콘, 제목, 활성 상태를 시각적으로 표현합니다.
struct DataRateIndicator: View {
    /// 센서 유형을 나타내는 제목 (예: "EEG", "PPG")
    let title: String
    /// 해당 센서로부터 데이터를 수신 중인지 여부
    let hasData: Bool
    /// 센서를 나타내는 SF Symbol 아이콘 이름
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            // 센서 아이콘 (데이터 수신 시 녹색, 미수신 시 회색)
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(hasData ? .green : .gray)
                .symbolEffect(.pulse, value: hasData)
            
            // 센서 제목
            Text(title)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            // 활성 상태 표시 원형 인디케이터
            Circle()
                .fill(hasData ? Color.green : Color.gray.opacity(0.5))
                .frame(width: 6, height: 6)
        }
    }
}

#Preview {
    EnhancedStatusCardView(bluetoothKit: BluetoothKitViewModel())
} 