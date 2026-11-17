
import UIKit

class CaseDetailViewController: UIViewController {

    var caseDetails: CaseModel!

    private let detailsLabel = UILabel()
    private let evidenceButton = UIButton(type: .system)
    private let historyButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()

        setupScreen()
        setupUI()
        displayCaseDetails()
    }

    private func setupScreen() {
        view.backgroundColor = .systemGroupedBackground
        title = "Case Details"
    }

    private func setupUI() {

        detailsLabel.numberOfLines = 0
        detailsLabel.font = .systemFont(ofSize: 16)
        detailsLabel.backgroundColor = .secondarySystemGroupedBackground
        detailsLabel.layer.cornerRadius = 12
        detailsLabel.clipsToBounds = true

        evidenceButton.setTitle("View Case Evidence", for: .normal)
        evidenceButton.backgroundColor = .systemBlue
        evidenceButton.setTitleColor(.white, for: .normal)
        evidenceButton.layer.cornerRadius = 10
        evidenceButton.addTarget(
            self,
            action: #selector(openEvidence),
            for: .touchUpInside
        )

        historyButton.setTitle("View Audit History", for: .normal)
        historyButton.backgroundColor = .systemGreen
        historyButton.setTitleColor(.white, for: .normal)
        historyButton.layer.cornerRadius = 10
        historyButton.addTarget(
            self,
            action: #selector(openHistory),
            for: .touchUpInside
        )

        let stackView = UIStackView(
            arrangedSubviews: [
                detailsLabel,
                evidenceButton,
                historyButton
            ]
        )

        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false

        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        evidenceButton.translatesAutoresizingMaskIntoConstraints = false
        historyButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 25
            ),
            stackView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20
            ),
            stackView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -20
            ),
            evidenceButton.heightAnchor.constraint(equalToConstant: 50),
            historyButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func displayCaseDetails() {

        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        detailsLabel.text = """
        Case Number:
        \(caseDetails.caseNumber)

        FIR Number:
        \(caseDetails.firNumber)

        Case Title:
        \(caseDetails.caseTitle)

        Crime Type:
        \(caseDetails.crimeType)

        Description:
        \(caseDetails.caseDescription)

        Incident Date:
        \(formatter.string(from: caseDetails.incidentDate))

        Status:
        \(caseDetails.status)
        """
    }

    @objc private func openEvidence() {
        let evidenceVC = EvidenceViewController()
        evidenceVC.caseNumber = caseDetails.caseNumber

        navigationController?.pushViewController(
            evidenceVC,
            animated: true
        )
    }

    @objc private func openHistory() {
        let historyVC = EvidenceHistoryViewController()
        historyVC.caseNumber = caseDetails.caseNumber

        navigationController?.pushViewController(
            historyVC,
            animated: true
        )
    }
}
