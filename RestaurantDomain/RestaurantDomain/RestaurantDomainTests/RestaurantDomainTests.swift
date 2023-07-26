//

import XCTest
@testable import RestaurantDomain

final class RestaurantDomainTests: XCTestCase {

	func testInitializerRestaurantLoaderAndValidateURLRequest() throws {
		let requestURL = try XCTUnwrap(URL(string: "https://comintando.com.br"))
		let client = NetworkClientSpy()

		let sut = RemoteRestaurantLoader(url: requestURL, networkClient: client)
		
		sut.load { _ in }

		XCTAssertEqual([requestURL], client.urlRequests)
	}

	func testRestaurantRequestWithError() throws {
		let requestURL = try XCTUnwrap(URL(string: "https://comintando.com.br"))
		let client = NetworkClientSpy()

		let expect = XCTestExpectation(description: "request expectation")
		var returnedError: Error?

		let sut = RemoteRestaurantLoader(url: requestURL, networkClient: client)

		sut.load { error in
			returnedError = error
			expect.fulfill()
		}

		wait(for: [expect], timeout: 1)

		XCTAssertEqual([requestURL], client.urlRequests)
		XCTAssertNotNil(returnedError)
	}
}

final class NetworkClientSpy: NetworkClient {
	private(set) var urlRequests: [URL] = []

	func request(from url: URL, completion: @escaping (Error) -> Void) {
		urlRequests.append(url)
		completion(anyError())
	}

	private func anyError() -> Error {
		NSError(domain: "Any error", code: -1)
	}
}
