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

		try client.setupFailureCompletion()
		
		wait(for: [expect], timeout: 1)

		XCTAssertEqual([requestURL], client.urlRequests)
		XCTAssertEqual(returnedState, .failure(.connectivity))
	}

	func testRestaurantRequestWithInvalidData() throws {
		let (sut, client, requestURL) = try makeSUT()

		let expect = XCTestExpectation(description: "request expectation")
		var returnedState: RemoteRestaurantLoader.RemoterestaurantResult?

		sut.load { state in
			returnedState = state
			expect.fulfill()
		}

		try client.setupSuccessCompletion()
		wait(for: [expect], timeout: 1)

		XCTAssertEqual([requestURL], client.urlRequests)
		XCTAssertEqual(returnedState, .failure(.invalidData))
	}

	func testRestaurantRequestWithSuccessEmptyList() throws {
		let (sut, client, requestURL) = try makeSUT()

		let expect = XCTestExpectation(description: "request expectation")
		var returnedState: RemoteRestaurantLoader.RemoterestaurantResult?

		sut.load { state in
			returnedState = state
			expect.fulfill()
		}

		try client.setupSuccessCompletion(data: emptyListData())

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

		sut.load { state in
			returnedState = state
			expect.fulfill()
		}

		try client.setupSuccessCompletion(data: returnData)

		wait(for: [expect], timeout: 1)

		XCTAssertEqual([requestURL], client.urlRequests)
		XCTAssertEqual(returnedState, .success([model]))
	}

	func testLoadNotReturnedAdterSUTDealloc() throws {
		let anyURL = try XCTUnwrap(URL(string: "hhttps://commitando.com.br"))
		let client = NetworkClientSpy()
		var sut: RemoteRestaurantLoader? = RemoteRestaurantLoader(url: anyURL, networkClient: client)

		var returnedResult: RemoteRestaurantLoader.RemoterestaurantResult?
		sut?.load(completion: { result in
			returnedResult = result
		})

		sut = nil
		try client.setupSuccessCompletion()

		XCTAssertNil(returnedResult)
	}

	func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
		addTeardownBlock { [weak instance] in
			XCTAssertNil(instance, "The instance should be dealloced. Possible Memory leak.", file: file, line: line)
		}
	}

	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) throws -> (sut: RemoteRestaurantLoader, client: NetworkClientSpy, requestURL: URL) {
		let requestURL = try XCTUnwrap(URL(string: "https://comintando.com.br"))
		let client = NetworkClientSpy()
		let sut = RemoteRestaurantLoader(url: requestURL, networkClient: client)

		trackForMemoryLeaks(client, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)

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
	private var completionHandler: ((NetworkResult) -> Void)?

	func request(from url: URL, completion: @escaping (NetworkResult) -> Void) {
		urlRequests.append(url)
		completionHandler = completion
	}

	func setupSuccessCompletion(statusCode: Int = 200, data: Data = Data()) throws {
		let response = try XCTUnwrap(HTTPURLResponse(url: urlRequests[0], statusCode: statusCode, httpVersion: nil, headerFields: nil))

		completionHandler?(.success((data, response)))
	}

	func setupFailureCompletion(error: Error = NetworkClientSpy.anyError()) {
		completionHandler?(.failure(error))
	}

	static private func anyError() -> Error {
		NSError(domain: "Any error", code: -1)
	}
}
