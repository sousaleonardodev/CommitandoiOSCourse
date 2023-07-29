//

import XCTest
@testable import RestaurantDomain

final class RestaurantDomainTests: XCTestCase {

	func testInitializerRestaurantLoaderAndValidateURLRequest() throws {
		let (sut, client, requestURL) = try makeSUT()
		
		sut.load { _ in }

		XCTAssertEqual([requestURL], client.urlRequests)
	}

	func testRestaurantRequestWithConectivityError() throws {
		let (sut, client, requestURL) = try makeSUT()

		let expect = XCTestExpectation(description: "request expectation")
		var returnedState: RemoteRestaurantLoader.Error?


		sut.load { state in
			returnedState = state
			expect.fulfill()
		}

		wait(for: [expect], timeout: 1)

		XCTAssertEqual([requestURL], client.urlRequests)
		XCTAssertEqual(returnedState, .connectivity)
	}

	func testRestaurantRequestWithInvalidData() throws {
		let (sut, client, requestURL) = try makeSUT()

		let expect = XCTestExpectation(description: "request expectation")
		var returnedState: RemoteRestaurantLoader.Error?

		client.stateHandler = .success((Data(), HTTPURLResponse()))
		sut.load { state in
			returnedState = state
			expect.fulfill()
		}

		wait(for: [expect], timeout: 1)

		XCTAssertEqual([requestURL], client.urlRequests)
		XCTAssertEqual(returnedState, .invalidData)
	}

	private func makeSUT() throws -> (sut: RemoteRestaurantLoader, client: NetworkClientSpy, requestURL: URL) {
		let requestURL = try XCTUnwrap(URL(string: "https://comintando.com.br"))
		let client = NetworkClientSpy()
		let sut = RemoteRestaurantLoader(url: requestURL, networkClient: client)

		return (sut, client, requestURL)
	}
}

final class NetworkClientSpy: NetworkClient {
	private(set) var urlRequests: [URL] = []
	var stateHandler: NetworkResult?

	func request(from url: URL, completion: @escaping (NetworkResult) -> Void) {
		urlRequests.append(url)
		completion(stateHandler ?? .failure(anyError()))
	}

	private func anyError() -> Error {
		NSError(domain: "Any error", code: -1)
	}
}
