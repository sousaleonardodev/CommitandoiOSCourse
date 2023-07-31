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

		try client.setupSuccessHandler()
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

		try client.setupSuccessHandler(data: emptyListData())

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

		try client.setupSuccessHandler(data: returnData)

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
	private var stateHandler: NetworkResult?

	func request(from url: URL, completion: @escaping (NetworkResult) -> Void) {
		urlRequests.append(url)
		completion(stateHandler ?? .failure(NetworkClientSpy.anyError()))
	}

	func setupSuccessHandler(statusCode: Int = 200, data: Data = Data()) throws {
		let url = try XCTUnwrap(URL(string: "https://comitando.com"))
		let response = try XCTUnwrap(HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil))

		stateHandler = .success((data, response))
	}

	func setupFailureHandler(error: Error = NetworkClientSpy.anyError()) {
		stateHandler = .failure(error)
	}

	static private func anyError() -> Error {
		NSError(domain: "Any error", code: -1)
	}
}
