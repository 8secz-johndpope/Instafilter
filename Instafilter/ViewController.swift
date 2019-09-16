//
//  ViewController.swift
//  Instafilter
//
//  Created by Juan Francisco Dorado Torres on 8/3/19.
//  Copyright © 2019 Juan Francisco Dorado Torres. All rights reserved.
//

import UIKit
import CoreImage

class ViewController: UIViewController {

  // MARK: - Outlets

  @IBOutlet var imageView: UIImageView!
  @IBOutlet var intensitySlider: UISlider!
  @IBOutlet var radiusSlider: UISlider!
  @IBOutlet var scaleSlider: UISlider!
  @IBOutlet var intensityStackView: UIStackView!
  @IBOutlet var radiusStackView: UIStackView!
  @IBOutlet var scaleStackView: UIStackView!

  // MARK: - Properties

  var currentImage: UIImage!
  var context: CIContext! // this is the context that handles rendering - create a context is expensive, so don't be creating one each time.
  var currentFilter: CIFilter! // this will save whatever filter the user has activated.

  // MARK: - View Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Instafilter (YACIFP)"
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))
    imageView.alpha = 0.0

    // Filtering
    context = CIContext() // creates a default core image context
    currentFilter = CIFilter(name: "CISepiaTone") // creates an example filter that will apply a sepia tone to images

    setupView()
  }

  // MARK: - Actions

  @IBAction func changeFilterButtonTapped(_ sender: UIButton) {
    let ac = UIAlertController(title: "Choose filter", message: nil, preferredStyle: .actionSheet)
    ac.addAction(UIAlertAction(title: "CIBumpDistortion", style: .default, handler: setFilter))
    ac.addAction(UIAlertAction(title: "CIGaussianBlur", style: .default, handler: setFilter))
    ac.addAction(UIAlertAction(title: "CIPixellate", style: .default, handler: setFilter))
    ac.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: setFilter))
    ac.addAction(UIAlertAction(title: "CITwirlDistortion", style: .default, handler: setFilter))
    ac.addAction(UIAlertAction(title: "CIUnsharpMask", style: .default, handler: setFilter))
    ac.addAction(UIAlertAction(title: "CIVignette", style: .default, handler: setFilter))
    ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    present(ac, animated: true)
  }

  @IBAction func saveButtonTapped(_ sender: UIButton) {
    guard let image = imageView.image else {
      showNoImageErrorAlert()
      return
    }

    UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
  }

  @IBAction func sliderValueChanged(_ sender: UISlider) {
    applyProcessing()
  }

  // MARK: - Methods

  func setupView() {
    intensityStackView.isHidden = true
    radiusStackView.isHidden = true
    scaleStackView.isHidden = true

    intensitySlider.isEnabled = false
    radiusSlider.isEnabled = false
    scaleSlider.isEnabled = false
  }

  @objc func importPicture() {
    UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: { [weak self] in
      self?.imageView.alpha = 0.0
    }, completion: nil)
    let picker = UIImagePickerController()
    picker.allowsEditing = true
    picker.delegate = self
    present(picker, animated: true)
  }

  func applyProcessing() {
    let inputKeys = currentFilter.inputKeys
    title = currentFilter.name

    if inputKeys.contains(kCIInputIntensityKey) {
      intensityStackView.isHidden = false
      intensitySlider.isEnabled = true
      currentFilter.setValue(intensitySlider.value, forKey: kCIInputIntensityKey)
    } else {
      intensityStackView.isHidden = true
      intensitySlider.isEnabled = false
    }

    if inputKeys.contains(kCIInputRadiusKey) {
      radiusStackView.isHidden = false
      radiusSlider.isEnabled = true
      currentFilter.setValue(radiusSlider.value, forKey: kCIInputRadiusKey)
    } else {
      radiusStackView.isHidden = true
      radiusSlider.isEnabled = false
    }

    if inputKeys.contains(kCIInputScaleKey) {
      scaleStackView.isHidden = false
      scaleSlider.isEnabled = true
      currentFilter.setValue(scaleSlider.value, forKey: kCIInputScaleKey)
    } else {
      scaleStackView.isHidden = true
      scaleSlider.isEnabled = false
    }

    if inputKeys.contains(kCIInputCenterKey) {
      currentFilter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey: kCIInputCenterKey)
    }

    // creates a new data, 'CGImage' from the output image of the current filter
    // we need specify which part of the image we want to render, with 'image.extent' means 'all of it'
    // until this method is called, no actual processing is done.
    // it returns an optional 'CGImage' so check and unwrap with 'if let'
    if let cgimg = context.createCGImage(currentFilter.outputImage!, from: currentFilter.outputImage!.extent) {
      let processedImage = UIImage(cgImage: cgimg) // it creates a new 'UIImage' from the 'CGImage'
      imageView.image = processedImage // assign the 'UIImage' to our 'UIImageView'
    }

    if imageView.alpha.isZero {
      UIView.animate(withDuration: 2.0, delay: 5.0, options: [], animations: { [weak self] in
        self?.imageView.alpha = 1.0
        }, completion: nil)
    }
  }

  func setFilter(action: UIAlertAction) {
    // make sure we have a valid image before continuing!
    guard currentImage != nil else {
      showNoImageErrorAlert()
      return
    }

    // safely read the alert action's title
    guard let actionTitle = action.title else { return }

    currentFilter = CIFilter(name: actionTitle)

    let beginImage = CIImage(image: currentImage)
    currentFilter.setValue(beginImage, forKey: kCIInputImageKey)

    applyProcessing()
  }

  @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
    if let error = error {
      // we got back an error!
      let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
      ac.addAction(UIAlertAction(title: "OK", style: .default))
      present(ac, animated: true)
    } else {
      let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
      ac.addAction(UIAlertAction(title: "OK", style: .default))
      present(ac, animated: true)
    }
  }

  func showNoImageErrorAlert() {
    let ac = UIAlertController(title: "No Image!", message: "There is any image to save, add one and start adding filters to it before save", preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "Ok", style: .default))
    present(ac, animated: true)
  }
}

// MARK: - Image Picker Controller Delegate

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    guard let image = info[.editedImage] as? UIImage else { return }
    dismiss(animated: true)

    currentImage = image

    let beginImage = CIImage(image: currentImage) // this is the equivalent to 'UIImage' for 'CoreImage'
    currentFilter.setValue(beginImage, forKey: kCIInputImageKey) // send the result into the current core image filter

    applyProcessing()
  }

  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true)
    UIView.animate(withDuration: 2.0, delay: 0, options: [], animations: { [weak self] in
      self?.imageView.alpha = 1.0
    }, completion: nil)
  }
}

