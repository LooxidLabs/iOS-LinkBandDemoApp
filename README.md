# iOS-LinkBandDemoApp

LooxidLabs LinkBand 디바이스와의 Bluetooth 연결 및 센서 데이터 수집을 시연하는 iOS 데모 앱입니다.

## 주요 기능

### 📡 Bluetooth 연결
- LinkBand 디바이스 자동 스캔 및 연결
- 자동 재연결 기능
- 연결 상태 실시간 모니터링

### 📊 센서 데이터 수집

#### EEG (뇌전도)
- 2채널 원시 신호(raw data)
- 전압 변환값 (µV 단위)
- 전극 접촉 상태 정보

#### PPG (광전 용적 맥파)
- 적외선(IR) 및 적색(RED) 신호

#### ACC (가속도계)
- 3축(x, y, z) 원시값
- 움직임 모드 전환 기능 지원

#### 배터리
- 잔량 모니터링 기능

### 📈 배치 데이터 수집
- 샘플 수 기반 수집
- 시간 기반 수집 (초/분)
- 센서별 개별 설정
- 실시간 모니터링

### 💾 데이터 관리
- CSV 형식으로 센서 데이터 저장
- 기록된 파일 관리 및 공유

## 기술 스택

- **프레임워크**: SwiftUI
- **아키텍처**: MVVM + Adapter Pattern
- **Bluetooth**: BluetoothKit SDK
- **최소 지원 버전**: Xcode 16.4+, iOS 18.4+, macOS 15.5+

## 프로젝트 구조

```
LinkBandDemo/
├── LinkBandDemoApp.swift          # 앱 진입점
├── ContentView.swift              # 메인 UI
├── SDKAdapter/                    # SDK 어댑터 레이어
│   ├── BluetoothKitViewModel.swift
│   ├── BatchDataConfigurationViewModel.swift
│   └── ViewModelTypes.swift
└── Views/                         # UI 컴포넌트
    ├── StatusCard/
    ├── SensorData/
    ├── Controls/
    └── Files/
```

## 사용법

1. 앱 실행 후 "스캔 시작" 버튼 터치
2. 발견된 LinkBand 디바이스에 "연결" 버튼 터치
3. 연결 완료 후 실시간 센서 데이터 확인
4. 필요시 배치 데이터 수집 설정 후 기록 시작
