//

import XCTest
import RestaurantDomain
@testable import RestaurantUI

final class RestaurantUITests: XCTestCase {

	func testInitDoesntLoad() {
		let service = RestaurantLoaderSpy()
		let sut = RestaurantListViewController(service: service)

		XCTAssertEqual(sut.restaurants.count, 0)
		XCTAssertEqual(service.loadCount, 0)
	}

	func testViewControllerDidCalledLoad() {
		let service = RestaurantLoaderSpy()
		let sut = RestaurantListViewController(service: service)

		sut.loadViewIfNeeded()

		XCTAssertEqual(sut.restaurants.count, 0)
		XCTAssertEqual(service.loadCount, 1)
	}
}

final class RestaurantLoaderSpy: RestaurantLoader {
	private(set) var loadCount = 0
	func load(completion: @escaping (RestaurantResult) -> Void) {
		loadCount += 1
	}
}
