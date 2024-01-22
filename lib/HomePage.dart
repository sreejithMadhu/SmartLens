// ignore: file_names



import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import "package:camera/camera.dart";
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:vibration/vibration.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scan/scan.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:loading_overlay/loading_overlay.dart';

import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';



bool opencomplete = false;
bool _isLoading = false;
int curerentstate = 0;

int flip = 0;
String extractedBarcode = ' ';
String? result;
String qrcopybtntxt = 'copy to clipboard';
String qrcodesearchbtntxt = 'Search on Web';
FlashMode _flashMode = FlashMode.off;



String? _label;

//......................ocr


String _ocr_Read = '';

//...........................

late final  imageLabeler;

//........................
const img_directory = "/storage/emulated/0/DCIM/1.jpg";

class Homepage extends StatefulWidget
{
  const Homepage({Key?key}):super(key: key);

  @override
  State<Homepage> createState()=>_HomePageState();
}

class _HomePageState extends State<Homepage>
{
  late List<CameraDescription> Cameras;
  late CameraController cameraController;

  @override
  void initState() {
    startCamera();
    Loadmodel();
    extractedBarcode='';
     super.initState();
  }

Loadmodel()
async {
   final modelPath = 'flutter_assets/assets/ML/model.tflite';

  final ImageLabelerOptions options = LocalLabelerOptions(modelPath : modelPath,confidenceThreshold: 0.9);
   imageLabeler= ImageLabeler(options: options);
}


  void startCamera() async
  {
    Cameras = await availableCameras();
    cameraController = CameraController(Cameras[flip], ResolutionPreset.high,enableAudio: false);
    await cameraController.initialize().then((value)
    {
      if(!mounted)
      {
        return;
      }
      //Refresh Widget
      setState(() {});
    }).catchError((e)
    {
     // print(e);
    });
cameraController.setFlashMode(_flashMode);
    
  } 

@override
  void dispose() {
    cameraController.dispose();
    extractedBarcode = '';
    super.dispose();
  }

