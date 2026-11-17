
import UIKit

class ProfileViewController: UIViewController {

    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    private let roleLabel = UILabel()
    private let logoutButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()

        setupScreen()
        setupUI()
    }

    private func setupScreen() {
        view.backgroundColor = .systemGroupedBackground
        title = "My Profile"
    }

    private func setupUI() {

        nameLabel.text = "Investigator"
        emailLabel.text = "investigator@example.com"
        roleLabel.text = "Role: Investigator"

        nameLabel.font = .boldSystemFont(ofSize: 22)
        emailLabel.font = .systemFont(ofSize: 16)
        roleLabel.font = .systemFont(ofSize: 16)

        let profileStack = UIStackView(
            arrangedSubviews: [
                nameLabel,
                emailLabel,
                roleLabel
            ]
        )

        profileStack.axis = .vertical
        profileStack.spacing = 15
        profileStack.alignment = .center

        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.backgroundColor = .systemRed
        logoutButton.setTitleColor(.white, for: .normal)
        logoutButton.layer.cornerRadius = 10
        logoutButton.addTarget(
            self,
            action: #selector(logoutTapped),
            for: .touchUpInside
        )

        let mainStack = UIStackView(
            arrangedSubviews: [
                profileStack,
                logoutButton
            ]
        )

        mainStack.axis = .vertical
        mainStack.spacing = 40
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 50
            ),
            mainStack.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 25
            ),
            mainStack.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -25
            ),
            logoutButton.heightAnchor.constraint(
                equalToConstant: 50
            )
        ])
    }

    @objc private func logoutTapped() {

        let alert = UIAlertController(
            title: "Logout",
            message: "Are you sure you want to logout?",
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(title: "Cancel", style: .cancel)
        )

        alert.addAction(
            UIAlertAction(title: "Logout", style: .destructive) {
                _ in

                self.navigationController?.dismiss(
                    animated: true
                )
            }
        )

        present(alert, animated: true)
    }
}
