import SwiftUI

// MARK: - 간소화된 배치 데이터 수집 뷰

/// LinkBand 디바이스로부터 배치 데이터를 수집하고 설정하는 간소화된 사용자 인터페이스
/// BatchDataConfigurationViewModel을 사용하여 깔끔한 아키텍처를 제공하며,
/// 샘플 수 기반 또는 시간 기반의 데이터 수집 모드를 지원합니다.
struct SimplifiedBatchDataCollectionView: View {
    /// Bluetooth 디바이스 관리를 담당하는 메인 ViewModel
    @ObservedObject var bluetoothKit: BluetoothKitViewModel
    /// 배치 데이터 수집 설정과 로직을 관리하는 전용 ViewModel
    @StateObject private var viewModel: BatchDataConfigurationViewModel
    /// 텍스트 필드의 포커스 상태를 추적하는 상태 변수
    @FocusState private var isTextFieldFocused: Bool
    /// 모니터링 중지 확인 알림 표시 상태
    @State private var showStopMonitoringAlert = false
    
    // MARK: - 포커스 상태 관리
    // 개별 텍스트 필드 포커스 상태 추적을 위한 변수들
    // 각 센서별로 독립적인 포커스 상태를 관리하여 정확한 검증 타이밍을 제공
    @FocusState private var focusedSampleCountField: SensorKind?
    @FocusState private var focusedSecondsField: SensorKind?
    @FocusState private var focusedMinutesField: SensorKind?
    
    /// 주로 사용하는 센서 타입들 (배터리 제외)
    /// 배터리 센서는 별도 관리되므로 이 목록에서 제외
    private let mainSensors: [SensorKind] = [.eeg, .ppg, .accelerometer]
    
    /// SimplifiedBatchDataCollectionView 초기화
    /// - Parameter bluetoothKit: Bluetooth 디바이스 관리 ViewModel
    init(bluetoothKit: BluetoothKitViewModel) {
        self.bluetoothKit = bluetoothKit
        // 어댑터 패턴을 사용하여 BluetoothKit으로부터 배치 데이터 ViewModel 생성
        self._viewModel = StateObject(wrappedValue: bluetoothKit.createBatchDataConfigurationViewModel())
    }
    
    var body: some View {
        content
            .padding()
            .background(backgroundStyle)
            .onTapGesture { handleBackgroundTap() }
            .onChange(of: isTextFieldFocused) { handleFocusChange($0) }
            .onChange(of: focusedSampleCountField) { handleSampleCountFocusChange($0) }
            .onChange(of: focusedSecondsField) { handleSecondsFieldFocusChange($0) }
            .onChange(of: focusedMinutesField) { handleMinutesFieldFocusChange($0) }
            .onAppear { ensureAllFieldsHaveValues() }
            .alert("모니터링 중지 확인", isPresented: $showStopMonitoringAlert) {
                alertButtons
            } message: {
                alertMessage
            }
            .onChange(of: bluetoothKit.accelerometerMode) { handleAccelerometerModeChange($0) }
    }
    
    // MARK: - Main Content
    
    private var content: some View {
        VStack(spacing: 16) {
            headerView
            collectionModeSection
            configurationContentView
            sensorSelectionSection
            controlButtonsSection
        }
    }
    
    private var configurationContentView: some View {
        Group {
            if viewModel.selectedCollectionMode == .sampleCount {
                sampleCountConfiguration
            } else {
                durationConfiguration
            }
        }
    }
    
