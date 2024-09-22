import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart'; // To save file
import 'package:slip_genrater/Provider/report_provider.dart'; // Your report provider

class ReportPlaza extends StatefulWidget {
  const ReportPlaza({Key? key}) : super(key: key);

  @override
  State<ReportPlaza> createState() => _ReportPlazaState();
}

class _ReportPlazaState extends State<ReportPlaza> {
  @override
  void initState() {
    super.initState();
    Provider.of<ReportProvider>(context, listen: false).fetchReports();
  }

  // Method to generate PDF
  Future<File> _generatePdf(List<dynamic> reports) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Table.fromTextArray(
          headers: [
            'ID',
            'Lane ID',
            'TC Name',
            'Date Time',
            'Vehicle Number',
            'Fare',
            'Penalty Fare',
            'Expiry Date Time'
          ],
          data: List<List<String>>.generate(
            reports.length,
            (index) {
              final report = reports[index];
              return [
                (index + 1).toString(),
                report.laneId ?? 'N/A',
                report.tcName ?? 'N/A',
                report.dateTime ?? 'N/A',
                report.vehNum ?? 'N/A',
                report.fare?.toString() ?? 'N/A',
                report.penaltyFare?.toString() ?? 'N/A',
                report.expiryDateTime ?? 'N/A',
              ];
            },
          ),
        ),
      ),
    );

    // Save the PDF to a file
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/report_plaza.pdf");
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // Method to share PDF
  Future<void> _sharePdf(List<dynamic> reports) async {
    try {
      final pdfFile = await _generatePdf(reports);
      await Share.shareXFiles([XFile(pdfFile.path)], text: 'Report Plaza Data');
    } catch (e) {
      print('Error while sharing PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Plaza'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Trigger PDF sharing when the button is clicked
              final reportProvider =
                  Provider.of<ReportProvider>(context, listen: false);
              if (reportProvider.reports.isNotEmpty) {
                _sharePdf(reportProvider.reports);
              }
            },
          ),
        ],
      ),
      body: Consumer<ReportProvider>(
        builder: (context, reportProvider, child) {
          if (reportProvider.reports.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Calculate the total Fare and Penalty Fare
          final totalFare = reportProvider.reports
              .fold<double>(0.0, (sum, report) => sum + (report.fare ?? 0));
          final totalPenaltyFare = reportProvider.reports.fold<double>(
              0.0, (sum, report) => sum + (report.penaltyFare ?? 0));

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 20.0,
                      headingRowColor:
                          MaterialStateProperty.all(Colors.teal[100]),
                      headingTextStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      border: TableBorder.all(color: Colors.grey, width: 1),
                      columns: const [
                        DataColumn(label: Text('TransanctionId')),
                        DataColumn(label: Text('Lane ID')),
                        DataColumn(label: Text('TC Name')),
                        DataColumn(label: Text('Vehicle Number')),
                        DataColumn(label: Text('Fare')),
                        DataColumn(label: Text('Penalty Fare')),
                      ],
                      rows: List<DataRow>.generate(
                        reportProvider.reports.length,
                        (index) {
                          final report = reportProvider.reports[index];
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  '${report.laneId ?? 'N/A'} | ${report.dateTime ?? 'N/A'}',
                                ),
                              ),
                              // DataCell(Text((index + 1).toString())),
                              DataCell(Text(report.laneId ?? 'N/A')),
                              DataCell(Text(report.tcName ?? 'N/A')),
                              DataCell(Text(report.vehNum ?? 'N/A')),
                              DataCell(Text(report.fare?.toString() ?? 'N/A')),
                              DataCell(Text(
                                  report.penaltyFare?.toString() ?? 'N/A')),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              Text(
                'Total Fare: \$${totalFare.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(width: 20),
              Text(
                'Total Penalty Fare: \$${totalPenaltyFare.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              // Display the totals row below the DataTable
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
