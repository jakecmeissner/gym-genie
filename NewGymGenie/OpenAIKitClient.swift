//
//  OpenAIKitClient.swift
//  NewGymGenie
//
//  Created by Jake Meissner on 4/28/23.
//


import Foundation
import AsyncHTTPClient
import NIO
import OpenAIKit

class OpenAIKitClient {
    let apiKey: String = "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"
    let organization: String = "org-meV4TygEf8DaJtFAE9BAwo9e"

    private let httpClient: HTTPClient
    let openAIClient: OpenAIKit.Client

    init() {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
        
        let configuration = Configuration(apiKey: apiKey, organization: organization)
        openAIClient = OpenAIKit.Client(httpClient: httpClient, configuration: configuration)
    }

    deinit {
        try? httpClient.syncShutdown()
    }
}




