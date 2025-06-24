import SwiftUI

// MARK: - 제어 뷰

/// LinkBand 디바이스의 연결 관련 제어 기능을 제공하는 뷰
/// 자동 재연결 설정과 연결 해제 기능을 포함합니다.
struct ControlsView: View {
    /// Bluetooth 디바이스 관리를 담당하는 ViewModel
    @ObservedObject var bluetoothKit: BluetoothKitViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // 자동 재연결 기능 활성화/비활성화 토글
            // 연결이 끊어졌을 때 자동으로 재연결을 시도할지 설정
            HStack {
                Label("자동 재연결", systemImage: "arrow.clockwise.circle")
                    .font(.headline)
                    .foregroundColor(.blue)
                Spacer()
                Toggle("", isOn: $bluetoothKit.isAutoReconnectEnabled)
                    .labelsHidden()
                    .onChange(of: bluetoothKit.isAutoReconnectEnabled) { newValue in
                        bluetoothKit.setAutoReconnect(enabled: newValue)
                    }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
            
            // 연결 해제 버튼 - 현재 연결된 디바이스가 있을 때만 표시
            if bluetoothKit.isConnected {
                Button(action: { bluetoothKit.disconnect() }) {
                    Label("연결 해제", systemImage: "wifi.slash")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ControlsView(bluetoothKit: BluetoothKitViewModel())
} 