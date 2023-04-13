
//
//  Created by Shivanshu Verma on 10/01/23.
//

import UIKit
import CoreImage.CIFilterBuiltins

// MARK: - called QR generate method like....
if let qr = generateQRCode("My demo code.",
                           logo: UIImage(named: "myImageName")!,
                           width: 140, height: 46) {
    qrImageView.image = qr
}

// MARK: -
///  function return the QR Code image with  input information
/// - Parameters:
///   - message: message what you want write in QR Code
///   - logo:  passs the image to add in the center of the QR
///   - width: size of the logo
///   - height: height of the logo
/// - Returns: UIImage type image
func generateQRCode(_ message: String, logo: UIImage, width: Int, height: Int) -> UIImage? {
    let messageData = message.data(using: String.Encoding.ascii)
    /// The CIFilter class produces a CIImage object as output.
    guard let qrCodeGeneratorFilter = CIFilter(name: "CIQRCodeGenerator")  else {  return nil  }
    /// writing the message in QR code
    qrCodeGeneratorFilter.setValue(messageData, forKey: "inputMessage")
    /// adding correction level ratio of the generated QR
    qrCodeGeneratorFilter.setValue("Q", forKey: "inputCorrectionLevel")
    
    let qrTransform = CGAffineTransform(scaleX: 10, y: 10)
    guard
        let logoCGImage = logo.cgImage,
        let qrCIImage = qrCodeGeneratorFilter.outputImage?.transformed(by: qrTransform),
        let fQRImage = qrCIImage.addCenterImage(with: CIImage(cgImage: logoCGImage), width: width, height: height)
    else { return nil }
    return UIImage(ciImage: fQRImage)
}
// MARK: - CIImage extension
extension CIImage {
    /// Combine the QR image with the given centere image  with width & height.
    func addCenterImage(with centerImage: CIImage, width: Int, height: Int) -> CIImage? {
        guard let centerLogoImageFilter = CIFilter(name: "CISourceOverCompositing") else { return nil }
        guard let centerLogoResizeImageFilter = CIFilter(name:"CILanczosScaleTransform") else { return nil }
        /// Desired output size
        let centerLogoImageNewSize = CGSize(width: width, height: height)
        /// Compute scale and corrective aspect ratio
        let scale = centerLogoImageNewSize.height / (centerImage.extent.size.height)
        let aspectRatio = centerLogoImageNewSize.width / ((centerImage.extent.size.width) * scale)
        /// Apply resizing on `centerImage`
        centerLogoResizeImageFilter.setValue(centerImage, forKey: kCIInputImageKey)
        centerLogoResizeImageFilter.setValue(scale, forKey: kCIInputScaleKey)
        centerLogoResizeImageFilter.setValue(aspectRatio, forKey: kCIInputAspectRatioKey)
        
        guard let newResizeImage = centerLogoResizeImageFilter.outputImage else { return nil }
        
        /// getting center of the `newResizeImage`
        let centerTransform = CGAffineTransform(
            translationX: extent.midX - (newResizeImage.extent.size.width / 2),
            y: extent.midY - (newResizeImage.extent.size.height / 2))
        
        /// combine  the `newResizeImage` image with `QR Image` (self)
        centerLogoImageFilter.setValue(newResizeImage.transformed(by: centerTransform), forKey: kCIInputImageKey)
        centerLogoImageFilter.setValue(self, forKey: kCIInputBackgroundImageKey)
        
        guard let newCIImage = centerLogoImageFilter.outputImage else { return nil }
        return newCIImage
    }
}
