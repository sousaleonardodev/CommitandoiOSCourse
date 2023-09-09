//

import Foundation
import RestaurantDomain

final class RestaurantListviewModel {
	private let service: RestaurantLoader

	var onLoadingState: ((Bool) -> Void)?
	var onRestaurantItem: (([RestaurantItem]) -> Void)?

	init(service: RestaurantLoader) {
		self.service = service
	}

	func loadService() {
		onLoadingState?(true)
		service.load { [weak self] result in
			switch result {
			case let .success(items):
				self?.onRestaurantItem?(items)
			case let .failure(error):
				break
			}
			self?.onLoadingState?(false)
		}
	}
}
