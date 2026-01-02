//
//  ExposableObject.swift
//  Expose
//
//  Created by 김민우 on 1/2/26.
//


import Observation


@available(iOS 15.0, *)
public protocol ExposableObject: AnyObject, ObservableObject where Self.ObjectWillChangePublisher == ObservableObjectPublisher  {
    
    @available(iOS 17.0, *)
    var registrar: ObservationRegistrar { get }
}



extension ExposableObject {
    /// iOS 17+ 전용: Observation 추적을 위한 브릿지 메서드
    @available(iOS 17.0, *)
    func trackAccess<T>(_ keyPath: ReferenceWritableKeyPath<Self, T>) {
        // 1. 실제 Observable을 준수하는지 확인 (매크로가 주입함)
        guard let observable = self as? any Observation.Observable else { return }
        
        // 2. 내부 함수를 통해 실존 타입(any)을 구체 타입(S)으로 엽니다.
        func open<S: Observation.Observable>(_ subject: S) {
            registrar.access(subject, keyPath: keyPath as! ReferenceWritableKeyPath<S, T>)
        }
        open(observable)
    }

    /// iOS 17+ 전용: Observation 변경 알림을 위한 브릿지 메서드
    @available(iOS 17.0, *)
    func trackMutation<T>(_ keyPath: ReferenceWritableKeyPath<Self, T>, action: () -> Void) {
        guard let observable = self as? any Observation.Observable else {
            action()
            return
        }
        
        func open<S: Observation.Observable>(_ subject: S) {
            registrar.withMutation(of: subject, keyPath: keyPath as! ReferenceWritableKeyPath<S, T>) {
                action()
            }
        }
        open(observable)
    }
}
