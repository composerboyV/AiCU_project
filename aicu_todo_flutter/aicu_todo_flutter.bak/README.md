# 📱 AiCU Todo Flutter App

AICU 신입 개발자 채용 과제의 Flutter 모바일 애플리케이션입니다.

## 🚀 주요 기능

- ✅ 사용자 회원가입 및 로그인
- ✅ JWT 토큰 기반 인증
- ✅ Todo 목록 조회, 생성, 수정, 삭제
- ✅ 실시간 Todo 상태 업데이트
- ✅ 크로스 플랫폼 지원 (Web, Android, iOS)

## 🛠 기술 스택

- **Framework**: Flutter 3.35.2
- **Language**: Dart 3.9.0
- **State Management**: Riverpod 2.6.1
- **HTTP Client**: http 1.5.0
- **Local Storage**: SharedPreferences 2.5.3

## 📁 프로젝트 구조

```
lib/
├── models/           # 데이터 모델
│   ├── user.dart
│   └── todo.dart
├── services/         # API 서비스
│   └── api_service.dart
├── providers/        # Riverpod 상태 관리
│   ├── auth_provider.dart
│   └── todo_provider.dart
├── screens/          # UI 화면
│   ├── login_screen.dart
│   ├── register_screen.dart
│   └── todo_screen.dart
└── main.dart        # 앱 진입점
```

## 🏃‍♂️ 실행 방법

### 1. 의존성 설치
```bash
flutter pub get
```

### 2. 백엔드 서버 실행 확인
백엔드 API 서버가 `http://localhost:4000`에서 실행 중인지 확인하세요.

### 3. 앱 실행

#### 웹에서 실행
```bash
flutter run -d chrome --web-port 8080
```

#### Android 에뮬레이터에서 실행
```bash
flutter run -d android
```

#### iOS 시뮬레이터에서 실행 (macOS만)
```bash
flutter run -d ios
```

## 🎯 사용법

1. **회원가입**: 이메일과 비밀번호로 새 계정 생성
2. **로그인**: 기존 계정으로 로그인
3. **Todo 관리**:
   - 새 Todo 추가: 상단 입력 필드에 할 일 입력 후 추가 버튼 클릭
   - Todo 완료: 체크박스 클릭으로 완료 상태 토글
   - Todo 삭제: 오른쪽 삭제 버튼 클릭
   - 새로고침: 상단 새로고침 버튼으로 최신 데이터 로드

## 🔧 환경 설정

### API 베이스 URL 변경
`lib/services/api_service.dart` 파일에서 `baseUrl`을 수정하세요:

```dart
static const String baseUrl = 'http://localhost:4000';
```

배포 환경에서는 실제 서버 주소로 변경해야 합니다.

## 📱 지원 플랫폼

- ✅ **Web**: Chrome, Safari, Firefox 등 모던 브라우저
- ✅ **Android**: API 21+ (Android 5.0+)
- ✅ **iOS**: iOS 12.0+ (Xcode 14.2에서 테스트됨)

## 🎨 UI/UX 특징

- **Material Design 3**: 최신 Material Design 가이드라인 적용
- **반응형 디자인**: 다양한 화면 크기에 최적화
- **직관적 인터페이스**: 사용자 친화적인 Todo 관리 경험
- **실시간 피드백**: 로딩 상태 및 에러 메시지 표시

## 🔐 보안

- JWT 토큰을 SharedPreferences에 안전하게 저장
- 자동 로그인 상태 유지
- API 요청 시 토큰 자동 포함
- 인증 실패 시 자동 로그아웃

## 🧪 테스트

### 단위 테스트 실행
```bash
flutter test
```

### 통합 테스트 실행
```bash
flutter drive --target=test_driver/app.dart
```

## 📝 개발 메모

- **상태 관리**: Riverpod을 사용하여 예측 가능한 상태 관리 구현
- **에러 처리**: 네트워크 오류 및 API 에러에 대한 적절한 처리
- **성능 최적화**: 효율적인 위젯 리빌드 및 메모리 관리
- **코드 품질**: Dart 분석기 규칙 준수 및 깔끔한 코드 작성

## 🔧 문제 해결

### 일반적인 문제

1. **네트워크 연결 오류**
   - 백엔드 서버가 실행 중인지 확인
   - 방화벽 설정 확인

2. **빌드 오류**
   - `flutter clean` 후 `flutter pub get` 실행
   - Flutter 및 Dart SDK 버전 확인

3. **iOS 시뮬레이터 문제**
   - Xcode 설치 및 라이선스 동의
   - iOS 시뮬레이터 설치 확인

## 📞 지원

문제가 발생하거나 질문이 있으시면 개발자에게 문의하세요.

**개발자**: 곽준기  
**이메일**: [이메일 주소]  
**프로젝트**: AICU 신입 개발자 채용 과제