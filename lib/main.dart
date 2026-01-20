import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/pdf_reader_screen.dart';
import 'services/pdf_picker_service.dart';
import 'services/pdf_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/config/.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Reader',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: PdfReaderScreen(
        pdfPickerService: PdfPickerService(),
        pdfService: PdfService(),
      ),
    );
  }
}
