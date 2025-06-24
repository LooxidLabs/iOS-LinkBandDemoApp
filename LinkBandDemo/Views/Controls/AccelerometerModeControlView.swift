import SwiftUI

// MARK: - 가속도계 모드 제어 뷰

/// 가속도계 센서의 측정 모드를 전환하는 제어 뷰
/// 원시값 모드와 움직임 모드 간 전환을 세그먼트 컨트롤 스타일로 제공합니다.
struct AccelerometerModeControlView: View {
    /// Bluetooth 디바이스와 가속도계 모드 관리를 담당하는 ViewModel
    @ObservedObject var bluetoothKit: BluetoothKitViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            // 세그먼트 컨트롤 스타일의 모드 전환 버튼
            HStack(spacing: 0) {
                // 원시값 모드 버튼
                Button(action: {
                    bluetoothKit.accelerometerMode = .raw
                }) {
                    Text("원시값")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(bluetoothKit.accelerometerMode == .raw ? Color.blue : Color.clear)
                        )
                        .foregroundColor(bluetoothKit.accelerometerMode == .raw ? .white : .blue)
                }
                .disabled(bluetoothKit.isRecording)
                
                // 움직임 모드 버튼
                Button(action: {
                    bluetoothKit.accelerometerMode = .motion
                }) {
                    Text("움직임")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(bluetoothKit.accelerometerMode == .motion ? Color.blue : Color.clear)
                        )
                        .foregroundColor(bluetoothKit.accelerometerMode == .motion ? .white : .blue)
                }
                .disabled(bluetoothKit.isRecording)
            }
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.blue, lineWidth: 1)
            )
            .opacity(bluetoothKit.isRecording ? 0.5 : 1.0)
            
            // 현재 선택된 모드에 대한 설명 텍스트
            HStack {
                Text(bluetoothKit.accelerometerMode.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
            }
        }
    }
}

#Preview {
    AccelerometerModeControlView(bluetoothKit: BluetoothKitViewModel())
} 