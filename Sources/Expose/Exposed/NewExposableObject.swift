//
//  NewExposableObject.swift
//  Expose
//
//  Created by 김민우 on 1/3/26.
//


import Observation
import Combine

@available(iOS 17.0, *)
public protocol NewExposableObject: ExposableObject, Observation.Observable {
    var registrar: ObservationRegistrar { get }
}
