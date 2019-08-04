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

  // MARK: - Properties

  var currentImage: UIImage!
  var context: CIContext! // this is the context that handles rendering - create a context is expensive, so don't be creating one each time.
  var currentFilter: CIFilter! // this will save whatever filter the user has activated.

  // MARK: - View Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Instafilter (YACIFP)"
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))

    // Filtering
    context = CIContext() // creates a default core image context
    currentFilter = CIFilter(name: "CISepiaTone") // creates an example filter that will apply a sepia tone to images
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
      let ac = UIAlertController(title: "No Image!", message: "There is any image to save, add one and start adding filters to it before save", preferredStyle: .alert)
      ac.addAction(UIAlertAction(title: "Ok", style: .default))
      present(ac, animated: true)
      return
    }

    UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
  }

  @IBAction func intensitySliderValueChanged(_ sender: UISlider) {
    applyProcessing()
  }

  // MARK: - Methods

  @objc func importPicture() {
    let picker = UIImagePickerController()
    picker.allowsEditing = true
    picker.delegate = self
    present(picker, animated: true)
  }

  func applyProcessing() {
    let inputKeys = currentFilter.inputKeys

    if inputKeys.contains(kCIInputIntensityKey) {
      currentFilter.setValue(intensitySlider.value, forKey: kCIInputIntensityKey)
    }

    if inputKeys.contains(kCIInputRadiusKey) {
      currentFilter.setValue(intensitySlider.value * 200, forKey: kCIInputRadiusKey)
    }

    if inputKeys.contains(kCIInputScaleKey) {
      currentFilter.setValue(intensitySlider.value * 10, forKey: kCIInputScaleKey)
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
  }

  func setFilter(action: UIAlertAction) {
    // make sure we have a valid image before continuing!
    guard currentImage != nil else { return }

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
}

