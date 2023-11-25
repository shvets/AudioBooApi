//: [Previous](@previous)

import Foundation

import AsyncHTTPClient

let httpClient = HTTPClient(eventLoopGroupProvider: .singleton)

/// MARK: - Using Swift Concurrency
let request = HTTPClientRequest(url: "https://apple.com/")
let response = try await httpClient.execute(request, timeout: .seconds(30))
print("HTTP head", response)
if response.status == .ok {
    let body = try await response.body.collect(upTo: 1024 * 1024) // 1 MB
    // handle body
} else {
    // handle remote error
}


/// MARK: - Using SwiftNIO EventLoopFuture
httpClient.get(url: "https://apple.com/").whenComplete { result in
    switch result {
    case .failure(let error):
        print(error)
        // process error
    case .success(let response):
        if response.status == .ok {
            print("ok")
            // handle response
        } else {
            // handle remote error
        }
    }
}

