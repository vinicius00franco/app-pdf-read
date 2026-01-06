import 'package:flutter/material.dart';
import 'screens/pdf_reader_screen.dart';
import 'services/pdf_picker_service.dart';
import 'services/pdf_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: PdfReaderScreen(
        pdfPickerService: PdfPickerService(),
        pdfService: PdfService(),
      ),
    );
  }
}
