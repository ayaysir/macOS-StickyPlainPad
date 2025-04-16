# Global Function vs Static Function

> 글로벌 func 랑 static 클래스/구조체 (예: 독립된 someFunction 이랑 ClassName.someFunction()) 는 동작 원리 및 방식이 같나 다르나?

훌륭한 질문입니다!  
`global function`과 `static func` (클래스나 구조체의 정적 함수)는 **문법상 비슷해 보여도**,  
**동작 방식, 메모리 구조, 네임스페이스, 접근 방식** 면에서 중요한 차이가 있습니다.

---

## 🧠 차이 요약

| 항목 | 글로벌 함수 | `static` 메서드 |
|------|-------------|------------------|
| **정의 위치** | 전역 (파일 스코프) | 타입 내부 (`class`, `struct`, `enum`) |
| **접근 방식** | 함수명 직접 호출 | `타입명.함수()` 형태로 호출 |
| **네임스페이스** | 없음 (같은 파일 내에 중복 불가) | 있음 (타입 내에서 구분됨) |
| **오버로딩** | 가능 | 가능 |
| **디스패치 방식** | 정적 (컴파일 타임) | 정적 (컴파일 타임), 클래스인 경우 가상 디스패치 가능 |
| **의미적 역할** | 범용 유틸리티 | 타입과 논리적으로 관련된 동작 |

---

## ✅ 예시 비교

### 글로벌 함수

```swift
func makeTitleCase(_ string: String) -> String {
  string.capitalized
}
```

- 범용 기능
- 어떤 타입에도 소속되지 않음
- 파일이나 모듈 내에서 중복 정의 불가

### static 함수

```swift
struct StringFormatter {
  static func makeTitleCase(_ string: String) -> String {
    string.capitalized
  }
}
```

- `StringFormatter.makeTitleCase(...)`처럼 **네임스페이스에 속함**
- 동일 이름을 다른 타입에도 정의 가능

---

## 🧩 내부 동작 원리 차이

### 🟢 글로벌 함수
- Swift에서 글로벌 함수는 실제로 **정적 함수로 컴파일**되며,  
  컴파일 시점에 메모리에 바로 올라가는 **함수 포인터**와 유사한 구조입니다.
- C 기반의 symbol로 변환됨: `_function_name`

### 🔵 static 메서드
- `struct`이나 `enum`에서는 static 함수도 컴파일 타임에 결정되며 글로벌 함수처럼 정적으로 동작합니다.
- `class`에서의 static은 기본적으로 final이며 정적 디스패치 되지만, `class func`는 오버라이드 가능하므로 **동적 디스패치(vtable)**를 사용합니다.

---

## ✅ 언제 어떤 걸 쓰는 게 좋을까?

| 상황 | 추천 방식 | 이유 |
|------|------------|------|
| 범용 유틸리티 함수 | 글로벌 함수 | 논리적으로 특정 타입에 속하지 않음 |
| 타입 관련 도우미 | `static` 메서드 | 구조화 및 네임스페이스 분리 |
| 테스트/DI 고려 | `static` 또는 `instance` 메서드 | 의존성 주입 및 mock이 쉬움 |
| 이름 충돌 위험 회피 | `static` 메서드 | 다른 파일이나 모듈과의 중복 방지 |

---

## 🎯 결론

- **기술적으로는 유사한 방식으로 컴파일**되지만,  
- **논리적 구조와 코드 조직 측면에서는 매우 다른 역할**을 합니다.
- **프레임워크/라이브러리/모듈 규모가 커질수록 static 네임스페이스 구조가 훨씬 유리**합니다.

---

> 함수 포인터와 vtable 차이점이 뭔데/?

## Function Pointer vs Virtual Table

좋은 질문입니다!  
**함수 포인터(Function Pointer)**와 **vtable(Virtual Table)**은 모두 "함수 호출을 위한 주소"를 다루지만, **목적과 구조, 동작 방식이 매우 다릅니다.**

---

## ✅ 요약: 차이점 비교표

| 항목 | 함수 포인터 (Function Pointer) | vtable (Virtual Table) |
|------|-------------------------------|-------------------------|
| 📦 저장 대상 | **개별 함수 주소** | **클래스마다 가상 함수 주소들의 배열** |
| 🧠 디스패치 시점 | **정적(컴파일 타임)** 또는 **동적** | **항상 동적(런타임)** |
| 🎯 목적 | 단일 함수 호출 | 다형성(override) 함수 호출 |
| 🧩 사용 맥락 | C 스타일 또는 Swift 글로벌/static 함수 | 클래스 기반 가상 메서드 호출 |
| 🏷️ 주소 위치 | 함수 단위로 따로 보관됨 | 클래스마다 1개 vtable 존재 |
| ⛓️ 성능 | 빠름 (간단한 jump) | 약간 느림 (vtable 인덱싱 후 jump) |

---

## 🧠 함수 포인터 (Function Pointer)

### 📌 정의
- 함수의 **메모리 주소를 변수처럼 저장**해서 나중에 호출할 수 있도록 하는 기능

### 📌 Swift/C 예시

