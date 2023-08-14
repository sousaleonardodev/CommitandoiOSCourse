//

import Foundation
import XCTest
import RestaurantDomain

extension XCTestCase {
	func trackForMemoryLeaks(
		_ instance: AnyObject,
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		addTeardownBlock { [weak instance] in
			XCTAssertNil(instance, "The instance should be dealloced. Possible Memory leak.", file: file, line: line)
		}
	}

	func restaurantList() -> [RestaurantItem] {
		[
			.init(id: UUID(), name: "name", location: "location", distance: 1.0, ratings: 5, parasols: 11),
			.init(id: UUID(), name: "name1", location: "location1", distance: 10.2, ratings: 2, parasols: 10),
			.init(id: UUID(), name: "name2", location: "location2", distance: 20.5, ratings: 3, parasols: 9),
			.init(id: UUID(), name: "name3", location: "location3", distance: 100.8, ratings: 1, parasols: 5)
		]
	}
}
