import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

@module
abstract class FilePickersModule {
  @lazySingleton
  ImagePicker get imagePicker => ImagePicker();

  @lazySingleton
  FilePicker get filePicker => FilePicker.platform;
}
