# 링크밴드 SDK 어댑터 기능 가이드

LooxidLabs 링크밴드 디바이스와의 Bluetooth 연결 및 센서 데이터 수집과 기록을 위한 iOS SDK 어댑터 기능 가이드입니다.

## Overview

이 문서는 링크밴드 디바이스와 상호작용하기 위한 핵심 기능들을 설명합니다. 
모든 기능은 ``BluetoothKitViewModel``과 ``BatchDataConfigurationViewModel``을 통해 제공되며, UI와 SDK 사이의 어댑터 역할을 합니다.

## 설정 가이드

### 링크밴드 SDK 어댑터 다운받기

1. 터미널을 열고 Xcode 프로젝트 루트 폴더로 이동합니다.
2. 아래 커맨드를 복사해 붙여넣으면 SDK 어댑터가 Xcode 프로젝트 안에 자동으로 생성되고 다운로드됩니다.

```bash
git init
git remote add origin https://github.com/LooxidLabs/SDK-iOS.git
git config core.sparseCheckout true
echo "SDKAdapter/" >> .git/info/sparse-checkout
git pull origin develop
```

### Xcode에서 추가

#### 링크밴드 SDK 추가
1. File → Add Package Dependencies...
2. 레포지토리 URL 입력 (https://github.com/LooxidLabs/SDK-iOS.git)
3. Add Package 누르기
4. [프로젝트명] → Targets → [프로젝트명] → General → Frameworks, Libraries, and Embedded Content
5. "+" 선택 → BluetoothKit Package → BluetoothKit 선택 → Add 누르기

#### 블루투스 권한 설정
1. [프로젝트명] → Targets → [프로젝트명] → Info → Custom iOS Target Properties 
2. "+" 선택후 아래 키 추가
   - Privacy - Bluetooth Always Usage Description
   - Privacy - Bluetooth Peripheral Usage Description

## 핵심 기능

> **핵심 기능들은 모두 ``BluetoothKitViewModel``만 사용합니다.**  
> 고급 데이터 수집 기능은 별도의 ``BatchDataConfigurationViewModel``을 사용하며, 이는 [고급 설정](#고급-설정---배치-데이터-수집-코드-예시) 섹션에서 다룹니다.

### 1. Bluetooth 스캔 관리
- ``BluetoothKitViewModel/startScanning()`` - Bluetooth 디바이스 스캔 시작
- ``BluetoothKitViewModel/stopScanning()`` - Bluetooth 디바이스 스캔 중지
- ``BluetoothKitViewModel/isScanning`` - 현재 스캔 상태 확인

### 2. 디바이스 목록 관리  
- ``BluetoothKitViewModel/discoveredDevices`` - 스캔으로 발견된 디바이스 목록
- ``DeviceInfo`` - Bluetooth 디바이스 정보 구조체

### 3. 디바이스 연결 관리
- ``BluetoothKitViewModel/connect(to:)`` - 특정 디바이스에 연결
- ``BluetoothKitViewModel/disconnect()`` - 현재 연결된 디바이스에서 연결 해제
- ``BluetoothKitViewModel/connectionState`` - 현재 연결 상태
- ``BluetoothKitViewModel/isConnected`` - 연결 상태 확인
- ``DeviceConnectionState`` - 연결 상태 열거형

### 4. 센서 데이터 수신 관리
- ``BluetoothKitViewModel/enableMonitoring()`` - 센서 모니터링 시작 (실시간 데이터 수신)
- ``BluetoothKitViewModel/disableMonitoring()`` - 센서 모니터링 중지
- ``BluetoothKitViewModel/latestEEGReading`` - 최신 EEG 데이터
- ``BluetoothKitViewModel/latestPPGReading`` - 최신 PPG 데이터  
- ``BluetoothKitViewModel/latestAccelerometerReading`` - 최신 ACC 데이터
- ``BluetoothKitViewModel/latestBatteryReading`` - 최신 배터리 데이터

### 5. 데이터 기록 및 저장
- ``BluetoothKitViewModel/startRecording()`` - CSV 파일로 센서 데이터 기록 시작
- ``BluetoothKitViewModel/stopRecording()`` - 센서 데이터 기록 중지
- ``BluetoothKitViewModel/recordingsDirectory`` - 기록 파일이 저장되는 디렉토리
- ``BluetoothKitViewModel/recordedFiles`` - 기록된 파일 목록
- ``BluetoothKitViewModel/isRecording`` - 현재 기록 상태 확인

## BatchDataConfigurationViewModel - 고급 데이터 수집 설정

``BatchDataConfigurationViewModel``은 센서별 세밀한 데이터 수집 설정을 관리하는 전용 ViewModel입니다.

### 배치 데이터 수집 핵심 기능

#### 1. 배치 모니터링 제어
- ``BatchDataConfigurationViewModel/startMonitoring()`` - 배치 데이터 모니터링 시작
- ``BatchDataConfigurationViewModel/stopMonitoring()`` - 배치 데이터 모니터링 중지
- ``BatchDataConfigurationViewModel/isMonitoringActive`` - 현재 모니터링 상태

#### 2. 센서 선택 관리
- ``BatchDataConfigurationViewModel/updateSensorSelection(_:)`` - 모니터링할 센서 선택
- ``BatchDataConfigurationViewModel/selectedSensors`` - 현재 선택된 센서들
- ``BatchDataConfigurationViewModel/isSensorSelected(_:)`` - 특정 센서 선택 상태 확인

#### 3. 수집 모드 설정
- ``BatchDataConfigurationViewModel/updateCollectionMode(_:)`` - 데이터 수집 모드 변경
- ``BatchDataConfigurationViewModel/selectedCollectionMode`` - 현재 수집 모드
- ``CollectionModeKind`` - 수집 모드 종류 (샘플 수/시간 기반)

#### 4. 센서별 상세 설정
- **샘플 수 기반 설정:**
  - ``BatchDataConfigurationViewModel/setSampleCount(_:for:)`` - 센서별 목표 샘플 수 설정
  - ``BatchDataConfigurationViewModel/getSampleCount(for:)`` - 현재 설정된 샘플 수 조회
  - ``BatchDataConfigurationViewModel/setSampleCountText(_:for:)`` - UI 텍스트 필드 값 설정
  - ``BatchDataConfigurationViewModel/getSampleCountText(for:)`` - UI 텍스트 필드 값 조회

- **시간 기반 설정:**
  - ``BatchDataConfigurationViewModel/setSeconds(_:for:)`` - 센서별 수집 시간(초) 설정
  - ``BatchDataConfigurationViewModel/getSeconds(for:)`` - 현재 설정된 시간(초) 조회
  - ``BatchDataConfigurationViewModel/setMinutes(_:for:)`` - 센서별 수집 시간(분) 설정
  - ``BatchDataConfigurationViewModel/getMinutes(for:)`` - 현재 설정된 시간(분) 조회

#### 5. 유효성 검증
- ``BatchDataConfigurationViewModel/validateSampleCount(_:for:)`` - 샘플 수 값 검증
- ``BatchDataConfigurationViewModel/validateSeconds(_:for:)`` - 시간(초) 값 검증
- ``BatchDataConfigurationViewModel/validateMinutes(_:for:)`` - 시간(분) 값 검증
- ``BatchDataConfigurationViewModel/showValidationError`` - 검증 오류 UI 상태
- ``BatchDataConfigurationViewModel/validationMessage`` - 검증 오류 메시지

#### 6. 예상 값 계산
- ``BatchDataConfigurationViewModel/getExpectedTime(for:sampleCount:)`` - 샘플 수 기반 예상 수집 시간
- ``BatchDataConfigurationViewModel/getExpectedSamples(for:seconds:)`` - 시간 기반 예상 샘플 수
- ``BatchDataConfigurationViewModel/getExpectedMinutes(for:sampleCount:)`` - 샘플 수 기반 예상 수집 시간(분)

#### 7. 기록 중 설정 변경 처리
- ``BatchDataConfigurationViewModel/confirmSensorChangeWithRecordingStop()`` - 기록 중지 후 센서 변경 확인
- ``BatchDataConfigurationViewModel/cancelSensorChange()`` - 센서 변경 취소
- ``BatchDataConfigurationViewModel/showRecordingChangeWarning`` - 기록 중 변경 경고 상태

## 코드 예시

### 기본 ViewModel 설정

```swift
import SwiftUI

struct ContentView: View {
    @StateObject private var bluetoothKitViewModel = BluetoothKitViewModel()
    
    var body: some View {
        VStack {
            // UI 구성
        }
    }
}
```

### 1. Bluetooth 스캔 구현 예시

```swift
struct ScanControlView: View {
    @ObservedObject var bluetoothKit: BluetoothKitViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            if bluetoothKit.isScanning {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                
                Button("스캔 중지") {
                    bluetoothKit.stopScanning()
                }
                .buttonStyle(.bordered)
                .tint(.red)
            } else {
                Button("스캔 시작") {
                    bluetoothKit.startScanning()
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
            }
        }
    }
}
```

### 2. 디바이스 목록 표시 및 연결

```swift
struct DeviceListView: View {
    @ObservedObject var bluetoothKit: BluetoothKitViewModel
    
    var body: some View {
        if !bluetoothKit.discoveredDevices.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("발견된 디바이스")
                    .font(.headline)
                
                ForEach(bluetoothKit.discoveredDevices, id: \.id) { device in
                    DeviceRow(device: device, bluetoothKit: bluetoothKit)
                }
            }
        }
    }
}

struct DeviceRow: View {
    let device: DeviceInfo
    @ObservedObject var bluetoothKit: BluetoothKitViewModel
    
    var body: some View {
        HStack {
            Text(device.name)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
            
            Button("연결") {
                bluetoothKit.connect(to: device)
            }
            .buttonStyle(.bordered)
            .tint(.blue)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(8)
    }
}
```

### 3. 센서 데이터 수신 표시

```swift
struct SensorDataView: View {
    @ObservedObject var bluetoothKit: BluetoothKitViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // EEG 데이터 표시
            if let eegReading = bluetoothKit.latestEEGReading {
                EEGDataCard(reading: eegReading)
            }
            
            // PPG 데이터 표시
            if let ppgReading = bluetoothKit.latestPPGReading {
                PPGDataCard(reading: ppgReading)
            }
            
            // 가속도계 데이터 표시
            if let accelReading = bluetoothKit.latestAccelerometerReading {
                AccelerometerDataCard(reading: accelReading)
            }
            
            // 배터리 데이터 표시
            if let batteryReading = bluetoothKit.latestBatteryReading {
                BatteryDataCard(reading: batteryReading)
            }
        }
    }
}

struct EEGDataCard: View {
    let reading: EEGData
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.purple)
                Text("EEG 데이터")
                    .font(.headline)
                Spacer()
                Image(systemName: reading.leadOff ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                    .foregroundColor(reading.leadOff ? .red : .green)
            }
            
            HStack(spacing: 20) {
                VStack {
                    Text("CH1")
                        .font(.caption)
                    Text(String(format: "%.1f µV", reading.channel1))
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                VStack {
                    Text("CH2")
                        .font(.caption)
                    Text(String(format: "%.1f µV", reading.channel2))
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                VStack {
                    Text("접촉 상태")
                        .font(.caption)
                    Text(reading.leadOff ? "접촉 안됨" : "접촉됨")
                        .font(.caption)
                        .foregroundColor(reading.leadOff ? .red : .green)
                }
            }
        }
        .padding()
        .background(Color.purple.opacity(0.1))
        .cornerRadius(12)
    }
}
```

### 4. 센서 모니터링 제어

```swift
struct MonitoringControlView: View {
    @ObservedObject var bluetoothKit: BluetoothKitViewModel
    
    var body: some View {
        HStack {
            Button("모니터링 시작") {
                bluetoothKit.enableMonitoring()
            }
            .disabled(!bluetoothKit.isConnected)
            
            Button("모니터링 중지") {
                bluetoothKit.disableMonitoring()
            }
            .disabled(!bluetoothKit.isConnected)
        }
        .buttonStyle(.bordered)
    }
}
```

### 5. 데이터 기록 (CSV 저장) 구현

```swift
struct RecordingControlView: View {
    @ObservedObject var bluetoothKit: BluetoothKitViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: bluetoothKit.isRecording ? "stop.circle.fill" : "record.circle")
                    .foregroundColor(bluetoothKit.isRecording ? .red : .blue)
                    .font(.title2)
                
                Text(bluetoothKit.isRecording ? "기록 중지" : "기록 시작")
                    .font(.headline)
                    .foregroundColor(bluetoothKit.isRecording ? .red : .blue)
                
                Spacer()
                
                if bluetoothKit.isRecording {
                    Image(systemName: "circle.fill")
                        .foregroundColor(.red)
                        .symbolEffect(.pulse)
                }
            }
            
            Button(action: {
                if bluetoothKit.isRecording {
                    bluetoothKit.stopRecording()
                } else {
                    bluetoothKit.startRecording()
                }
            }) {
                Text(bluetoothKit.isRecording ? "중지" : "시작")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(bluetoothKit.isRecording ? Color.red : Color.blue)
                    .cornerRadius(8)
            }
            .disabled(!bluetoothKit.isConnected)
            
            // 기록 파일 디렉토리 표시
            if bluetoothKit.isRecording {
                Text("저장 위치: \(bluetoothKit.recordingsDirectory.path)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            Color(bluetoothKit.isRecording ? .red : .blue)
                .opacity(0.1)
        )
        .cornerRadius(12)
    }
}
```

### 6. 연결 상태 모니터링

```swift
struct ConnectionStatusView: View {
    @ObservedObject var bluetoothKit: BluetoothKitViewModel
    
    var body: some View {
        HStack {
            Image(systemName: connectionIcon)
                .foregroundColor(connectionColor)
                .font(.title2)
            
            VStack(alignment: .leading) {
                Text("연결 상태")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(bluetoothKit.connectionStatusDescription)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            if bluetoothKit.isConnected {
                Button("연결 해제") {
                    bluetoothKit.disconnect()
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var connectionIcon: String {
        switch bluetoothKit.connectionState {
        case .disconnected: return "wave.3.right.circle"
        case .scanning: return "magnifyingglass.circle"
        case .connecting: return "arrow.triangle.2.circlepath.circle"
        case .connected: return "wave.3.right.circle.fill"
        case .reconnecting: return "arrow.clockwise.circle"
        case .failed: return "exclamationmark.triangle.fill"
        }
    }
    
    private var connectionColor: Color {
        switch bluetoothKit.connectionState {
        case .disconnected: return .gray
        case .scanning: return .blue
        case .connecting, .reconnecting: return .orange
        case .connected: return .green
        case .failed: return .red
        }
    }
}
```

## 고급 설정 - 배치 데이터 수집 코드 예시

### BatchDataConfigurationViewModel 생성 및 설정

```swift
struct BatchDataCollectionView: View {
    @ObservedObject var bluetoothKit: BluetoothKitViewModel
    @StateObject private var batchViewModel: BatchDataConfigurationViewModel
    
    init(bluetoothKit: BluetoothKitViewModel) {
        self.bluetoothKit = bluetoothKit
        // BluetoothKitViewModel에서 BatchDataConfigurationViewModel 생성
        self._batchViewModel = StateObject(wrappedValue: bluetoothKit.createBatchDataConfigurationViewModel())
    }
    
    var body: some View {
        VStack {
            // 배치 데이터 수집 UI
        }
    }
}
```

### 1. 배치 데이터 수집 모드 선택

```swift
struct CollectionModeView: View {
    @ObservedObject var batchViewModel: BatchDataConfigurationViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("수집 모드")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Picker("수집 모드", selection: $batchViewModel.selectedCollectionMode) {
                ForEach(CollectionModeKind.allCases, id: \.self) { mode in
                    Text(mode.displayName).tag(mode)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .disabled(batchViewModel.isMonitoringActive)
            .onChange(of: batchViewModel.selectedCollectionMode) { newMode in
                batchViewModel.updateCollectionMode(newMode)
            }
        }
    }
}
```

### 2. 센서 선택 및 배치 모니터링

```swift
struct SensorSelectionView: View {
    @ObservedObject var batchViewModel: BatchDataConfigurationViewModel
    
    private let mainSensors: [SensorKind] = [.eeg, .ppg, .accelerometer]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("모니터링할 센서 선택")
                .font(.subheadline)
                .fontWeight(.medium)
            
            HStack(spacing: 20) {
                ForEach(mainSensors, id: \.self) { sensor in
                    SensorToggle(sensor: sensor, batchViewModel: batchViewModel)
                }
            }
            
            // 모니터링 제어 버튼
            HStack {
                Button(action: {
                    if batchViewModel.isMonitoringActive {
                        batchViewModel.stopMonitoring()
                    } else {
                        batchViewModel.startMonitoring()
                    }
                }) {
                    Text(batchViewModel.isMonitoringActive ? "모니터링 중지" : "모니터링 시작")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(batchViewModel.isMonitoringActive ? Color.red : Color.blue)
                        .cornerRadius(8)
                }
            }
        }
    }
}

struct SensorToggle: View {
    let sensor: SensorKind
    @ObservedObject var batchViewModel: BatchDataConfigurationViewModel
    
    var body: some View {
        VStack {
            Button(action: {
                var newSelection = batchViewModel.selectedSensors
                if batchViewModel.isSensorSelected(sensor) {
                    newSelection.remove(sensor)
                } else {
                    newSelection.insert(sensor)
                }
                batchViewModel.updateSensorSelection(newSelection)
            }) {
                VStack(spacing: 4) {
                    Text(sensor.emoji)
                        .font(.title2)
                    Text(sensor.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .frame(width: 60, height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(batchViewModel.isSensorSelected(sensor) ? 
                              Color(sensor.color).opacity(0.2) : Color.gray.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(batchViewModel.isSensorSelected(sensor) ? 
                                        Color(sensor.color) : Color.gray.opacity(0.3), lineWidth: 2)
                        )
                )
            }
            .disabled(batchViewModel.isMonitoringActive)
        }
    }
}
```

### 3. 센서별 상세 설정

```swift
struct SensorConfigurationView: View {
    @ObservedObject var batchViewModel: BatchDataConfigurationViewModel
    let sensor: SensorKind
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(sensor.emoji)
                Text(sensor.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
            }
            
            if batchViewModel.selectedCollectionMode == .sampleCount {
                sampleCountSetting
            } else if batchViewModel.selectedCollectionMode == .seconds {
                secondsSetting
            } else {
                minutesSetting
            }
        }
        .padding()
        .background(Color(sensor.color).opacity(0.1))
        .cornerRadius(8)
    }
    
    private var sampleCountSetting: some View {
        HStack {
            Text("목표 샘플 수:")
                .font(.caption)
            
            TextField("샘플 수", text: sampleCountText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .frame(width: 80)
                .onChange(of: batchViewModel.getSampleCountText(for: sensor)) { newValue in
                    if batchViewModel.validateSampleCount(newValue, for: sensor) {
                        let intValue = Int(newValue) ?? 100
                        batchViewModel.setSampleCount(intValue, for: sensor)
                    }
                }
            
            Text("예상 시간: \(String(format: "%.1f", batchViewModel.getExpectedTime(for: sensor, sampleCount: batchViewModel.getSampleCount(for: sensor))))초")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var secondsSetting: some View {
        HStack {
            Text("수집 시간:")
                .font(.caption)
            
            TextField("초", text: secondsText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .frame(width: 60)
                .onChange(of: batchViewModel.getSecondsText(for: sensor)) { newValue in
                    if batchViewModel.validateSeconds(newValue, for: sensor) {
                        let intValue = Int(newValue) ?? 30
                        batchViewModel.setSeconds(intValue, for: sensor)
                    }
                }
            
            Text("초")
                .font(.caption)
            
            Text("예상 샘플: \(batchViewModel.getExpectedSamples(for: sensor, seconds: batchViewModel.getSeconds(for: sensor)))개")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var minutesSetting: some View {
        HStack {
            Text("수집 시간:")
                .font(.caption)
            
            TextField("분", text: minutesText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .frame(width: 60)
                .onChange(of: batchViewModel.getMinutesText(for: sensor)) { newValue in
                    if batchViewModel.validateMinutes(newValue, for: sensor) {
                        let intValue = Int(newValue) ?? 1
                        batchViewModel.setMinutes(intValue, for: sensor)
                    }
                }
            
            Text("분")
                .font(.caption)
            
            Text("예상 샘플: \(batchViewModel.getExpectedSamplesForMinutes(for: sensor, minutes: batchViewModel.getMinutes(for: sensor)))개")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var sampleCountText: Binding<String> {
        Binding(
            get: { batchViewModel.getSampleCountText(for: sensor) },
            set: { batchViewModel.setSampleCountText($0, for: sensor) }
        )
    }
    
    private var secondsText: Binding<String> {
        Binding(
            get: { batchViewModel.getSecondsText(for: sensor) },
            set: { batchViewModel.setSecondsText($0, for: sensor) }
        )
    }
    
    private var minutesText: Binding<String> {
        Binding(
            get: { batchViewModel.getMinutesText(for: sensor) },
            set: { batchViewModel.setMinutesText($0, for: sensor) }
        )
    }
}
```

### 4. 유효성 검증 및 오류 처리

```swift
struct ValidationErrorView: View {
    @ObservedObject var batchViewModel: BatchDataConfigurationViewModel
    
    var body: some View {
        if batchViewModel.showValidationError {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                Text(batchViewModel.validationMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                Spacer()
                Button("확인") {
                    batchViewModel.showValidationError = false
                }
                .font(.caption)
                .buttonStyle(.bordered)
                .tint(.red)
            }
            .padding()
            .background(Color.red.opacity(0.1))
            .cornerRadius(8)
        }
    }
}
```

## 사용 예시

### 기본 워크플로우
1. **스캔 시작**: ``BluetoothKitViewModel/startScanning()``
2. **디바이스 목록 확인**: ``BluetoothKitViewModel/discoveredDevices``
3. **디바이스 연결**: ``BluetoothKitViewModel/connect(to:)``
4. **센서 모니터링 시작**: ``BluetoothKitViewModel/enableMonitoring()``
5. **데이터 기록 시작**: ``BluetoothKitViewModel/startRecording()``
6. **기록 중지**: ``BluetoothKitViewModel/stopRecording()``
7. **모니터링 중지**: ``BluetoothKitViewModel/disableMonitoring()``
8. **연결 해제**: ``BluetoothKitViewModel/disconnect()``

### 배치 데이터 수집 워크플로우
1. **BatchDataConfigurationViewModel 생성**: ``BluetoothKitViewModel/createBatchDataConfigurationViewModel()``
2. **수집 모드 선택**: ``BatchDataConfigurationViewModel/updateCollectionMode(_:)``
3. **센서 선택**: ``BatchDataConfigurationViewModel/updateSensorSelection(_:)``
4. **센서별 설정**: ``BatchDataConfigurationViewModel/setSampleCount(_:for:)``
5. **배치 모니터링 시작**: ``BatchDataConfigurationViewModel/startMonitoring()``
6. **모니터링 중지**: ``BatchDataConfigurationViewModel/stopMonitoring()``

## Topics

### 뷰모델
- ``BluetoothKitViewModel``
- ``BatchDataConfigurationViewModel``

### 디바이스 관리
- ``DeviceInfo``
- ``DeviceConnectionState``

### 센서 데이터 타입
- ``EEGData``
- ``PPGData`` 
- ``AccelerometerData``
- ``BatteryData``
- ``SensorKind``

### 설정 타입
- ``CollectionModeKind``
- ``AccelMode``