  @override
  Widget build(BuildContext context)
  {
    if(cameraController.value.isInitialized)
    {
      return Scaffold(
        body: LoadingOverlay(
      isLoading:false,
      child: Container(
         
        

         child:Stack(children: <Widget>[SizedBox(width: double.infinity,height: double.infinity, child: CameraPreview(cameraController)),
    
         //Info btn
         Padding(padding:const EdgeInsets.symmetric(horizontal: 15,vertical: 47),
           child: FloatingActionButton(
            onPressed:(){
              debugPrint("Capture button pressed");
            }
            ,highlightElevation: 0, elevation: 0,
           child:const Icon(Icons.info_outline_rounded,size: 30,),
           heroTag: "ingobtn",
           backgroundColor: Colors.black.withOpacity(0),
           )

         ),

     

           Padding(padding:const EdgeInsets.symmetric(horizontal: 15,vertical: 48),
           child:Align(alignment:Alignment.topRight,child:Container(height: 50,width: 50,
             child: FloatingActionButton(onPressed:()
             {
             
             setState(() {
                if (_flashMode == FlashMode.always) {
                _flashMode = FlashMode.off;
                 } else {
                 _flashMode = FlashMode.always;
                }
                 cameraController.setFlashMode(_flashMode);
             });
              
             }
             , splashColor: Colors.transparent,highlightElevation: 0,elevation: 0,
             heroTag: "flash_btn",
             backgroundColor: Colors.black.withOpacity(0),
             child:Icon(
              _flashMode == FlashMode.always?
              Icons.flash_on:Icons.flash_off,
              size: 30,
              ),
             ),
           )
           )

         ),
        


  const Padding(
           padding: EdgeInsets.symmetric(vertical: 160),
           child:Align(alignment: Alignment.center,child: 
              SizedBox(width: 150,height: 150,
                   child: Image(image:AssetImage('assets/images/camera.png'),width: 50,height: 50,),
           
               ),
         ),
         ),

        
      //....................................................................................................capture Btn
         
        
        //capture button

          Padding(padding:const EdgeInsets.symmetric(horizontal: 35,vertical: 30),
           child:Align(alignment:Alignment.bottomCenter,child:Container(height: 100,width: 100,
             child: FloatingActionButton(onPressed:()
             {
              takepicture();
              //page

              
             }
             , splashColor: Colors.transparent,highlightElevation: 0,
             child:Icon(Icons.circle_outlined,size: 100,),elevation: 0,
             heroTag: "capturebtn",
             backgroundColor: Colors.black.withOpacity(0),
             ),
           )
           )

         ),
        
        //gallerybtn
        Padding(padding:const EdgeInsets.symmetric(horizontal: 35,vertical: 43  ),
           child:Align(alignment:Alignment.bottomRight,child:Container(height: 75,width: 75,
             child: FloatingActionButton(onPressed:()
             {

              opengallery();

             
             }
             , splashColor: Colors.transparent,highlightElevation: 0,
             elevation: 0,
             backgroundColor: Colors.black.withOpacity(0),
             heroTag: "gallerybtn",
             child:const Icon(Icons.image_rounded,size: 45,)
             ),
           )
           )

         ),


          Padding(padding:const EdgeInsets.symmetric(horizontal: 35,vertical: 35),
           child:Align(alignment:Alignment.bottomLeft,child:Container(height: 75,width: 75,
             child: FloatingActionButton(onPressed:()
             {
               if(flip == 0)
               {
                flip = 1;
               }
               else
               {
                flip = 0;
               }
               startCamera();
             }
             , splashColor: Colors.transparent,highlightElevation: 0,
             elevation: 0,
             backgroundColor: Colors.black.withOpacity(0),
             heroTag: "cameraswitchbtn",
             child:const Icon(Icons.flip_camera_ios_rounded,size: 45,)
             ),
           )
           )

         )

         ],)
            

      )
          
        ),
        
        
        bottomNavigationBar: Container(
        color: Colors.black.withOpacity(1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 20),
          child: GNav(
            gap: 5,
            onTabChange: (index)
            {
              curerentstate = index;
            },
            backgroundColor: Colors.black.withOpacity(0),
            color: Colors.white,
            tabBackgroundColor: Colors.grey.shade900,
            padding: EdgeInsets.all(16), 
        
            activeColor: Colors.amberAccent,
            tabs: const[
              GButton(icon: Icons.data_array,text: "Object Detection",),
              GButton(icon: Icons.qr_code,text: "BarCode Reader",),
              GButton(icon: Icons.text_fields,text: "OCR",),
            ]),
        ),
      ),
    );
    }
    else
    {
      return const SizedBox();
    }
  
  }

var _imageWidth;
var _imageHeight;
var _recognitions;


void detectObjects(String imagePath) async {

InputImage img = InputImage.fromFilePath(img_directory);
final List<ImageLabel> labels = await imageLabeler.processImage(img);
double max_confidence = 0;
_label='';
for (ImageLabel label in labels) {
  final String text = label.label;
  final int index = label.index;
  final double confidence = label.confidence;
  if(confidence>5)
  {
  if(confidence>max_confidence)
  {
    max_confidence=confidence;
    _label = text; 
   }
  }
  
}
debugPrint("Label : $_label");
  debugPrint("Label : $max_confidence");
  if(max_confidence>5)
  {
     debugPrint("Launching");
    _launch();
  }
}


  // define the _launch method here
  Future<void> _launch() async {
    Uri google = Uri.parse("https://www.google.com/search?q="+_label!+"&source=lnms&tbm=shop&sa=X&ved=2ahUKEwi2yMWzmN3-AhX48DgGHer9CKcQ_AUoA3oECAEQBQ&cshid=1683255915607336&biw=1536&bih=746&dpr=1.25");
    await launchUrl(google);
  }

   