    private var backgroundStyle: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.gray.opacity(0.1))
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    private var alertButtons: some View {
        Group {
            Button("기록 및 모니터링 중지", role: .destructive) {
                if bluetoothKit.isRecording {
                    bluetoothKit.stopRecording()
                }
                viewModel.stopSelectedSensors()
            }
            Button("취소", role: .cancel) { }
        }
    }
    
    private var alertMessage: some View {
        Text("데이터 기록이 진행 중입니다.\n모니터링을 중지하면 기록도 함께 중지됩니다.")
    }
    
    // MARK: - Event Handlers
    
    private func handleBackgroundTap() {
        isTextFieldFocused = false
        focusedSampleCountField = nil
        focusedSecondsField = nil
        focusedMinutesField = nil
    }
    
    private func handleFocusChange(_ isFocused: Bool) {
        if !isFocused {
            restoreEmptyFieldsToDefaults()
        }
    }
    
    private func handleSampleCountFocusChange(_ focusedSensor: SensorKind?) {
        if focusedSensor == nil {
            for sensor in mainSensors {
                let currentValue = viewModel.getSampleCountText(for: sensor)
                validateAndFixSampleCount(currentValue, for: sensor)
            }
        }
    }
    
    private func handleSecondsFieldFocusChange(_ focusedSensor: SensorKind?) {
        if focusedSensor == nil {
            for sensor in mainSensors {
                let currentValue = viewModel.getSecondsText(for: sensor)
                validateAndFixSeconds(currentValue, for: sensor)
            }
        }
    }
    
    private func handleMinutesFieldFocusChange(_ focusedSensor: SensorKind?) {
        if focusedSensor == nil {
            for sensor in mainSensors {
                let currentValue = viewModel.getMinutesText(for: sensor)
                validateAndFixMinutes(currentValue, for: sensor)
            }
        }
    }
    
    private func handleAccelerometerModeChange(_ newMode: AccelMode) {
        viewModel.updateAccelerometerMode(newMode)
    }
    
    // MARK: - View Components
    
    /// 헤더 영역 - 제목과 현재 기록 상태를 표시
    private var headerView: some View {
        HStack {
            Image(systemName: "square.stack.3d.down.right.fill")
                .font(.system(size: 20))
                .foregroundColor(.blue)
            
            Text("데이터 수집 설정")
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
    }
    
    /// 수집 모드 선택 섹션 (샘플 수, 초, 분 기반)
    private var collectionModeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("수집 모드")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Picker("수집 모드", selection: $viewModel.selectedCollectionMode) {
                ForEach(CollectionModeKind.allCases, id: \.self) { mode in
                    Text(mode.displayName).tag(mode)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .disabled(viewModel.isMonitoringActive)
            .onChange(of: viewModel.selectedCollectionMode) { newMode in
                // 모드가 변경되면 ViewModel에 전달
                viewModel.setCollectionMode(newMode)
            }
        }
    }
    
    /// 설정 섹션 래퍼 (선택된 모드에 따라 다른 UI 표시)
    private var configurationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if viewModel.selectedCollectionMode == .sampleCount {
                sampleCountConfiguration
            } else {
                durationConfiguration
            }
        }
    }
    
    /// 샘플 수 기반 설정 섹션
    private var sampleCountConfiguration: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("센서별 목표 샘플 수")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                // 현재 상태 표시 (모니터링 중 또는 기록 중)
                if viewModel.isMonitoringActive || bluetoothKit.isRecording {
                    HStack(spacing: 4) {
                        Image(systemName: bluetoothKit.isRecording ? "record.circle.fill" : "eye.fill")
                            .foregroundColor(bluetoothKit.isRecording ? .red : .orange)
                            .font(.caption)
                        Text(bluetoothKit.isRecording ? "기록 중" : "모니터링 중")
                            .font(.caption)
                            .foregroundColor(bluetoothKit.isRecording ? .red : .orange)
                            .fontWeight(.medium)
                    }
                }
            }
            
            // 각 센서별 샘플 수 설정 행
            ForEach(mainSensors, id: \.self) { sensor in
                sensorSampleCountRow(for: sensor)
            }
        }
    }
    
    /// 시간 기반 설정 섹션
    private var durationConfiguration: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(viewModel.selectedCollectionMode == .seconds ? "센서별 수집 시간 (초)" : "센서별 수집 시간 (분)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                if viewModel.isMonitoringActive || bluetoothKit.isRecording {
                    HStack(spacing: 4) {
                        Image(systemName: bluetoothKit.isRecording ? "record.circle.fill" : "eye.fill")
                            .foregroundColor(bluetoothKit.isRecording ? .red : .orange)
                            .font(.caption)
                        Text(bluetoothKit.isRecording ? "기록 중" : "모니터링 중")
                            .font(.caption)
                            .foregroundColor(bluetoothKit.isRecording ? .red : .orange)
                            .fontWeight(.medium)
                    }
                }
            }
            
            ForEach(mainSensors, id: \.self) { sensor in
                if viewModel.selectedCollectionMode == .seconds {
                    sensorSecondsRow(for: sensor)
                } else {
                    sensorMinutesRow(for: sensor)
                }
            }
        }
    }
    
    /// 특정 센서의 샘플 수 입력 행을 생성하는 메서드
    /// - Parameter sensor: 샘플 수를 설정할 센서 타입
    /// - Returns: 센서별 샘플 수 입력 UI 컴포넌트
    private func sensorSampleCountRow(for sensor: SensorKind) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(sensor.emoji) \(sensor.displayName)")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(colorForSensor(sensor))
            
            HStack {
                TextField("예: \(defaultSampleCount(for: sensor))", text: sampleCountBinding(for: sensor))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .focused($focusedSampleCountField, equals: sensor)
                    .disabled(viewModel.isMonitoringActive || bluetoothKit.isRecording)
                    .opacity(viewModel.isMonitoringActive || bluetoothKit.isRecording ? 0.6 : 1.0)
                    .onTapGesture {
                        if viewModel.isMonitoringActive || bluetoothKit.isRecording {
                            // 텍스트 필드 비활성화 상태에서는 포커스 해제만
                            focusedSampleCountField = nil
                        }
                    }
                    .onChange(of: sampleCountBinding(for: sensor).wrappedValue) { newValue in
                        validateAndFixSampleCount(newValue, for: sensor)
                    }
                    .onSubmit {
                        // 엔터 키를 눌렀을 때도 검증
                        let currentValue = viewModel.getSampleCountText(for: sensor)
                        validateAndFixSampleCount(currentValue, for: sensor)
                        focusedSampleCountField = nil
                    }
                
                Text("샘플")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    /// 특정 센서의 시간(초) 입력 행을 생성하는 메서드
    /// - Parameter sensor: 수집 시간을 설정할 센서 타입
    /// - Returns: 센서별 시간(초) 입력 UI 컴포넌트
    private func sensorSecondsRow(for sensor: SensorKind) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(sensor.emoji) \(sensor.displayName)")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(colorForSensor(sensor))
            
            HStack {
                TextField("예: 1", text: durationBinding(for: sensor))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .focused($focusedSecondsField, equals: sensor)
                    .disabled(viewModel.isMonitoringActive || bluetoothKit.isRecording)
                    .opacity(viewModel.isMonitoringActive || bluetoothKit.isRecording ? 0.6 : 1.0)
                    .onTapGesture {
                        if viewModel.isMonitoringActive || bluetoothKit.isRecording {
                            // 텍스트 필드 비활성화 상태에서는 포커스 해제만
                            focusedSecondsField = nil
                        }
                    }
                    .onChange(of: durationBinding(for: sensor).wrappedValue) { newValue in
                        validateAndFixSeconds(newValue, for: sensor)
                    }
                    .onSubmit {
                        // 엔터 키를 눌렀을 때도 검증
                        let currentValue = viewModel.getSecondsText(for: sensor)
                        validateAndFixSeconds(currentValue, for: sensor)
                        focusedSecondsField = nil
                    }
                
                Text("초")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    /// 특정 센서의 시간(분) 입력 행을 생성하는 메서드
    /// - Parameter sensor: 수집 시간을 설정할 센서 타입
    /// - Returns: 센서별 시간(분) 입력 UI 컴포넌트
    private func sensorMinutesRow(for sensor: SensorKind) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(sensor.emoji) \(sensor.displayName)")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(colorForSensor(sensor))
            
            HStack {
                TextField("예: 1", text: minutesBinding(for: sensor))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .focused($focusedMinutesField, equals: sensor)
                    .disabled(viewModel.isMonitoringActive || bluetoothKit.isRecording)
                    .opacity(viewModel.isMonitoringActive || bluetoothKit.isRecording ? 0.6 : 1.0)
                    .onTapGesture {
                        if viewModel.isMonitoringActive || bluetoothKit.isRecording {
                            // 텍스트 필드 비활성화 상태에서는 포커스 해제만
                            focusedMinutesField = nil
                        }
                    }
                    .onChange(of: minutesBinding(for: sensor).wrappedValue) { newValue in
                        validateAndFixMinutes(newValue, for: sensor)
                    }
                    .onSubmit {
                        // 엔터 키를 눌렀을 때도 검증
                        let currentValue = viewModel.getMinutesText(for: sensor)
                        validateAndFixMinutes(currentValue, for: sensor)
                        focusedMinutesField = nil
                    }
                
                Text("분")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var sensorSelectionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("센서 선택")
                .font(.headline)
            
            HStack(spacing: 8) {
                ForEach(mainSensors, id: \.self) { sensor in
                    SensorToggleButton(
                        sensor: sensor,
                        isSelected: viewModel.selectedSensors.contains(sensor),
                        isDisabled: viewModel.isMonitoringActive
                    ) {
                        toggleSensorSelection(sensor)
                    }
                }
            }
        }
    }
    
    private var controlButtonsSection: some View {
        VStack(spacing: 12) {
            // 센서 활성화 컨트롤
            HStack(spacing: 12) {
                if viewModel.isMonitoringActive {
                    Button("센서 비활성화") {
                        // 기록 중이면 경고 팝업 표시, 아니면 바로 중지
                        if bluetoothKit.isRecording {
                            showStopMonitoringAlert = true
                        } else {
                            viewModel.stopSelectedSensors()
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                } else {
                    Button("센서 활성화") {
                        viewModel.startSelectedSensors()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.selectedSensors.isEmpty)
                }
                
                Spacer()
                
                if viewModel.showValidationError {
                    Text(viewModel.validationMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            Divider()
            
            // 기록 컨트롤 (항상 표시, 센서 활성화 상태에 따라 활성화/비활성화)
            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    Button(bluetoothKit.isRecording ? "기록 중지" : "기록 시작") {
                        if bluetoothKit.isRecording {
                            bluetoothKit.stopRecording()
                        } else {
                            bluetoothKit.startRecording()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(bluetoothKit.isRecording ? .red : .green)
                    .frame(maxWidth: .infinity)
                    .disabled(!viewModel.isMonitoringActive) // 센서 활성화되어야만 기록 가능
                    .opacity(viewModel.isMonitoringActive ? 1.0 : 0.6)
                    
                    if bluetoothKit.isRecording {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "record.circle.fill")
                                    .foregroundColor(.red)
                                    .scaleEffect(1.1) // pulse 대신 약간 큰 크기로 표시
                                Text("기록 중")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                            }
                            Text("선택된 센서 데이터 저장 중")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // 상태별 안내 메시지
                if !viewModel.isMonitoringActive {
                    VStack(spacing: 4) {
                        Text("💡 센서를 먼저 활성화해야 기록을 시작할 수 있습니다.")
                            .font(.caption)
                            .foregroundColor(.orange)
                            .multilineTextAlignment(.center)
                        
                        Text("저장 경로 : 파일 → 나의 iPhone → LinkBandDemo")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 4)
                } else if !bluetoothKit.isRecording {
                    VStack(spacing: 4) {
                        Text("💡 센서 모니터링 중. 기록 시작 버튼을 눌러 데이터를 저장하세요.")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .multilineTextAlignment(.center)
                        
                        Text("저장 경로 : 파일 → 나의 iPhone → LinkBandDemo")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 4)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// 센서 타입에 따른 색상을 반환하는 메서드
    /// - Parameter sensor: 색상을 결정할 센서 타입
    /// - Returns: 센서에 맞는 SwiftUI Color 객체
    private func colorForSensor(_ sensor: SensorKind) -> Color {
        // 센서별 고유 색상으로 UI에서 구분하기 쉽게 함
        switch sensor.color {
        case "blue": return .blue
        case "red": return .red
        case "green": return .green
        case "orange": return .orange
        default: return .primary
        }
    }
    
    /// ViewModel의 기본값을 사용하여 중복 제거
    /// 각 센서별로 권장되는 기본 샘플 수를 반환
    /// - Parameter sensor: 기본값을 조회할 센서 타입
    /// - Returns: 센서별 권장 샘플 수
    private func defaultSampleCount(for sensor: SensorKind) -> Int {
        // 센서별 특성에 맞는 최적의 샘플 수 설정
        // EEG: 250Hz 샘플링으로 1초간 데이터
        // PPG: 50Hz 샘플링으로 1초간 데이터  
        // 가속도계: 25Hz 샘플링으로 1초간 데이터
        // 배터리: 1개 샘플 (상태 확인용)
        switch sensor {
        case .eeg:
            return 250
        case .ppg:
            return 50
        case .accelerometer:
            return 25
        case .battery:
            return 1
        }
    }
    
    /// Generic한 바인딩을 생성하여 switch문 중복 제거
    /// 샘플 수 텍스트 필드와 ViewModel 간의 양방향 바인딩 생성
    /// - Parameter sensor: 바인딩을 생성할 센서 타입
    /// - Returns: 양방향 데이터 바인딩 객체
    private func sampleCountBinding(for sensor: SensorKind) -> Binding<String> {
        return Binding<String>(
            get: { 
                // ViewModel에서 현재 샘플 수 텍스트 값 가져오기
                self.viewModel.getSampleCountText(for: sensor)
            },
            set: { newValue in
                // 새로운 값을 ViewModel에 설정
                self.viewModel.setSampleCountText(newValue, for: sensor)
            }
        )
    }
    
    /// Generic한 바인딩을 생성하여 switch문 중복 제거
    /// 시간(초) 텍스트 필드와 ViewModel 간의 양방향 바인딩 생성
    /// - Parameter sensor: 바인딩을 생성할 센서 타입
    /// - Returns: 양방향 데이터 바인딩 객체
    private func durationBinding(for sensor: SensorKind) -> Binding<String> {
        return Binding<String>(
            get: { 
                // ViewModel에서 현재 시간(초) 텍스트 값 가져오기
                self.viewModel.getSecondsText(for: sensor)
            },
            set: { newValue in
                // 새로운 값을 ViewModel에 설정
                self.viewModel.setSecondsText(newValue, for: sensor)
            }
        )
    }
    
    /// 분단위 바인딩을 생성합니다.
    /// 시간(분) 텍스트 필드와 ViewModel 간의 양방향 바인딩 생성
    /// - Parameter sensor: 바인딩을 생성할 센서 타입
    /// - Returns: 양방향 데이터 바인딩 객체
    private func minutesBinding(for sensor: SensorKind) -> Binding<String> {
        return Binding<String>(
            get: { 
                // ViewModel에서 현재 시간(분) 텍스트 값 가져오기
                self.viewModel.getMinutesText(for: sensor)
            },
            set: { newValue in
                // 새로운 값을 ViewModel에 설정
                self.viewModel.setMinutesText(newValue, for: sensor)
            }
        )
    }
    
    /// 샘플 수 실시간 검증 및 자동 복원
    /// 사용자 입력 중 실시간으로 유효성을 검사하고 잘못된 입력을 자동 수정
    /// - Parameters:
    ///   - newValue: 검증할 새로운 텍스트 값
    ///   - sensor: 검증 대상 센서 타입
    private func validateAndFixSampleCount(_ newValue: String, for sensor: SensorKind) {
        let trimmedValue = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 빈 값이면 즉시 기본값으로 복원
        // 사용자가 필드를 완전히 비웠을 때 기본값으로 자동 복원
        if trimmedValue.isEmpty {
            let defaultValue = defaultSampleCount(for: sensor)
            viewModel.setSampleCountText("\(defaultValue)", for: sensor)
            return
        }
        
        // 숫자가 아닌 문자가 포함되어 있으면 제거
        // 사용자가 실수로 문자를 입력했을 때 숫자만 남기고 자동 정리
        let numbersOnly = trimmedValue.filter { $0.isNumber }
        if numbersOnly != trimmedValue {
            // 숫자가 없으면 기본값으로 복원
            if numbersOnly.isEmpty {
                let defaultValue = defaultSampleCount(for: sensor)
                viewModel.setSampleCountText("\(defaultValue)", for: sensor)
            } else {
                viewModel.setSampleCountText(numbersOnly, for: sensor)
            }
            return
        }
        
        // 0으로만 이루어져 있으면 기본값으로 복원
        // "000" 같은 무의미한 값을 의미 있는 기본값으로 교체
        if numbersOnly.allSatisfy({ $0 == "0" }) {
            let defaultValue = defaultSampleCount(for: sensor)
            viewModel.setSampleCountText("\(defaultValue)", for: sensor)
            return
        }
        
        // 유효성 검사 실행
        // ViewModel의 비즈니스 로직에 따른 최종 검증 수행
        _ = viewModel.validateSampleCount(newValue, for: sensor)
    }
    
    /// 시간(초) 실시간 검증 및 자동 복원
    /// 시간 기반 수집 모드에서 초 단위 입력값의 유효성 검증
    /// - Parameters:
    ///   - newValue: 검증할 새로운 텍스트 값
    ///   - sensor: 검증 대상 센서 타입
    private func validateAndFixSeconds(_ newValue: String, for sensor: SensorKind) {
        let trimmedValue = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 빈 값이면 즉시 기본값으로 복원
        // 배터리 센서는 60초, 나머지 센서는 1초가 기본값
        if trimmedValue.isEmpty {
            let defaultValue = sensor == .battery ? 60 : 1
            viewModel.setSecondsText("\(defaultValue)", for: sensor)
            return
        }
        
        // 숫자가 아닌 문자가 포함되어 있으면 제거
        // 실시간 입력 검증으로 사용자 경험 향상
        let numbersOnly = trimmedValue.filter { $0.isNumber }
        if numbersOnly != trimmedValue {
            // 숫자가 없으면 기본값으로 복원
            if numbersOnly.isEmpty {
                let defaultValue = sensor == .battery ? 60 : 1
                viewModel.setSecondsText("\(defaultValue)", for: sensor)
            } else {
                viewModel.setSecondsText(numbersOnly, for: sensor)
            }
            return
        }
        
        // 0으로만 이루어져 있으면 기본값으로 복원
        // 0초는 무의미하므로 기본값으로 교체
        if numbersOnly.allSatisfy({ $0 == "0" }) {
            let defaultValue = sensor == .battery ? 60 : 1
            viewModel.setSecondsText("\(defaultValue)", for: sensor)
            return
        }
        
        // 유효성 검사 실행
        // ViewModel의 비즈니스 로직에 따른 최종 검증 수행
        _ = viewModel.validateSeconds(newValue, for: sensor)
    }
    
    /// 분 실시간 검증 및 자동 복원
    /// 시간 기반 수집 모드에서 분 단위 입력값의 유효성 검증
    /// - Parameters:
    ///   - newValue: 검증할 새로운 텍스트 값
    ///   - sensor: 검증 대상 센서 타입
    private func validateAndFixMinutes(_ newValue: String, for sensor: SensorKind) {
        let trimmedValue = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 빈 값이면 즉시 기본값으로 복원
        // 모든 센서에 대해 1분이 기본값
        if trimmedValue.isEmpty {
            viewModel.setMinutesText("1", for: sensor)
            return
        }
        
        // 숫자가 아닌 문자가 포함되어 있으면 제거
        // 사용자 편의성을 위한 자동 정리 기능
        let numbersOnly = trimmedValue.filter { $0.isNumber }
        if numbersOnly != trimmedValue {
            // 숫자가 없으면 기본값으로 복원
            if numbersOnly.isEmpty {
                viewModel.setMinutesText("1", for: sensor)
            } else {
                viewModel.setMinutesText(numbersOnly, for: sensor)
            }
            return
        }
        
        // 0으로만 이루어져 있으면 기본값으로 복원
        // 0분은 무의미하므로 1분으로 교체
        if numbersOnly.allSatisfy({ $0 == "0" }) {
            viewModel.setMinutesText("1", for: sensor)
            return
        }
        
        // 유효성 검사 실행
        // ViewModel의 비즈니스 로직에 따른 최종 검증 수행
        _ = viewModel.validateMinutes(newValue, for: sensor)
    }
    
    /// 빈 필드들을 기본값으로 복원하는 메서드
    /// 사용자가 텍스트 필드를 비워둔 상태에서 포커스를 해제했을 때 호출
    /// 일관된 UI 상태 유지를 위해 모든 빈 필드를 적절한 기본값으로 설정
    private func restoreEmptyFieldsToDefaults() {
        for sensor in mainSensors {
            // 샘플 수 텍스트 필드 확인 및 복원
            let sampleCountText = viewModel.getSampleCountText(for: sensor)
            if sampleCountText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                viewModel.setSampleCountText("\(defaultSampleCount(for: sensor))", for: sensor)
            }
            
            // 시간(초) 텍스트 필드 확인 및 복원
            let secondsText = viewModel.getSecondsText(for: sensor)
            if secondsText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                let defaultSeconds = sensor == .battery ? 60 : 1
                viewModel.setSecondsText("\(defaultSeconds)", for: sensor)
            }
            
            // 분 텍스트 필드 확인 및 복원
            let minutesText = viewModel.getMinutesText(for: sensor)
            if minutesText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                viewModel.setMinutesText("1", for: sensor)
            }
        }
    }
    
    /// 센서 선택 상태를 토글하는 메서드
    /// 사용자가 센서 토글 버튼을 눌렀을 때 선택/해제 상태를 변경
    /// - Parameter sensor: 선택 상태를 변경할 센서 타입
    private func toggleSensorSelection(_ sensor: SensorKind) {
        // 모니터링 중이 아닐 때만 센서 선택 변경 가능
        // 데이터 수집 중에는 센서 구성 변경을 방지하여 일관성 유지
        guard !viewModel.isMonitoringActive else { return }
        
        // 센서 선택/해제 토글
        // 현재 선택된 센서 집합을 복사하여 안전하게 수정
        var newSelection = viewModel.selectedSensors
        if newSelection.contains(sensor) {
            newSelection.remove(sensor)
        } else {
            newSelection.insert(sensor)
        }
        // ViewModel에 변경된 선택 상태 전달
        viewModel.updateSensorSelection(newSelection)
    }
    
    /// 모든 텍스트 필드가 유효한 값을 가지도록 보장하는 메서드
    /// 뷰가 처음 나타날 때 또는 초기화 시점에 호출되어 일관된 초기 상태 제공
    private func ensureAllFieldsHaveValues() {
        for sensor in mainSensors {
            // 샘플 수 텍스트 필드 초기화 확인
            let sampleCountText = viewModel.getSampleCountText(for: sensor)
            if sampleCountText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                viewModel.setSampleCountText("\(defaultSampleCount(for: sensor))", for: sensor)
            }
            
            // 시간(초) 텍스트 필드 초기화 확인
            let secondsText = viewModel.getSecondsText(for: sensor)
            if secondsText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                let defaultSeconds = sensor == .battery ? 60 : 1
                viewModel.setSecondsText("\(defaultSeconds)", for: sensor)
            }
            
            // 분 텍스트 필드 초기화 확인
            let minutesText = viewModel.getMinutesText(for: sensor)
            if minutesText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                viewModel.setMinutesText("1", for: sensor)
            }
        }
    }
}

// MARK: - Helper Views

/// 센서 선택을 위한 토글 버튼 컴포넌트
/// 각 센서의 선택 상태를 시각적으로 표시하고 토글 기능을 제공
private struct SensorToggleButton: View {
    /// 표시할 센서 타입
    let sensor: SensorKind
    /// 현재 선택 상태
    let isSelected: Bool
    /// 버튼 비활성화 상태 (모니터링 중일 때)
    let isDisabled: Bool
    /// 버튼 탭 시 실행될 액션
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                // 선택 상태를 나타내는 체크마크 아이콘
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .green : .gray)
                    .font(.system(size: 14))
                
                // 센서 이름 표시
                Text(sensor.displayName)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1.0)
    }
}

#Preview {
    SimplifiedBatchDataCollectionView(bluetoothKit: BluetoothKitViewModel())
} 
