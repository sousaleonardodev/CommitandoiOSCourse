//

import UIKit

public protocol ViewCodeHelper {
	func buildHierarchy()
	func setupConstraints()
	func setupAdditionalConfiguration()
	func setupView()
}

public extension ViewCodeHelper {
	func setupView() {
		buildHierarchy()
		setupConstraints()
		setupAdditionalConfiguration()
	}

	func setupAdditionalConfiguration() {}
}

final class RestaurantItemCell: UITableViewCell {
	private(set) lazy var hStack = setupStackView(axis: .horizontal, spacing: 16, aligment: .center)
	private(set) lazy var vStack = setupStackView(axis: .vertical, spacing: 4, aligment: .leading)
	private(set) lazy var hRatingStack = setupStackView(axis: .horizontal, spacing: 0, aligment: .fill)

	private(set) lazy var mapImage = setupImage("map")
	private(set) lazy var title = setupLabel(font: .preferredFont(forTextStyle: .title2))
	private(set) lazy var location = setupLabel(font: .preferredFont(forTextStyle: .body))
	private(set) lazy var distance = setupLabel(font: .preferredFont(forTextStyle: .body))
	private(set) lazy var parasols = setupLabel(font: .preferredFont(forTextStyle: .body))
	private(set) lazy var ratings: [UIImageView] = renderImageCollection()

	private func setupLabel(font: UIFont, textColor: UIColor = .black) -> UILabel {
		let label = UILabel()
		label.font = font
		label.translatesAutoresizingMaskIntoConstraints = false

		return label
	}

	private func setupStackView(axis: NSLayoutConstraint.Axis, spacing: CGFloat, aligment: UIStackView.Alignment) -> UIStackView {
		let stack = UIStackView()

		stack.axis = axis
		stack.spacing = spacing
		stack.alignment = aligment
		stack.translatesAutoresizingMaskIntoConstraints = false

		return stack
	}

	private func setupImage(_ systemName: String) -> UIImageView {
		let imageView = UIImageView()
		imageView.image = UIImage(systemName: systemName)
		imageView.translatesAutoresizingMaskIntoConstraints = false

		return imageView
	}

	private func renderImageCollection() -> [UIImageView] {
		var images = [UIImageView]()

		for _ in 1...5 {
			images.append(setupImage("star"))
		}
		return images
	}
}