crop_img()
async {
 
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: img_directory,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarWidgetColor:Colors.amberAccent,
            backgroundColor: Colors.white,
            activeControlsWidgetColor: Colors.amberAccent,
            cropGridColor: Colors.white,
            cropFrameColor: Colors.white,
            toolbarColor: Colors.black,
            cropGridStrokeWidth:12,
            cropFrameStrokeWidth:15,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Cropper',
        ),
        WebUiSettings(
          context: context,
        ),
      ],
    );

  
     if (croppedFile != null) {
        final Uint8List copiedfile = await croppedFile.readAsBytes();
        final pathofimage = await File(img_directory);
        await pathofimage.writeAsBytes(copiedfile);
        if(curerentstate == 2)
        {
         Navigator.push(context, MaterialPageRoute(builder: (context) => imagecropper()));
        }
        else if(curerentstate == 1)
        {
        Navigator.push(context,MaterialPageRoute(builder: ((context) => qrcodepage())));
        }
     }

}

   _rotateImage(File file) async {
     debugPrint("Label Rotating");

     
 
      final newFile =  File(img_directory);

      Uint8List imageBytes = await newFile.readAsBytes();

      final originalImage = img.decodeImage(imageBytes);

      img.Image fixedImage;
      fixedImage = img.copyRotate(originalImage!,  angle: 90);

      final fixedFile = await newFile.writeAsBytes(img.encodeJpg(fixedImage),
          mode: FileMode.write, flush: true);

  }

void cropImageInBackground(XFile image) async {
  // Load image from file
  final imageData = await image.readAsBytes();
  final imageFile = File(img_directory);
  await imageFile.writeAsBytes(imageData);
  
  if (curerentstate == 1 || curerentstate == 2) {
    // Start crop operation in background
    Future.delayed(Duration.zero, () => crop_img());
  } else {
    // Navigate to next screen without cropping
    if (curerentstate == 0) {
img.Image? image = img.decodeImage(File(img_directory).readAsBytesSync());
img.Image resizedImage = img.copyResize(image!, width: 384, height: 384);
// Save the image as jpg
File(img_directory).writeAsBytesSync(img.encodeJpg(resizedImage, quality: 100));

      debugPrint("Label");
      //await _rotateImage(File(img_directory));
      detectObjects(img_directory);
    } 
  }
}


  takepicture() async {
       Vibration.vibrate(duration: 100);
debugPrint("Image Captured");
if (cameraController.value.isInitialized) {
  final image =     await cameraController.takePicture();
  File img = File(img_directory);
  if (await File(img_directory).exists()) {
    img = File(img_directory);
    img.delete();
  }
  setState(() {
  _isLoading = true;
});
  // Perform crop operation in the background while the image is being saved
  cropImageInBackground(image);
}

}

opengallery() async
{
  ImagePicker picker = ImagePicker();
  XFile? image = await picker.pickImage(source: ImageSource.gallery); 
   image?.saveTo(img_directory);

    cropImageInBackground(image!);
              

}
}
//....................................................................................................QrCode

