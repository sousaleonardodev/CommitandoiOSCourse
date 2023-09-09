//

import Foundation
import RestaurantDomain

final class RestaurantListViewModel {
	typealias Observer<T> = (T) -> Void

	private let service: RestaurantLoader

	var onLoadingState: Observer<Bool>?
	var onRestaurantItem: Observer<[RestaurantItem]>?

	init(service: RestaurantLoader) {
		self.service = service
	}

	func loadService() {
		onLoadingState?(true)
		service.load { [weak self] result in
			self?.onLoadingState?(false)

			switch result {
			case let .success(items):
				self?.onRestaurantItem?(items)
			case let .failure(error):
				break
			}
		}
	}
}
