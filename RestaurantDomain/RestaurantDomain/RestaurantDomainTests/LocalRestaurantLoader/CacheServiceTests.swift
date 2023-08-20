//

import XCTest
@testable import RestaurantDomain

final class CacheServiceTests: XCTestCase {

	func testSaveValue() {
		let sut = makeSUT()
		let items = restaurantList()
		let timestamp = Date()

		let returnedError = insert(sut, items: items, timestamp: timestamp)

		XCTAssertNil(returnedError)
	}

	func testSaveAndReturnLastValue() {
		let sut = makeSUT()
		let firstTimeItems = restaurantList()
		let firstTimeTimestamp = Date()
		let expectation = XCTestExpectation(description: "filemanager expectation")

		insert(sut, items: firstTimeItems, timestamp: firstTimeTimestamp)

		let secondTimeItems = restaurantList()
		let secondTimeTimestamp = Date()

		insert(sut, items: secondTimeItems, timestamp: secondTimeTimestamp)

		assert(sut, completion: .success(items: secondTimeItems, timestamp: secondTimeTimestamp))
	}

	func testSaveReturnErrorWithInvalidURL() {
		let invalidURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
		let sut = CacheService(managerURL: invalidURL)
		let items = restaurantList()

		let returnedError = insert(sut, items: items, timestamp: Date())

		XCTAssertNotNil(returnedError)
	}

	private func assert(
		_ sut: CacheClient,
		completion result: LoadResultState,
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		let expectation = XCTestExpectation(description: "assert expectation")

		sut.load { returnedResult in
			switch (result, returnedResult) {
			case (.empty, .empty), (.failure, .failure):
				break
			case let (.success(items: items, timestamp: timestamp), .success(items: returnedItems, timestamp: returnedTimestamp)):
				XCTAssertEqual(items, returnedItems, file: file, line: line)
				XCTAssertEqual(timestamp, returnedTimestamp, file: file, line: line)

			default:
				XCTFail("Expected: \(result), got: \(returnedResult)", file: file, line: line)
			}

			expectation.fulfill()
		}

		wait(for: [expectation], timeout: 0.5)
	}

	private func makeSUT() -> CacheClient {
		let path = type(of: self)
		let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appending(path: "\(path)")
		return CacheService(managerURL: url!)
	}

	@discardableResult
	private func insert(_ sut: CacheClient, items: [RestaurantItem], timestamp: Date) -> Error? {
		let expectation = XCTestExpectation(description: "filemanager wait")
		var returnedError: Error?


		sut.save(items, timestamp: timestamp) { error in
			returnedError = error
			expectation.fulfill()
		}

		wait(for: [expectation], timeout: 0.5)

		return returnedError
	}
}
