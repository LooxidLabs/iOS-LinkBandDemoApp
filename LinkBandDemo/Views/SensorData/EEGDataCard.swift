import SwiftUI

// MARK: - EEG 데이터 카드

/// EEG (뇌전도) 센서 데이터를 시각적으로 표시하는 카드 컴포넌트
/// 2채널 신호값, 전극 접촉 상태를 포함하여 표시합니다.
struct EEGDataCard: View {
    /// 표시할 EEG 센서 데이터
    let reading: EEGData
    
    var body: some View {
        VStack(spacing: 8) {
            // 헤더 영역 - 센서 타입과 접촉 상태 표시
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.purple)
                    .font(.title2)
                Text("EEG 데이터")
                    .font(.headline)
                    .foregroundColor(.purple)
                Spacer()
                // 전극 접촉 상태 인디케이터
                Image(systemName: reading.leadOff ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                    .foregroundColor(reading.leadOff ? .red : .green)
            }
            .frame(maxWidth: .infinity)
            
            // 데이터 표시 영역 - 2채널 신호값과 접촉 상태
            HStack(spacing: 20) {
                // 채널 1 신호값
                VStack {
                    Text("CH1")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(String(format: "%.1f µV", reading.channel1))
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                
                // 채널 2 신호값
                VStack {
                    Text("CH2")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(String(format: "%.1f µV", reading.channel2))
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                
                // 전극 접촉 상태 정보
                VStack {
                    Text("센서 접촉 상태")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(reading.leadOff ? "접촉 안됨" : "접촉됨")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(reading.leadOff ? .red : .green)
                }
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.purple.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview {
    EEGDataCard(reading: EEGData(channel1: 125.5, channel2: -88.2, ch1Raw: 5000, ch2Raw: -3500, leadOff: false, timestamp: Date()))
} 