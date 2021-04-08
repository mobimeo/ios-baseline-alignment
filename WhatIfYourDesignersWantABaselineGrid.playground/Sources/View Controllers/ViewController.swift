import UIKit

public class ViewController: UIViewController {

    var grid: GridView!
    var label: LabelView!

    override public func viewDidLoad() {
        view.backgroundColor = .white

        let gridUnit: CGFloat = 8.0

        grid = createGridView()
        grid.translatesAutoresizingMaskIntoConstraints = false
        grid.gridUnit = gridUnit
        grid.backgroundColor = UIColor.systemGray5
        view.addSubview(grid)

        label = createLabelView()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.gridUnit = gridUnit
        updateLabelText()
        view.addSubview(label)

        let topAnchor = view.safeAreaLayoutGuide.topAnchor

        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: label.leadingAnchor, constant: -16),
            view.trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: 16),
            topAnchor.constraint(equalTo: label.topAnchor, constant: -16),
            grid.topAnchor.constraint(equalTo: label.topAnchor),
            grid.bottomAnchor.constraint(equalTo: label.bottomAnchor),
            grid.leadingAnchor.constraint(equalTo: label.leadingAnchor),
            grid.trailingAnchor.constraint(equalTo: label.trailingAnchor)])

        let button = UIButton(type: .roundedRect)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Cycle Content Size Category", for: .normal)
        button.addTarget(nil, action: #selector(cycleContentSizeCategory), for: .primaryActionTriggered)

        let button2 = UIButton(type: .roundedRect)
        button2.translatesAutoresizingMaskIntoConstraints = false
        button2.setTitle("Cycle Text Style", for: .normal)
        button2.addTarget(nil, action: #selector(cycleTextStyle), for: .primaryActionTriggered)

        view.addSubview(button)
        view.addSubview(button2)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: button.centerXAnchor, constant: 0),
            button.widthAnchor.constraint(equalToConstant: 200),
            button.bottomAnchor.constraint(equalTo: button2.topAnchor, constant: -20),
            label.centerXAnchor.constraint(equalTo: button2.centerXAnchor, constant: 0),
            button2.widthAnchor.constraint(equalToConstant: 200),
            view.bottomAnchor.constraint(equalTo: button2.bottomAnchor, constant: 60),
            ])
    }

    @IBAction func cycleContentSizeCategory() {
        let contentSizeCategories = UIContentSizeCategory.specifiedContentSizeCategories

        guard let index = contentSizeCategories.firstIndex(of: label.contentSizeCategory) else {
            return
        }
        label.contentSizeCategory = contentSizeCategories[(index + 1) % contentSizeCategories.count]
        updateLabelText()
    }

    @IBAction func cycleTextStyle() {
        let textStyles = UIFont.TextStyle.textStyles

        guard let index = textStyles.firstIndex(of: label.textStyle) else {
            return
        }
        label.textStyle = textStyles[(index + 1) % textStyles.count]
        updateLabelText()
    }

    private func updateLabelText() {
        label.text = "\(label.textStyle.rawValue)\n\(label.contentSizeCategory.rawValue)"
    }
}
