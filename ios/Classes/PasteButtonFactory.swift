import Flutter
import UIKit
import SwiftUI
import UniformTypeIdentifiers

class PasteButtonFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    private var channel: FlutterMethodChannel
    private var seed: [String: Any]
    
    init(messenger: FlutterBinaryMessenger, seed: [String: Any]) {
        self.messenger = messenger
        self.channel = FlutterMethodChannel(
            name: seed["widgetUUID"] as! String,
            binaryMessenger: messenger
        )
        
        // Enrichir le seed avec des valeurs par défaut
        var enrichedSeed = seed
        
        // Valeurs par défaut pour garantir la compatibilité
        if enrichedSeed["hasLabel"] == nil {
            enrichedSeed["hasLabel"] = false
        }
        
        if enrichedSeed["width"] == nil {
            enrichedSeed["width"] = 100.0
        }
        
        if enrichedSeed["height"] == nil {
            enrichedSeed["height"] = 44.0
        }
        
        // Options avancées avec valeurs par défaut
        if enrichedSeed["customIcon"] == nil {
            enrichedSeed["customIcon"] = false
        }
        
        if enrichedSeed["iconSize"] == nil {
            enrichedSeed["iconSize"] = 24.0
        }
        
        if enrichedSeed["customStyleIconOnly"] == nil {
            enrichedSeed["customStyleIconOnly"] = false
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
        
        return PasteButtonPView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger,
            channel: channel,
            seed: finalSeed
        )
    }
}

class PasteButtonPView: NSObject, FlutterPlatformView {
    private var _view: UIView
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?,
        channel: FlutterMethodChannel,
        seed: [String: Any]
    ) {
        // Créer la couleur à partir des composants RGB
        let color = UIColor(
            red: seed["red"] as? Double ?? 0.0 / 255.0,
            green: seed["green"] as? Double ?? 0.0 / 255.0,
            blue: seed["blue"] as? Double ?? 255.0 / 255.0,
            alpha: seed["alpha"] as? Double ?? 1.0
        )
        
        // Créer le controller SwiftUI
        let hostingController = UIHostingController(
            rootView: PasteButtonSwiftUIView(seed: seed, bodyColor: Color(color)) { data in
                DispatchQueue.main.async {
                    channel.invokeMethod("pasteAction", arguments: data)
                }
            }
        )
        
        // Configurer la vue
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        _view = hostingController.view
        
        super.init()
    }
    
    func view() -> UIView {
        return _view
    }
}
