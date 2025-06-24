import SwiftUI

// MARK: - PPG 데이터 카드

/// PPG (광전 용적 맥파) 센서 데이터를 시각적으로 표시하는 카드 컴포넌트
/// 적외선(RED)과 근적외선(IR) LED 신호값을 함께 표시하여 심박 및 혈중 산소 농도 측정에 사용됩니다.
struct PPGDataCard: View {
    /// 표시할 PPG 센서 데이터
    let reading: PPGData
    
    var body: some View {
        VStack(spacing: 8) {
            // 헤더 영역 - 센서 타입과 하트 아이콘 표시
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                    .font(.title2)
                Text("PPG 데이터")
                    .font(.headline)
                    .foregroundColor(.red)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            
            // 센서 신호값 표시 영역 - RED와 IR 채널
            HStack(spacing: 30) {
                // 적외선 LED 신호값
                VStack {
                    Text("RED")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(reading.red)")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                
                // 근적외선 LED 신호값
                VStack {
                    Text("IR")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(reading.ir)")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.red.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview {
    PPGDataCard(reading: PPGData(red: 65432, ir: 78901, timestamp: Date()))
} 