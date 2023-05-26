//
//  SoundViewController.swift
//  SoundBoard
//
//  Created by Robert Charca on 24/05/23.
//

import UIKit
import AVFoundation

class SoundViewController: UIViewController {

    @IBOutlet weak  var grabarButton: UIButton!
    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var reproducirButton: UIButton!
    @IBOutlet weak var agregarButton: UIButton!
    
    var grabarAudio:AVAudioRecorder?
    var reproducirAudio:AVAudioPlayer?
    var audioURL:URL?
    
    @IBOutlet weak var cronometro: UILabel!
    var tiempo:Timer?
    var contador = 0
    var cronometroFormat:String = ""
    
    @IBOutlet weak var controlVolumen: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarGrabacion()
        reproducirButton.isEnabled = false
        agregarButton.isEnabled = false
        controlVolumen.addTarget(self, action: #selector(cambiarVolumen(_:)), for: .valueChanged)
        // Do any additional setup after loading the view.
    }
    
    @objc func contadorCronometro() {
        contador += 1
        let minutos = contador / 60
        let segundos = contador % 60
        
        cronometroFormat = String(format: "%02d:%02d", minutos, segundos)
        cronometro.text = cronometroFormat
    }
    
    @objc func cambiarVolumen(_ sender: UISlider) {
        reproducirAudio?.volume = sender.value
    }
    
    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording{
           grabarAudio?.stop()
           grabarButton.setTitle("GRABAR", for: .normal)
           reproducirButton.isEnabled = true
            tiempo?.invalidate()
        }else{
           grabarAudio?.record()
           grabarButton.setTitle("DETENER", for: .normal)
           reproducirButton.isEnabled = false
            agregarButton.isEnabled = true
            tiempo = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(contadorCronometro), userInfo: nil, repeats: true)
        }

    }
    
    @IBAction func reproducirTapped(_ sender: Any) {
        do{
           try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
           reproducirAudio!.play()
            reproducirAudio?.volume = controlVolumen.value
           print("Reproduciendo")
        }catch{}
    }
    
    @IBAction func agregarTapped(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let grabacion = Grabacion(context: context)
        grabacion.nombre = nombreTextField.text
        grabacion.duracion = cronometroFormat
        grabacion.audio = NSData(contentsOf:audioURL!)! as Data
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController!.popViewController(animated: true)

    }
    
    func configurarGrabacion(){
       do{
           let session = AVAudioSession.sharedInstance()
           try  session.setCategory(AVAudioSession.Category.playAndRecord, mode:AVAudioSession.Mode.default, options: [])
           try session.overrideOutputAudioPort(.speaker)
           try session.setActive(true)


           let basePath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask,true).first!
           let pathComponents = [basePath,"audio.m4a"]
           audioURL = NSURL.fileURL(withPathComponents: pathComponents)!


           print("*****************")
           print(audioURL!)
           print("*****************")


           var settings:[String:AnyObject] = [:]
           settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
           settings[AVSampleRateKey] = 44100.0 as AnyObject?
           settings[AVNumberOfChannelsKey] = 2 as AnyObject?


           grabarAudio = try AVAudioRecorder(url:audioURL!, settings: settings)
           grabarAudio!.prepareToRecord()
       }catch let error as NSError{
           print(error)
       }
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
