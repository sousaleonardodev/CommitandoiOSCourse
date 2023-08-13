//

import XCTest
import RestaurantDomain

final class RestaurantDomainTests: XCTestCase {
	func testInitializerRestaurantLoaderAndValidateURLRequest() throws {
		let (sut, client, requestURL) = try makeSUT()
		
		sut.load { _ in }

		XCTAssertEqual([requestURL], client.urlRequests)
	}

	func testRestaurantRequestWithConectivityError() throws {
		let (sut, client, _) = try makeSUT()

		try assert(sut, completion: .failure(.connectivity)) {
			client.setupFailureCompletion()
		}
	}

	func testRestaurantRequestWithInvalidData() throws {
		let (sut, client, _) = try makeSUT()

		try assert(sut, completion: .failure(.invalidData)) {
			try client.setupSuccessCompletion()
		}
	}

	func testRestaurantRequestWithSuccessEmptyList() throws {
		let (sut, client, _) = try makeSUT()

		try assert(sut, completion: .success([RestaurantItem]())) {
			try client.setupSuccessCompletion(data: emptyListData())
		}
	}

	func testRestaurantRequestWithSuccessRestaurantList() throws {
		let (sut, client, _) = try makeSUT()

		let (model, json) = makeItem()
		let rootJSON = ["items": [json]]
		let returnData = try XCTUnwrap(JSONSerialization.data(withJSONObject: rootJSON))

		try assert(sut, completion: .success([model])) {
			try client.setupSuccessCompletion(data: returnData)
		}
	}

	func testRestaurantRequestWithSuccessWithInvalidStatusCode() throws {
		let (sut, client, _) = try makeSUT()

		try assert(sut, completion: .failure(.invalidData)) {
			let (_, json) = makeItem()
			let rootJSON = ["items": [json]]
			let returnData = try XCTUnwrap(JSONSerialization.data(withJSONObject: rootJSON))
			try client.setupSuccessCompletion(statusCode: 201, data: returnData)
		}
	}

	func testLoadNotReturnedAdterSUTDealloc() throws {
		let anyURL = try XCTUnwrap(URL(string: "hhttps://commitando.com.br"))
		let client = NetworkClientSpy()
		var sut: RemoteRestaurantLoader? = RemoteRestaurantLoader(url: anyURL, networkClient: client)

		var returnedResult: RemoteRestaurantLoader.RestaurantResult?
		sut?.load(completion: { result in
			returnedResult = result
		})

		sut = nil
		try client.setupSuccessCompletion()

		XCTAssertNil(returnedResult)
	}

	private func assert(
		_ sut: RemoteRestaurantLoader,
		completion result: RemoteRestaurantLoader.RestaurantResult?,
		when action: () throws -> Void,
		file: StaticString = #filePath,
		line: UInt = #line
	) throws {
		let expect = XCTestExpectation(description: "request expectation")
		var returnedResult: RemoteRestaurantLoader.RestaurantResult?

		sut.load { state in
			returnedResult = state
			expect.fulfill()
		}

		try action()

		wait(for: [expect], timeout: 1)

		XCTAssertEqual(returnedResult, result, file: file, line: line)
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
