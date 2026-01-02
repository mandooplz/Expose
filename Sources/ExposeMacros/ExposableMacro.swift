//
//  ExposableMacro.swift
//  Expose
//
//  Created by 김민우 on 1/3/26.
//


import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder
import SwiftCompilerPlugin


public struct ExposableMacro: MemberMacro, ExtensionMacro {
    // ExtensionMacro: NewExposable 프로토콜 채택
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
        providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
        conformingTo protocols: [SwiftSyntax.TypeSyntax],
        in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
            // iOS 17 이상에서만 Observation.Observable을 채택하도록 생성
                let observationExtension = try ExtensionDeclSyntax("""
                @available(iOS 17.0, *)
                extension \(type.trimmed): NewExposableObject {}
                """)

                // 모든 버전에서 ObservableObject를 채택하도록 생성
                let legacyExtension = try ExtensionDeclSyntax("""
                extension \(type.trimmed): Combine.ObservableObject {}
                """)

                return [observationExtension, legacyExtension]
    }
    
    
    // MemberMacro: registrar 프로퍼티 주입
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        return [
            // 1. iOS 17 이상에서만 유효한 registrar
            """
            @available(iOS 17.0, *)
            @ObservationIgnored
            public let registrar = ObservationRegistrar()
            """,
            // 2. 모든 버전에서 필요한 Combine 퍼블리셔 (iOS 13+)
            "public let objectWillChange = Combine.ObservableObjectPublisher()"
        ]
    }
}
