import SwiftUI

// MARK: - 기록 제어 뷰

/// 센서 데이터 기록을 시작/중지하는 제어 뷰
/// 기록 상태에 따라 UI가 동적으로 변경되며, 연결 상태에 따라 활성화됩니다.
struct RecordingControlsView: View {
    /// Bluetooth 디바이스와 기록 기능을 관리하는 ViewModel
    @ObservedObject var bluetoothKit: BluetoothKitViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            // 헤더 영역 - 기록 상태와 아이콘 표시
            HStack {
                Image(systemName: bluetoothKit.isRecording ? "stop.circle.fill" : "record.circle")
                    .foregroundColor(bluetoothKit.isRecording ? .red : .blue)
                    .font(.title2)
                Text(bluetoothKit.isRecording ? "기록 중지" : "기록 시작")
                    .font(.headline)
                    .foregroundColor(bluetoothKit.isRecording ? .red : .blue)
                Spacer()
                // 기록 중일 때 펄스 애니메이션 인디케이터
                if bluetoothKit.isRecording {
                    Image(systemName: "circle.fill")
                        .foregroundColor(.red)
                        .symbolEffect(.pulse)
                }
            }
            .frame(maxWidth: .infinity)
            
            // 기록 시작/중지 버튼
            Button(action: {
                if bluetoothKit.isRecording {
                    bluetoothKit.stopRecording()
                } else {
                    bluetoothKit.startRecording()
                }
            }) {
                HStack {
                    Spacer()
                    Text(bluetoothKit.isRecording ? "중지" : "시작")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(bluetoothKit.isRecording ? Color.red : Color.blue)
                )
            }
            .disabled(!bluetoothKit.isConnected)
            .opacity(bluetoothKit.isConnected ? 1.0 : 0.5)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill((bluetoothKit.isRecording ? Color.red : Color.blue).opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke((bluetoothKit.isRecording ? Color.red : Color.blue).opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview {
    RecordingControlsView(bluetoothKit: BluetoothKitViewModel())
} 