class qrcodepage extends StatefulWidget
{
  @override
  qrcode createState()=>qrcode();
}
class qrcode extends State<qrcodepage>
{
   @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(color: Colors.black,
        
        child:Stack(children:<Widget>[
        
         Padding(padding:const EdgeInsets.symmetric(horizontal: 0,vertical: 0),
           child:Align(alignment:Alignment.topCenter,child:Container(height: 150,width: 300,
             child :const Center(
               child: Text("Barcode Reader",textAlign: TextAlign.center,style:TextStyle(fontSize: 20,color: Colors.amberAccent,fontWeight: FontWeight.bold)
               ),
             )
           )
           )
         ),
           
        
         Padding(padding:const EdgeInsets.symmetric(horizontal: 15,vertical: 47),
           child: FloatingActionButton(
            onPressed:(){
              Navigator.pop(context);
            }
            ,highlightElevation: 0, elevation: 0,
           child:Icon(Icons.arrow_back_ios),
           heroTag: "ingobtn",
           backgroundColor: Colors.black.withOpacity(0),
           )

         ),

         Padding(padding:const EdgeInsets.symmetric(horizontal: 0,vertical:200),
           child:Align(alignment:Alignment.bottomCenter,child:Container(height: 150,width: 370,
             child :Center(
               child: Text(extractedBarcode,textAlign: TextAlign.center,style:TextStyle(fontSize: 18,color: Colors.amberAccent,fontWeight: FontWeight.bold)
               ),
             )
           )
           )
         ),

        
         const Padding(
           padding: EdgeInsets.symmetric(vertical: 160),
           child:Align(alignment: Alignment.topCenter,child: 
              SizedBox(width: 250,height: 250,
                   child: Image(image:AssetImage('assets/images/sree.png'),width: 100,height: 100,),
           
               ),
         ),
         ),
         
           Padding(padding:const EdgeInsets.symmetric(horizontal: 0,vertical:100),
           child:Align(alignment:Alignment.bottomCenter,child:Container(height: 200,width: 300,
             child :Center(
               child: SizedBox(width: 450,height: 45,child: ElevatedButton (style: ElevatedButton.styleFrom(primary: Colors.amberAccent,shape: StadiumBorder()),
               onPressed: (){
                if(extractedBarcode != 'Cannot read QRcode'&&extractedBarcode!='')
                {
                
                Clipboard.setData(ClipboardData(text: extractedBarcode));
                qrcopybtntxt = "Text Copied";
                setState(() {
                  
                });
                }
                else
                {
                qrcopybtntxt = "invalid QR code";
                setState(() {});
                }
                Vibration.vibrate(duration: 70);
               }
               ,child : Text(qrcopybtntxt,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),)),),
               ),
             )
           )
           ),

          Padding(padding:const EdgeInsets.symmetric(horizontal: 0,vertical:10),
           child:Align(alignment:Alignment.bottomCenter,child:Container(height: 200,width: 300,
             child :Center(
               child: SizedBox(width: 450,height: 45,child: ElevatedButton (style: ElevatedButton.styleFrom(primary:Color(0xFFFFD740), shape: StadiumBorder()),
               onPressed: (){

                launchurl();

               }
               ,child : Text(qrcodesearchbtntxt,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),)),),
               ),
             )
           )
           )

         ]
    )
    )
    );
  }
  
  launchurl()
  async {
    if(extractedBarcode == '' || extractedBarcode == 'Cannot read QRcode')
    {
        qrcodesearchbtntxt = 'No data Found';
        setState(() {
          
        });
    }
    else
    {
     Uri url = Uri.parse(extractedBarcode);
         if (await canLaunchUrl(url)) {
             await launchUrl(url);
         }
         else
         {
           Uri google = Uri.parse("https://www.google.com/search?q="+extractedBarcode);
            await launchUrl(google);
         }
    }
    Vibration.vibrate(duration: 70);
  }

  @override
void initState()  {
    debugPrint("Barcode called");
    qrcopybtntxt = "Copy to Clipboard";
    qrcodesearchbtntxt = "Search on Web";
    setState(() { });
    displayqrvalue();
    super.initState();
  }

displayqrvalue()
async {

  result = await Scan.parse(img_directory );
  if(result!=null)
  {
  extractedBarcode = result!;
  }
  else
  {
    extractedBarcode = "Cannot read QRcode";
  }
 
  setState(() {  });
 
}

@override
  Future<void> dispose() async {
    result=extractedBarcode='';
    super.dispose();
  }
}

//.............................................................................image cropping/OCR

