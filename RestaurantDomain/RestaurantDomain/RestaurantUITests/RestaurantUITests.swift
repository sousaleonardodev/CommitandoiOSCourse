//

import XCTest
import RestaurantDomain
@testable import RestaurantUI

final class RestaurantUITests: XCTestCase {

	func testInitDoesntLoad() {
		let (sut, service) = makeSUT()

		XCTAssertEqual(sut.restaurants.count, 0)
		XCTAssertEqual(service.loadCount, 0)
	}

	func testViewControllerDidCalledLoad() {
		let (sut, service) = makeSUT()

		sut.loadViewIfNeeded()

		XCTAssertEqual(sut.restaurants.count, 0)
		XCTAssertEqual(service.loadCount, 1)
	}

	func testLoadWithReturnedData() {
		let (sut, service) = makeSUT()

		sut.loadViewIfNeeded()
		service.completionSuccess(.success(restaurantList()))

		XCTAssertEqual(service.loadCount, 1)
		XCTAssertEqual(sut.restaurants.count, 4)
	}

	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RestaurantListViewController, service: RestaurantLoaderSpy) {
		let service = RestaurantLoaderSpy()
		let sut = RestaurantListViewController(service: service)

		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(service, file: file, line: line)

		return (sut, service)
	}
}

final class RestaurantLoaderSpy: RestaurantLoader {

	private(set) var loadCount = 0
	private(set) var successCompletionHandler: ((RestaurantResult) -> Void)?
	func load(completion: @escaping (RestaurantResult) -> Void) {
		loadCount += 1
		successCompletionHandler = completion
	}

	func completionSuccess(_ result: RestaurantResult) {
		successCompletionHandler?(result)
	}
}
