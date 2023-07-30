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
		var returnedState: RemoteRestaurantLoader.RemoterestaurantResult?


		sut.load { state in
			returnedState = state
			expect.fulfill()
		}

		wait(for: [expect], timeout: 1)

		XCTAssertEqual([requestURL], client.urlRequests)
		XCTAssertEqual(returnedState, .failure(.connectivity))
	}

	func testRestaurantRequestWithInvalidData() throws {
		let (sut, client, requestURL) = try makeSUT()

		let expect = XCTestExpectation(description: "request expectation")
		var returnedState: RemoteRestaurantLoader.RemoterestaurantResult?

		client.stateHandler = .success((Data(), HTTPURLResponse()))
		sut.load { state in
			returnedState = state
			expect.fulfill()
		}

		wait(for: [expect], timeout: 1)

		XCTAssertEqual([requestURL], client.urlRequests)
		XCTAssertEqual(returnedState, .failure(.invalidData))
	}

	func testRestaurantRequestWithSuccessEmptyList() throws {
		let (sut, client, requestURL) = try makeSUT()

		let expect = XCTestExpectation(description: "request expectation")
		var returnedState: RemoteRestaurantLoader.RemoterestaurantResult?

		client.stateHandler = .success((emptyListData(), HTTPURLResponse()))
		sut.load { state in
			returnedState = state
			expect.fulfill()
		}

		wait(for: [expect], timeout: 1)

		XCTAssertEqual([requestURL], client.urlRequests)
		XCTAssertEqual(returnedState, .success([]))
	}

	func testRestaurantRequestWithSuccessRestaurantList() throws {
		let (sut, client, requestURL) = try makeSUT()

		let expect = XCTestExpectation(description: "request expectation")
		var returnedState: RemoteRestaurantLoader.RemoterestaurantResult?

		let (model, json) = makeItem()

		let rootJSON = ["items": [json]]
		let returnData = try XCTUnwrap(JSONSerialization.data(withJSONObject: rootJSON))

		client.stateHandler = .success((returnData, HTTPURLResponse()))

		sut.load { state in
			returnedState = state
			expect.fulfill()
		}

		wait(for: [expect], timeout: 1)

		XCTAssertEqual([requestURL], client.urlRequests)
		XCTAssertEqual(returnedState, .success([model]))
	}

	private func makeSUT() throws -> (sut: RemoteRestaurantLoader, client: NetworkClientSpy, requestURL: URL) {
		let requestURL = try XCTUnwrap(URL(string: "https://comintando.com.br"))
		let client = NetworkClientSpy()
		let sut = RemoteRestaurantLoader(url: requestURL, networkClient: client)

		return (sut, client, requestURL)
	}

	private func emptyListData() -> Data {
		Data("{ \"items\": [] }".utf8)
	}

	private func makeItem(
		id: UUID = UUID(),
		name: String = "name",
		location: String = "location",
		distance: Float = 0.5,
		ratings: Int = 5,
		parasols: Int = 20
	) -> (model: RestaurantItem, json: [String: Any]) {
		let model = RestaurantItem(
			id: id,
			name: name,
			location: location,
			distance: distance,
			ratings: ratings,
			parasols: parasols
		)

		let json: [String: Any] = [
			"id": id.uuidString,
			"name": name,
			"location": location,
			"distance": distance,
			"ratings": ratings,
			"parasols": parasols
		]

		return (model, json)
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