```c
void sayHello() {
  printf("Hello\n");
}

void (*fnPtr)() = sayHello;
fnPtr();  // "Hello"
```

Swift에선 이런 식으로 사용됩니다:

```swift
let fn: () -> Void = {
  print("Hello")
}
fn() // 실행
```

> ✅ 컴파일러가 `fn`이라는 변수에 해당 함수의 주소를 저장해 둠  
> → **jump 명령어 하나로 호출**, 빠름

---

## 🧠 vtable (Virtual Table)

### 📌 정의
- **클래스 기반 상속 구조**에서, 오버라이드된 메서드를 동적으로 선택하기 위한 **함수 포인터 배열**
- 클래스마다 **vtable(가상 함수 테이블)**이 1개 존재

### 📌 동작 방식

```swift
class Animal {
  func speak() { print("...") }
}

class Dog: Animal {
  override func speak() { print("멍멍") }
}

let pet: Animal = Dog()
pet.speak() // → 런타임에 Dog.speak 호출
```

➡️ `speak()` 호출 시, 컴파일 타임에는 Animal에 정의되어 있지만  
➡️ **런타임에 vtable을 통해 Dog의 speak가 선택됨**

> 🔁 vtable: `[offset 0: Dog.speak(), offset 1: Dog.run(), ...]`

---

## 🚀 비유로 이해하기

| 기능 | 비유 |
|------|------|
| 함수 포인터 | "특정 가게 전화번호를 알고 직접 전화함" |
| vtable | "전화번호부에서 그때그때 역할(직책)에 따라 전화를 걸기" — 예: `직원.상담()`은 상황 따라 다른 사람이 받음 |

---

## 🧠 Swift에서 적용

| 구조 | 디스패치 방식 | 내부 구조 |
|------|----------------|------------|
| `struct`, `enum` | 정적 디스패치 (함수 포인터) | 인라인 호출 |
| `class`, `override func` | 동적 디스패치 (vtable) | 런타임 테이블 인덱싱 |

---

## 🎯 결론 요약

| 요약 키워드 | 함수 포인터 | vtable |
|-------------|--------------|--------|
| 목적 | 함수 호출 | 다형성/오버라이드 |
| 방식 | 직접 호출 | 테이블 간접 호출 |
| 위치 | 함수 단위 | 클래스 단위 |
| 성능 | 빠름 | 조금 느림 |
| Swift 적용 | 글로벌/static/struct 함수 | class override method |

---

더 깊이 들어가면 `witness table`, `existential container`, `dynamic dispatch`, `@inlineable`, `@objc dynamic` 등도 연결되어 있는데요, 필요하시면 해당 주제도 이어서 설명드릴 수 있습니다!

---

## 글로벌 함수 파일 이름 추천

> readTextFileAutoEncoding 라는 글로벌 함수를 저장하는 파일 이름으로 추천하는거 있어? 내 생각은 ReadText...swift 로 그냥 앞글자만 대문자로 바꿔서 저장하고싶은데

네, 그 방식도 충분히 괜찮습니다! 다만 목적에 따라 조금 더 명확하고 관리하기 쉬운 이름을 제안드릴 수도 있어요. 아래에 추천드릴게요:

---

## ✅ 현재 스타일
```swift
ReadTextFileAutoEncoding.swift
```
- ✔️ 직관적이고 함수명을 그대로 따름
- ❌ 파일명이 너무 구체적이면 나중에 확장 시 애매해질 수 있음

---

## 📦 추천 파일 이름 (확장성 고려)

### 1. **TextFileIO.swift**
- 🔹 `readTextFileAutoEncoding`, `writeTextFile(...)` 같이 IO 관련 유틸 넣기에 좋음
- ✅ 다수의 텍스트 입출력 함수가 생길 때 자연스럽게 확장 가능

### 2. **TextFileReader.swift**
- 🔹 읽기(read) 기능에만 초점을 둘 경우
- ✅ `read`, `detectEncoding`, `previewText(...)` 등을 묶기 좋음

### 3. **FileEncodingUtils.swift**
- 🔹 인코딩 감지 중심 유틸리티일 경우
- ✅ `detectEncoding(...)`, `suggestEncoding(...)` 등과 함께 사용 가능

### 4. **ReadText.swift** *(당신의 스타일)*
- 🔹 심플하고 함수명과 대응됨
- ✅ 작은 프로젝트나 빠르게 쓰기엔 간결함
- ❌ 확장에 조금 불리 (write나 인코딩 목록 등 기능 추가 시 의미가 좁음)

---

## ✍️ 제 개인적 추천

> 확장성을 고려한다면 `TextFileIO.swift` 또는 `TextFileReader.swift`  
> 함수 하나만 있고 작게 쓰는 용도라면 `ReadText.swift` 도 OK입니다.

---

### 🔧 예: `TextFileIO.swift` 안에 이런 코드가 들어갈 수 있음

```swift
func readTextFileAutoEncoding(...) -> String?
func writeTextFile(_ text: String, to url: URL, encoding: String.Encoding) -> Bool
func detectEncoding(of url: URL) -> String.Encoding?
```

---

필요하시면 모듈 구조에 맞게 파일 분리/통합 설계도 도와드릴게요!
