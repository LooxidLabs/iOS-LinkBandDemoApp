import SwiftUI

// MARK: - 가속도계 데이터 카드

/// 가속도계 센서 데이터를 표시하고 측정 모드를 제어할 수 있는 카드 컴포넌트
/// 원시값 모드와 움직임 모드 간 전환 기능을 포함하며, X/Y/Z축 데이터를 표시합니다.
struct AccelerometerDataCard: View {
    /// 표시할 가속도계 센서 데이터
    let reading: AccelerometerData
    /// 가속도계 모드 제어를 위한 Bluetooth ViewModel
    @ObservedObject var bluetoothKit: BluetoothKitViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            // 헤더 섹션 - 센서 이름과 모드 제어
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "move.3d")
                        .foregroundColor(.blue)
                        .font(.title2)
                    Text("ACC")
                        .font(.headline)
                        .foregroundColor(.blue)
                    Spacer()
                }
                
                // 가속도계 모드 전환 컨트롤 (세그먼트 스타일)
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
                
                // 현재 선택된 모드에 대한 설명
                HStack {
                    Text(bluetoothKit.accelerometerMode.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                }
            }
            
            // 3축 데이터 표시 섹션
            // SDK에서 선택된 모드에 따라 처리된 데이터를 그대로 표시
            HStack(spacing: 20) {
                // X축 데이터
                VStack {
                    Text("X축")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(reading.x)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity)
                
                // Y축 데이터
                VStack {
                    Text("Y축")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(reading.y)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity)
                
                // Z축 데이터
                VStack {
                    Text("Z축")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(reading.z)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview {
    AccelerometerDataCard(
        reading: AccelerometerData(x: 1234, y: -567, z: 890, timestamp: Date()),
        bluetoothKit: BluetoothKitViewModel()
    )
} 