import 'dart:io';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TollPlazaForm(),
    );
  }
}

class TollPlazaForm extends StatefulWidget {
  @override
  _TollPlazaFormState createState() => _TollPlazaFormState();
}

class _TollPlazaFormState extends State<TollPlazaForm> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  final _formKey = GlobalKey<FormState>();
  final _plazaNameController =
      TextEditingController(text: 'Sonmarg Toll Plaza');
  final _dateController = TextEditingController(text: '07-09-2024');
  final _fareAmountController = TextEditingController(text: 'Rs 0');
  final _paymentModeController = TextEditingController();
  final _journeyTypeController = TextEditingController();
  final _laneIdController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _vehicleNoController = TextEditingController();

  @override
  void dispose() {
    _plazaNameController.dispose();
    _dateController.dispose();
    _fareAmountController.dispose();
    _paymentModeController.dispose();
    _journeyTypeController.dispose();
    _laneIdController.dispose();
    _vehicleTypeController.dispose();
    _vehicleNoController.dispose();
    super.dispose();
  }

  Future<void> _generatePDF() async {
    final pdf = pw.Document();
    final fontData = await rootBundle.load("assets/Roboto-Regular.ttf");
    final pdfFont = pw.Font.ttf(fontData);

    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          children: [
            pw.Text(
              'Toll Plaza Data',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                font: pdfFont,
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text('Plaza Name: ${_plazaNameController.text}',
                style: pw.TextStyle(font: pdfFont)),
            pw.Text('Date: ${_dateController.text}',
                style: pw.TextStyle(font: pdfFont)),
            pw.Text('Fare Amount: ${_fareAmountController.text}',
                style: pw.TextStyle(font: pdfFont)),
            pw.Text('Payment Mode: ${_paymentModeController.text}',
                style: pw.TextStyle(font: pdfFont)),
            pw.Text('Journey Type: ${_journeyTypeController.text}',
                style: pw.TextStyle(font: pdfFont)),
            pw.Text('Lane ID: ${_laneIdController.text}',
                style: pw.TextStyle(font: pdfFont)),
            pw.Text('Vehicle Type: ${_vehicleTypeController.text}',
                style: pw.TextStyle(font: pdfFont)),
            pw.Text('Vehicle No: ${_vehicleNoController.text}',
                style: pw.TextStyle(font: pdfFont)),
          ],
          crossAxisAlignment: pw.CrossAxisAlignment.start,
        );
      },
    ));

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/toll_plaza_data.pdf");
    await file.writeAsBytes(await pdf.save());

    _printPDF(file);
  }

  void _printPDF(File file) async {
    if (await bluetooth.isConnected == true) {
      await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => file.readAsBytesSync());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Printing...')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please connect to a Bluetooth printer.')),
      );
      await Printing.sharePdf(
        bytes: await file.readAsBytes(),
        filename: 'toll_plaza_data.pdf',
      );
    }
  }

  void _connectBluetooth() async {
    List<BluetoothDevice> devices = await bluetooth.getBondedDevices();
    if (devices.isNotEmpty) {
      await bluetooth.connect(devices.first); // Connecting to the first device
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Toll Plaza Form'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.grey[100],
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildTextField('Plaza Name', _plazaNameController,
                    readOnly: true),
                _buildTextField('Date', _dateController, readOnly: true),
                _buildTextField('Fare Amount', _fareAmountController,
                    readOnly: true),
                _buildTextField('Payment Mode', _paymentModeController),
                _buildTextField('Journey Type', _journeyTypeController),
                _buildTextField('Lane ID', _laneIdController),
                _buildTextField('Vehicle Type', _vehicleTypeController),
                _buildTextField('Vehicle No.', _vehicleNoController),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      backgroundColor: Colors.teal,
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _generatePDF();
                      }
                    },
                    child: const Text(
                      'Process',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          fillColor: Colors.white,
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.teal),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }
}
