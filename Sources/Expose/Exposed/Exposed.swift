//
//  Exposed.swift
//  Expose
//
//  Created by 김민우 on 1/2/26.
//


import RxCocoa
@_exported import Combine


@available(iOS 15.0, *)
@propertyWrapper
public struct Exposed<T> {
    private var relay: BehaviorRelay<T>

    public init(wrappedValue: T) {
        self.relay = BehaviorRelay(value: wrappedValue)
    }

    /// $ 기호를 통해 Rx/Combine 스트림에 접근
    public var projectedValue: ExposedStream<T> {
        ExposedStream(relay: relay)
    }

    /// 핵심: Observation 통합 서브스크립트
    /// EnclosingSelf가 NewExposable을 채택하고 있어야 registrar에 접근 가능합니다.
    public static subscript<EnclosingSelf: ExposableObject> (
        _enclosingInstance instance: EnclosingSelf,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingSelf, T>,
        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Exposed<T>>
    ) -> T {
        get {
            if #available(iOS 17.0, *) {
                instance.trackAccess(wrappedKeyPath)
            }
            
            return instance[keyPath: storageKeyPath].relay.value
        }
        set {
            // 2. Combine 알림 (iOS 15+ 공통 지원)
            instance.objectWillChange.send()

            // 3. iOS 17 이상: Observation 방식 알림
            if #available(iOS 17.0, *) {
                instance.trackMutation(wrappedKeyPath) {
                    instance[keyPath: storageKeyPath].relay.accept(newValue)
                }
            }
            
            // 4. Fallback: iOS 15/16 또는 캐스팅 실패 시 기본 업데이트
            instance[keyPath: storageKeyPath].relay.accept(newValue)
        }
    }

    /// 값 타입(Struct)에서의 사용을 제한하고 클래스 멤버로 유도
    @available(*, unavailable, message: "사용 불가")
    public var wrappedValue: T {
        get { fatalError() }
        set { fatalError() }
    }
}
