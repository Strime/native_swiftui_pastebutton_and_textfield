import Flutter
import UIKit
import SwiftUI
import UniformTypeIdentifiers

class TextFieldFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    private var channel: FlutterMethodChannel
    private var seed: [String: Any]
    
    init(messenger: FlutterBinaryMessenger, seed:[String: Any]) {
        self.messenger = messenger
        self.channel = FlutterMethodChannel(
            name: seed["widgetUUID"] as! String,
            binaryMessenger: messenger
        )
        
        // Enrichir le seed avec des valeurs par défaut pour le style Flutter
        var enrichedSeed = seed
        
        // Configurer les couleurs pour correspondre aux styles Flutter
        // La couleur de bordure par défaut pour Flutter (gris clair)
        enrichedSeed["borderColor"] = seed["borderColor"] as? String ?? "#E0E0E0"
        
        // La couleur de bordure en focus pour Flutter (généralement la couleur primaire)
        enrichedSeed["focusedBorderColor"] = seed["focusedBorderColor"] as? String ?? "#1976D2"
        
        // La couleur de fond par défaut pour Flutter
        enrichedSeed["backgroundColor"] = seed["backgroundColor"] as? String ?? "#FFFFFF"
        
        // La couleur de texte par défaut pour Flutter
        enrichedSeed["textColor"] = seed["textColor"] as? String ?? "#000000"
        
        // Le rayon des coins pour correspondre au style Flutter
        enrichedSeed["cornerRadius"] = seed["cornerRadius"] as? CGFloat ?? 8.0
        
        // La taille de police pour correspondre au style Flutter
        enrichedSeed["fontSize"] = seed["fontSize"] as? CGFloat ?? 14.0
        
        // Padding pour correspondre au TextFormField de Flutter
        if seed["padding"] == nil {
            enrichedSeed["padding"] = [
                "top": 14.0,
                "leading": 16.0,
                "bottom": 14.0,
                "trailing": 16.0
            ]
        }
        
        self.seed = enrichedSeed
        super.init()
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
    
    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        // Fusionner les arguments supplémentaires si fournis
        var finalSeed = self.seed
        if let additionalArgs = args as? [String: Any] {
            for (key, value) in additionalArgs {
                finalSeed[key] = value
            }
        }
        
        return TextFieldPView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger,
            channel: channel,
            seed: finalSeed
        )
    }
}

class TextFieldPView: NSObject, FlutterPlatformView {
    private var _view: UIView
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?,
        channel: FlutterMethodChannel,
        seed: [String: Any]
    ) {
        // Créer la vue SwiftUI et l'envelopper dans un UIHostingController
        let hostingController = UIHostingController(
            rootView: TextFieldSwiftUIView(seed: seed) { text in
                DispatchQueue.main.async {
                    channel.invokeMethod("textUpdate", arguments: text)
                }
            }
        )
        
        // Rendre la vue transparente pour s'intégrer correctement dans Flutter
        hostingController.view.backgroundColor = .clear
        hostingController.view.frame = frame
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        _view = hostingController.view
        super.init()
    }
    
    func view() -> UIView {
        return _view
    }
}
