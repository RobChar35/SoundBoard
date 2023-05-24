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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarGrabacion()
        reproducirButton.isEnabled = false
        agregarButton.isEnabled = false
        // Do any additional setup after loading the view.
    }
    
    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording{
           grabarAudio?.stop()
           grabarButton.setTitle("GRABAR", for: .normal)
           reproducirButton.isEnabled = true
        }else{
           grabarAudio?.record()
           grabarButton.setTitle("DETENER", for: .normal)
           reproducirButton.isEnabled = false
            agregarButton.isEnabled = true
        }

    }
    
    @IBAction func reproducirTapped(_ sender: Any) {
        do{
           try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
           reproducirAudio!.play()
           print("Reproduciendo")
        }catch{}
    }
    
    @IBAction func agregarTapped(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let grabacion = Grabacion(context: context)
        grabacion.nombre = nombreTextField.text
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
