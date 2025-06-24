import SwiftUI

// MARK: - 배터리 데이터 카드

/// 배터리 센서 데이터를 시각적으로 표시하는 카드 컴포넌트
/// 배터리 잔량을 백분율과 프로그레스 바로 표시하며, 잔량에 따라 색상이 변경됩니다.
struct BatteryDataCard: View {
    /// 표시할 배터리 센서 데이터
    let reading: BatteryData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 헤더 영역 - 배터리 아이콘과 잔량 표시
            HStack {
                Image(systemName: "battery.75")
                    .foregroundColor(batteryColor)
                Text("배터리 레벨")
                    .font(.headline)
                Spacer()
                // 배터리 잔량 백분율 표시
                Text("\(reading.level)%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(batteryColor)
            }
            .frame(maxWidth: .infinity)
            
            // 배터리 잔량 프로그레스 바
            ProgressView(value: Double(reading.level), total: 100.0)
                .progressViewStyle(LinearProgressViewStyle(tint: batteryColor))
                .frame(maxWidth: .infinity)
            
            // 마지막 업데이트 시간 표시
            Text("마지막 업데이트: \(timeFormatter.string(from: reading.timestamp))")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(batteryColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    /// 시간 표시를 위한 DateFormatter
    /// - Returns: 시간 스타일로 설정된 DateFormatter
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter
    }
    
    /// 배터리 잔량에 따른 색상 결정
    /// - Returns: 50% 초과 시 녹색, 20-50% 시 주황색, 20% 미만 시 빨간색
    private var batteryColor: Color {
        if reading.level > 50 {
            return .green
        } else if reading.level > 20 {
            return .orange
        } else {
            return .red
        }
    }
}

#Preview {
    BatteryDataCard(reading: BatteryData(level: 75, timestamp: Date()))
} 