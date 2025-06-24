import SwiftUI
// 모든 타입들이 같은 모듈 내에 있으므로 별도 import 불필요

// MARK: - 센서 데이터 뷰

/// LinkBand 디바이스로부터 수신되는 실시간 센서 데이터를 표시하는 메인 뷰
/// EEG, PPG, 가속도계, 배터리 센서의 최신 데이터를 각각의 전용 카드로 표시합니다.
/// 센서 데이터가 수신된 경우에만 해당 카드를 표시하는 조건부 렌더링을 사용합니다.
struct SensorDataView: View {
    /// Bluetooth 디바이스와 센서 데이터 관리를 담당하는 ViewModel
    @ObservedObject var bluetoothKit: BluetoothKitViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // EEG (뇌전도) 데이터 카드 - 가장 최근 읽기값이 있을 때만 표시
            if let eegReading = bluetoothKit.latestEEGReading {
                EEGDataCard(reading: eegReading)
                    .frame(maxWidth: .infinity)
            }
            
            // PPG (광전 용적 맥파) 데이터 카드 - 가장 최근 읽기값이 있을 때만 표시
            if let ppgReading = bluetoothKit.latestPPGReading {
                PPGDataCard(reading: ppgReading)
                    .frame(maxWidth: .infinity)
            }
            
            // 가속도계 데이터 카드 - 모드 제어 기능 포함, 가장 최근 읽기값이 있을 때만 표시
            if let accelReading = bluetoothKit.latestAccelerometerReading {
                AccelerometerDataCard(reading: accelReading, bluetoothKit: bluetoothKit)
                    .frame(maxWidth: .infinity)
            }
            
            // 배터리 데이터 카드 - 가장 최근 읽기값이 있을 때만 표시
            if let batteryReading = bluetoothKit.latestBatteryReading {
                BatteryDataCard(reading: batteryReading)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    SensorDataView(bluetoothKit: BluetoothKitViewModel())
} 