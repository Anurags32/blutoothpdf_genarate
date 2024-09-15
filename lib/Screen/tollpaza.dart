import 'dart:io';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class TollPlazaForm extends StatefulWidget {
  @override
  _TollPlazaFormState createState() => _TollPlazaFormState();
}

class _TollPlazaFormState extends State<TollPlazaForm> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  final _formKey = GlobalKey<FormState>();

  final _plazaNameController = TextEditingController();
  final _sectionController = TextEditingController();
  final _contractorNameController = TextEditingController();
  final _ticketNoController = TextEditingController();
  final _boothOperatorController = TextEditingController();
  final _dateController = TextEditingController(text: _getFormattedDate());
  final _timeController = TextEditingController(text: _getFormattedTime());
  final _vehicleNoController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _journeyTypeController = TextEditingController();
  final _feeController = TextEditingController();
  final _fineController = TextEditingController();
  final _totalTollFeeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  @override
  void dispose() {
    _plazaNameController.dispose();
    _sectionController.dispose();
    _contractorNameController.dispose();
    _ticketNoController.dispose();
    _boothOperatorController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _vehicleNoController.dispose();
    _vehicleTypeController.dispose();
    _journeyTypeController.dispose();
    _feeController.dispose();
    _fineController.dispose();
    _totalTollFeeController.dispose();
    super.dispose();
  }

  static String _getFormattedDate() {
    final now = DateTime.now();
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(now);
  }

  static String _getFormattedTime() {
    final now = DateTime.now();
    final formatter = DateFormat('hh:mm:ss a');
    return formatter.format(now);
  }

  void _initializeFields() {
    _plazaNameController.text = 'Bagwada Toll Plaza';
    _sectionController.text = 'Ch. No. 31+700';
    _contractorNameController.text = 'Coral Associates';
    _ticketNoController.text = '';
    _boothOperatorController.text = '';
    _vehicleNoController.text = '';
    _vehicleTypeController.text = '';
    _journeyTypeController.text = '';
    _feeController.text = 'Rs.';
    _fineController.text = 'Rs.';
    _totalTollFeeController.text = 'Rs.';
  }

  Future<void> _generatePDF() async {
    final pdf = pw.Document();
    final fontData = await rootBundle.load("assets/Roboto-Regular.ttf");
    final pdfFont = pw.Font.ttf(fontData);

    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(
                'Obedullaganj Itarsi ROAD',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  font: pdfFont,
                ),
              ),
            ),
            pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(
                'Bagwada Toll Plaza NH-46',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  font: pdfFont,
                ),
              ),
            ),
            // pw.SizedBox(height: 20),
            pw.Text('Toll Plaza Name: ${_plazaNameController.text}',
                style: pw.TextStyle(font: pdfFont)),
            pw.Text('Section: ${_sectionController.text}',
                style: pw.TextStyle(font: pdfFont)),
            pw.Text('Contractor Name: ${_contractorNameController.text}',
                style: pw.TextStyle(font: pdfFont)),
            pw.Text('Ticket No: ${_ticketNoController.text}',
                style: pw.TextStyle(font: pdfFont)),
            pw.Text('Booth & Operator: ${_boothOperatorController.text}',
                style: pw.TextStyle(font: pdfFont)),
            pw.Text(
                'Date & Time: ${_dateController.text} ${_timeController.text}',
                style: pw.TextStyle(font: pdfFont)),
            pw.Text('Vehicle No: ${_vehicleNoController.text}',
                style: pw.TextStyle(font: pdfFont)),
            pw.Text('Type of Vehicle: ${_vehicleTypeController.text}',
                style: pw.TextStyle(font: pdfFont)),
            pw.Text('Type of Journey: ${_journeyTypeController.text}',
                style: pw.TextStyle(font: pdfFont)),
            pw.Text('Fee: ${_feeController.text}',
                style: pw.TextStyle(font: pdfFont)),
            pw.Text('Fine for Non-FASTag: ${_fineController.text}',
                style: pw.TextStyle(font: pdfFont)),
            pw.Text('Total Toll Fee: ${_totalTollFeeController.text}',
                style: pw.TextStyle(font: pdfFont)),
          ],
          // crossAxisAlignment: pw.CrossAxisAlignment.start,
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
      _connectToPrinter(devices.first);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No Bluetooth devices found')),
      );
    }
  }

  void _connectToPrinter(BluetoothDevice device) async {
    try {
      await bluetooth.connect(device);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connected to ${device.name}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect: $e')),
      );
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
                _buildTextField('Toll Plaza Name', _plazaNameController,
                    readOnly: true),
                _buildTextField('Section', _sectionController, readOnly: true),
                _buildTextField('Contractor Name', _contractorNameController,
                    readOnly: true),
                _buildTextField('Ticket No', _ticketNoController,
                    isNumeric: true),
                _buildTextField('Booth & Operator', _boothOperatorController),
                _buildTextField('Date', _dateController, readOnly: true),
                _buildTextField('Time', _timeController, readOnly: true),
                _buildTextField('Vehicle No.', _vehicleNoController),
                _buildTextField('Type of Vehicle', _vehicleTypeController),
                _buildTextField('Type of Journey', _journeyTypeController),
                _buildTextField('Fee', _feeController, isNumeric: true),
                _buildTextField('Fine for Non-FASTag', _fineController,
                    isNumeric: true),
                _buildTextField('Total Toll Fee', _totalTollFeeController,
                    isNumeric: true),
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
    bool isNumeric = false,
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
          if (!readOnly && (value == null || value.isEmpty)) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }
}