class imagecropper extends StatefulWidget
{
  const imagecropper({Key?key}):super(key: key);
  @override
  cropper createState()=>cropper();
}
class cropper extends State<imagecropper>
{

final   _textrecogniser = TextRecognizer();

ocr()
async {


File img = File(img_directory);
final inputImage = InputImage.fromFile(img); 
final recognisedText = await _textrecogniser.processImage( inputImage);
//ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text("Scanned Result is $recognisedText")));
if(recognisedText.text !='')
{
  setState(() {
    

_ocr_Read = recognisedText.text;
debugPrint("Result is $_ocr_Read");
  });
}
else
{
  setState(() {
    _ocr_Read = "No Text Detected";
  });
}
}


@override
  void dispose() {

  _ocr_Read = '';

    _textrecogniser.close();
    super.dispose();
  }

@override
  void initState() {
   ocr();
    super.initState();
  }

late File _imageFile;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Container(
        child: SizedBox.expand(
          child: Container( color: Colors.black,
            
            child:Stack(children:<Widget>[
        
               Padding(padding:const EdgeInsets.symmetric(horizontal: 15,vertical: 47),
               child: FloatingActionButton(
                onPressed:(){
                  Navigator.pop(context);
                }
                ,highlightElevation: 0, elevation: 0,
               child:Icon(Icons.arrow_back_ios),
               heroTag: "ingobtn",
               backgroundColor: Colors.black.withOpacity(0),
               
               )
              ),
              Padding(padding:const EdgeInsets.symmetric(horizontal: 0,vertical: 0),
              child:Align(alignment:Alignment.topCenter,child:Container(height: 150,width: 300,
              child :const Center(
               child: Text("Optical Charecter Recognition",textAlign: TextAlign.center,style:TextStyle(fontSize: 20,color: Colors.amberAccent,fontWeight: FontWeight.bold)
               ),
             )
           )
           )
         ),

         const Padding(
           padding: EdgeInsets.symmetric(vertical: 130),
           child:Align(alignment: Alignment.topCenter,child: 
              SizedBox(width: 250,height: 250,
                   child: Image(image:AssetImage('assets/images/OCR.png'),width: 100,height: 100,),
           
               ),
         ),
         ),


          Padding(padding:const EdgeInsets.symmetric(horizontal: 0,vertical: 150),
              child:Align(alignment:Alignment.bottomCenter,child:Container(height: 200,width: 500,
              child : Center(
               child: SelectionArea(child:Text(_ocr_Read,textAlign: TextAlign.center,style:TextStyle(fontSize: 15,color: Colors.amberAccent,fontWeight: FontWeight.bold)
               )
               ),
             )
           )
           )
         ),
        Padding(padding:const EdgeInsets.symmetric(horizontal: 0,vertical:20),
           child:Align(alignment:Alignment.bottomCenter,child:Container(height: 150,width: 300,
             child :Center(
               child: SizedBox(width: 450,height: 45,child: ElevatedButton (style: ElevatedButton.styleFrom(primary: Colors.amberAccent,shape: StadiumBorder()),
               onPressed: (){
                
                Vibration.vibrate(duration: 70);
               }
               ,child : Text(qrcopybtntxt,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),)),),
               ),
             )
           )
           ),

            ]
            
            )
            ),  
          ),
          
      )



    );
  

  }
  

}


//.............................................................................Face Recognition

class FaceRecognition extends StatefulWidget
{
  const FaceRecognition({Key?key}):super(key: key);
  @override
  _facerecog createState()=>_facerecog();
}
class _facerecog extends State<FaceRecognition>
{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:SizedBox.expand(
        child: Container( color: Colors.black,
          
          child:Stack(children:<Widget>[
      
             Padding(padding:const EdgeInsets.symmetric(horizontal: 15,vertical: 47),
             child: FloatingActionButton(
              onPressed:(){
                Navigator.pop(context);
              }
              ,highlightElevation: 0, elevation: 0,
             child:Icon(Icons.arrow_back_ios),
             heroTag: "ingobtn",
             backgroundColor: Colors.black.withOpacity(0),
             
             )
            )
      
          ]
          
          )
          ),
      )
    );
    
      
  }

}

//.............................................................................object Detection

class objectDetection extends StatefulWidget
{
  const objectDetection({Key?key}):super(key: key);
  @override
  _objectDetection createState()=>_objectDetection();
}
class _objectDetection extends State<objectDetection>
{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:SizedBox.expand(
        child: Container( color: Colors.black,
          
          child:Stack(children:<Widget>[
      
             Padding(padding:const EdgeInsets.symmetric(horizontal: 15,vertical: 47),
             child: FloatingActionButton(
              onPressed:(){
                Navigator.pop(context);
              }
              ,highlightElevation: 0, elevation: 0,
             child:Icon(Icons.arrow_back_ios),
             heroTag: "ingobtn",
             backgroundColor: Colors.black.withOpacity(0),
             
             )
            )
      
          ]
          
          )
          ),
      )
    );
    
  }

}
