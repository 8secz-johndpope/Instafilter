//
//  ViewController.swift
//  Instafilter
//
//  Created by Juan Francisco Dorado Torres on 8/3/19.
//  Copyright © 2019 Juan Francisco Dorado Torres. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  // MARK: - Outlets

  @IBOutlet var imageView: UIImageView!
  @IBOutlet var intensitySlider: UISlider!

  // MARK: - Properties

  var currentImage: UIImage!

  // MARK: - View Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Instafilter (YACIFP)"
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))
  }

  // MARK: - Actions

  @IBAction func changeFilterButtonTapped(_ sender: UIButton) {

  }

  @IBAction func saveButtonTapped(_ sender: UIButton) {

  }

  @IBAction func intensitySliderValueChanged(_ sender: UISlider) {

  }

  // MARK: - Methods

  @objc func importPicture() {
    let picker = UIImagePickerController()
    picker.allowsEditing = true
    picker.delegate = self
    present(picker, animated: true)
  }
}

// MARK: - Image Picker Controller Delegate

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    guard let image = info[.editedImage] as? UIImage else { return }
    dismiss(animated: true)

    currentImage = image
  }
}

