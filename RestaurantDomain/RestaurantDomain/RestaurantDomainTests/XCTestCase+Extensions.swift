//

import Foundation
import XCTest

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
}
