/* import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_management_system/controllers/admit_card_controller.dart';
import 'package:school_management_system/models/admitcardModel.dart';

class AdmitCardScreen extends StatelessWidget {
  const AdmitCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdmitCardController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admit Card"),
        actions: [
          Obx(
            () => controller.admitCard.value == null
                ? const SizedBox()
                : IconButton(
                    icon: controller.isGeneratingPdf.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.picture_as_pdf),
                    onPressed: controller.isGeneratingPdf.value
                        ? null
                        : () => _generatePdf(controller),
                  ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = controller.admitCard.value;
        if (data == null) {
          return const Center(child: Text("No Data"));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: _buildAdmitCardUI(data),
            ),
          ),
        );
      }),
    );
  }

  // --- UI PART ---

  Widget _buildAdmitCardUI(AdmitCardModel data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(color: Colors.black, width: 2),
      ),
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          _buildHeader(data),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildTable(data),
          ),
          const SizedBox(height: 40),
          _buildSignatures(),
        ],
      ),
    );
  }

  Widget _buildHeader(AdmitCardModel data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Logo
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/benchmark-logo.jpeg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.school, size: 50),
              ),
            ),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              children: [
                Text(
                  "BENCHMARK",
                  style: GoogleFonts.merriweather(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1E3A8A),
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  "School of Leadership",
                  style: GoogleFonts.dancingScript(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0284C7),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "PLAY GROUP TO MATRIC",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 8,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "ADMIT CARD",
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data.examTitle,
                  style: GoogleFonts.inter(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          // Balance right side empty space for centering
        ],
      ),
    );
  }

  Widget _buildTable(AdmitCardModel data) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Column(
        children: [
          // Top Part: Rows 1-3 (left) + Photo (right)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 18,
                  child: Column(
                    children: [
                      _gridRow([
                        _gridCell(6, "Student's Name", isBold: true),
                        _gridCell(
                          12,
                          data.studentName,
                          isCenter: true,
                          borderRight: false,
                        ),
                      ]),
                      _gridRow([
                        _gridCell(6, "Father's Name", isBold: true),
                        _gridCell(
                          12,
                          data.fatherName,
                          isCenter: true,
                          borderRight: false,
                        ),
                      ]),
                      _gridRow([
                        _gridCell(6, "Class", isBold: true),
                        _gridCell(6, data.className, isCenter: true),
                        _gridCell(3, "Section", isBold: true),
                        _gridCell(
                          3,
                          data.section,
                          isCenter: true,
                          borderRight: false,
                        ),
                      ], borderBottom: false),
                    ],
                  ),
                ),
                Expanded(
  flex: 4,
  child: Container(
    decoration: const BoxDecoration(
      border: Border(
        left: BorderSide(color: Colors.black, width: 1),
      ),
    ),
    padding: const EdgeInsets.all(6),
    child: Center(
      child: data.photoUrl != null && data.photoUrl!.isNotEmpty
          ? Image.network(
              data.photoUrl!, // Load the student's photo
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.person, size: 40, color: Colors.grey),
            )
          : const Icon(
              Icons.person,
              size: 40,
              color: Colors.grey,
            ),
    ),
  ),
),
              ],
            ),
          ),
          // Bottom Part: Row 4
          Container(height: 1, color: Colors.black),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _gridCell(7, "Admission No.", isBold: true),
                _gridCell(6, data.admissionNo, isCenter: true),
                _gridCell(4, "G.R No.", isBold: true),
                _gridCell(4, data.grNo, isCenter: true),
                _gridCell(3, "Seat No.", isBold: true),
                _gridCell(3, data.seatNo, isCenter: true, borderRight: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _gridRow(List<Widget> cells, {bool borderBottom = true}) {
    return Container(
      decoration: borderBottom
          ? const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black, width: 1)),
            )
          : null,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: cells,
        ),
      ),
    );
  }

  Widget _gridCell(
    int flex,
    String text, {
    bool borderRight = true,
    bool isCenter = false,
    bool isBold = false,
  }) {
    return Expanded(
      flex: flex,
      child: Container(
        decoration: borderRight
            ? const BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.black, width: 1),
                ),
              )
            : null,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        alignment: isCenter ? Alignment.center : Alignment.centerLeft,
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: 7,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildSignatures() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _signatureBox("Signature of Controller"),
          _signatureBox("Signature of Class Teacher"),
        ],
      ),
    );
  }

  Widget _signatureBox(String title) {
    return Column(
      children: [
        Container(width: 60, height: 1, color: Colors.black),
        const SizedBox(height: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 6,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  // --- PDF PART ---

  Future<void> _generatePdf(AdmitCardController controller) async {
    controller.isGeneratingPdf.value = true;
    try {
      final data = controller.admitCard.value!;
      final pdf = pw.Document();

      // Load fonts using PdfGoogleFonts from printing package
      final interRegular = pw.Font.helvetica();
      final interBold = pw.Font.helveticaBold();
      final merriweatherBold = pw.Font.timesBold();
      final dancingScriptBold = pw.Font.timesBoldItalic();

      // Load image from assets
      pw.MemoryImage? logoImage;
      try {
        final ByteData bytes = await rootBundle.load(
          'assets/benchmark-logo.jpeg',
        );
        logoImage = pw.MemoryImage(bytes.buffer.asUint8List());
      } catch (e) {
        // Image load failure — silently continue without logo
      }

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(30),
          build: (pw.Context context) {
            return pw.Container(
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                border: pw.Border.all(color: PdfColors.black, width: 2),
              ),
              padding: const pw.EdgeInsets.only(bottom: 20),
              child: pw.Column(
                children: [
                  _buildPdfHeader(
                    data,
                    logoImage,
                    merriweatherBold,
                    dancingScriptBold,
                    interBold,
                    interRegular,
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 20),
                    child: _buildPdfTable(
                      data,
                      interBold,
                      interRegular,
                      logoImage,
                    ),
                  ),
                  pw.SizedBox(height: 60),
                  _buildPdfSignatures(interBold),
                ],
              ),
            );
          },
        ),
      );

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: "AdmitCard.pdf",
      );
    } finally {
      controller.isGeneratingPdf.value = false;
    }
  }

  pw.Widget _buildPdfHeader(
    AdmitCardModel data,
    pw.MemoryImage? logo,
    pw.Font titleFont,
    pw.Font subTitleFont,
    pw.Font boldFont,
    pw.Font regFont,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: pw.Column(
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Container(
                width: 100,
                height: 100,
                decoration: pw.BoxDecoration(
                  shape: pw.BoxShape.circle,
                  border: pw.Border.all(color: PdfColors.black, width: 2),
                ),
                child: logo != null
                    ? pw.ClipOval(child: pw.Image(logo, fit: pw.BoxFit.cover))
                    : pw.SizedBox(),
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: pw.Column(
                  children: [
                    pw.Text(
                      "BENCHMARK",
                      style: pw.TextStyle(
                        font: titleFont,
                        fontSize: 25,
                        color: const PdfColor.fromInt(0xFF1E3A8A),
                      ),
                    ),
                    pw.Text(
                      "School of Leadership",
                      style: pw.TextStyle(
                        font: subTitleFont,
                        fontSize: 22,
                        color: const PdfColor.fromInt(0xFF0284C7),
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: pw.BoxDecoration(
                        color: const PdfColor.fromInt(0xFF1E293B),
                        borderRadius: const pw.BorderRadius.all(
                          pw.Radius.circular(30),
                        ),
                      ),
                      child: pw.Text(
                        "PLAY GROUP TO MATRIC",
                        style: pw.TextStyle(
                          font: boldFont,
                          color: PdfColors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 110),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            "ADMIT CARD",
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 16,
              color: PdfColors.black,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            data.examTitle,
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 14,
              color: PdfColors.black,
            ),
          ),
          pw.SizedBox(height: 10),
        ],
      ),
    );
  }

  pw.Widget _buildPdfTable(
    AdmitCardModel data,
    pw.Font boldFont,
    pw.Font regFont,
    pw.MemoryImage? logo,
  ) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1.5),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            crossAxisAlignment: pw
                .CrossAxisAlignment
                .start, // Top aligned to allow height matches
            children: [
              pw.Expanded(
                flex: 18,
                child: pw.Column(
                  children: [
                    _pdfGridRow([
                      _pdfGridCell(6, "Student's Name", boldFont, isBold: true),
                      _pdfGridCell(
                        12,
                        data.studentName,
                        boldFont,
                        isCenter: true,
                        borderRight: false,
                      ),
                    ]),
                    _pdfGridRow([
                      _pdfGridCell(6, "Father's Name", boldFont, isBold: true),
                      _pdfGridCell(
                        12,
                        data.fatherName,
                        boldFont,
                        isCenter: true,
                        borderRight: false,
                      ),
                    ]),
                    _pdfGridRow([
                      _pdfGridCell(6, "Class", boldFont, isBold: true),
                      _pdfGridCell(6, data.className, boldFont, isCenter: true),
                      _pdfGridCell(3, "Section", boldFont, isBold: true),
                      _pdfGridCell(
                        3,
                        data.section,
                        boldFont,
                        isCenter: true,
                        borderRight: false,
                      ),
                    ], borderBottom: false),
                  ],
                ),
              ),
              pw.Expanded(
                flex: 4,
                child: pw.Container(
                  height:
                      93, // (31 * 3) roughly to match 3 rows of height 31 each
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      left: pw.BorderSide(color: PdfColors.black, width: 1),
                    ),
                  ),
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Center(
                    child: logo != null
                        ? pw.Image(logo, fit: pw.BoxFit.fill)
                        : pw.SizedBox(),
                  ),
                ),
              ),
            ],
          ),
          pw.Container(height: 1, color: PdfColors.black),
          pw.Row(
            children: [
              _pdfGridCell(7, "Admission No.", boldFont, isBold: true),
              _pdfGridCell(6, data.admissionNo, boldFont, isCenter: true),
              _pdfGridCell(4, "G.R No.", boldFont, isBold: true),
              _pdfGridCell(4, data.grNo, boldFont, isCenter: true),
              _pdfGridCell(3, "Seat No.", boldFont, isBold: true),
              _pdfGridCell(
                3,
                data.seatNo,
                boldFont,
                isCenter: true,
                borderRight: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfGridRow(List<pw.Widget> cells, {bool borderBottom = true}) {
    return pw.Container(
      decoration: borderBottom
          ? const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.black, width: 1),
              ),
            )
          : null,
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: cells,
      ),
    );
  }

  pw.Widget _pdfGridCell(
    int flex,
    String text,
    pw.Font font, {
    bool borderRight = true,
    bool isCenter = false,
    bool isBold = false,
  }) {
    return pw.Expanded(
      flex: flex,
      child: pw.Container(
        decoration: borderRight
            ? const pw.BoxDecoration(
                border: pw.Border(
                  right: pw.BorderSide(color: PdfColors.black, width: 1),
                ),
              )
            : null,
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        alignment: isCenter ? pw.Alignment.center : pw.Alignment.centerLeft,
        child: pw.Text(
          text,
          style: pw.TextStyle(font: font, fontSize: 11, color: PdfColors.black),
        ),
      ),
    );
  }

  pw.Widget _buildPdfSignatures(pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 40),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _pdfSignatureBox("Signature of Controller", font),
          _pdfSignatureBox("Signature of Class Teacher", font),
        ],
      ),
    );
  }

  pw.Widget _pdfSignatureBox(String title, pw.Font font) {
    return pw.Column(
      children: [
        pw.Container(width: 160, height: 1, color: PdfColors.black),
        pw.SizedBox(height: 8),
        pw.Text(title, style: pw.TextStyle(font: font, fontSize: 11)),
      ],
    );
  }
}
*/
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show NetworkAssetBundle, rootBundle;
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_management_system/controllers/admit_card_controller.dart';
import 'package:school_management_system/models/admitcardModel.dart';

class AdmitCardScreen extends StatelessWidget {
  const AdmitCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdmitCardController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admit Card"),
        actions: [
          Obx(
            () => controller.admitCard.value == null
                ? const SizedBox()
                : IconButton(
                    icon: controller.isGeneratingPdf.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.picture_as_pdf),
                    onPressed: controller.isGeneratingPdf.value
                        ? null
                        : () => _generatePdf(controller),
                  ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = controller.admitCard.value;
        if (data == null) {
          return const Center(child: Text("No Data"));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: _buildAdmitCardUI(data),
            ),
          ),
        );
      }),
    );
  }

  // --- UI PART ---

  Widget _buildAdmitCardUI(AdmitCardModel data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(color: Colors.black, width: 2),
      ),
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          _buildHeader(data),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildTable(data),
          ),
          const SizedBox(height: 40),
          _buildSignatures(),
        ],
      ),
    );
  }

  Widget _buildHeader(AdmitCardModel data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/benchmark-logo.jpeg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.school, size: 50),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              children: [
                Text(
                  "BENCHMARK",
                  style: GoogleFonts.merriweather(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1E3A8A),
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  "School of Leadership",
                  style: GoogleFonts.dancingScript(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0284C7),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "PLAY GROUP TO MATRIC",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 8,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "${data.examTitle} ${data.year}".toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(AdmitCardModel data) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 18,
                  child: Column(
                    children: [
                      _gridRow([
                        _gridCell(6, "Student's Name", isBold: true),
                        _gridCell(12, data.studentName, isCenter: true, borderRight: false),
                      ]),
                      _gridRow([
                        _gridCell(6, "Father's Name", isBold: true),
                        _gridCell(12, data.fatherName, isCenter: true, borderRight: false),
                      ]),
                      _gridRow([
                        _gridCell(6, "Class", isBold: true),
                        _gridCell(6, data.classId.toString(), isCenter: true),
                        _gridCell(3, "Section", isBold: true),
                        _gridCell(3, data.section, isCenter: true, borderRight: false),
                      ], borderBottom: false),
                    ],
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(left: BorderSide(color: Colors.black, width: 1)),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Center(
                      child: (data.photoUrl != null && data.photoUrl!.isNotEmpty)
                          ? Image.network(
                              data.photoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.person, size: 40, color: Colors.grey),
                            )
                          : const Icon(Icons.person, size: 40, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: Colors.black),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _gridCell(7, "Class Desc", isBold: true),
                _gridCell(6, data.className, isCenter: true),
                _gridCell(4, "G.R No.", isBold: true),
                _gridCell(4, data.grNo, isCenter: true),
                _gridCell(3, "Seat No.", isBold: true),
                _gridCell(3, data.seatNo.toString(), isCenter: true, borderRight: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _gridRow(List<Widget> cells, {bool borderBottom = true}) {
    return Container(
      decoration: borderBottom
          ? const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black, width: 1)),
            )
          : null,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: cells,
        ),
      ),
    );
  }

  Widget _gridCell(int flex, String text, {bool borderRight = true, bool isCenter = false, bool isBold = false}) {
    return Expanded(
      flex: flex,
      child: Container(
        decoration: borderRight
            ? const BoxDecoration(border: Border(right: BorderSide(color: Colors.black, width: 1)))
            : null,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        alignment: isCenter ? Alignment.center : Alignment.centerLeft,
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: 7,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildSignatures() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _signatureBox("Signature of Controller"),
          _signatureBox("Signature of Class Teacher"),
        ],
      ),
    );
  }

  Widget _signatureBox(String title) {
    return Column(
      children: [
        Container(width: 60, height: 1, color: Colors.black),
        const SizedBox(height: 8),
        Text(
          title,
          style: GoogleFonts.inter(fontSize: 6, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ],
    );
  }

  // --- PDF PART ---

  Future<void> _generatePdf(AdmitCardController controller) async {
    controller.isGeneratingPdf.value = true;
    try {
      final data = controller.admitCard.value!;
      final pdf = pw.Document();

      final interBold = pw.Font.helveticaBold();
      final interRegular = pw.Font.helvetica();
      final merriweatherBold = pw.Font.timesBold();
      final dancingScriptBold = pw.Font.timesBoldItalic();

      pw.MemoryImage? logoImage;
      try {
        final ByteData bytes = await rootBundle.load('assets/benchmark-logo.jpeg');
        logoImage = pw.MemoryImage(bytes.buffer.asUint8List());
      } catch (e) {}

      pw.MemoryImage? studentPhoto;
      if (data.photoUrl != null && data.photoUrl!.isNotEmpty) {
        try {
          final responseData = await NetworkAssetBundle(Uri.parse(data.photoUrl!)).load("");
          studentPhoto = pw.MemoryImage(responseData.buffer.asUint8List());
        } catch (e) {}
      }

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(30),
          build: (pw.Context context) {
            return pw.Container(
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                border: pw.Border.all(color: PdfColors.black, width: 2),
              ),
              padding: const pw.EdgeInsets.only(bottom: 20),
              child: pw.Column(
                children: [
                  _buildPdfHeader(data, logoImage, merriweatherBold, dancingScriptBold, interBold),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 20),
                    child: _buildPdfTable(data, interBold, interRegular, studentPhoto),
                  ),
                  pw.SizedBox(height: 60),
                  _buildPdfSignatures(interBold),
                ],
              ),
            );
          },
        ),
      );

      await Printing.sharePdf(bytes: await pdf.save(), filename: "${data.studentName}_AdmitCard.pdf");
    } finally {
      controller.isGeneratingPdf.value = false;
    }
  }

  pw.Widget _buildPdfHeader(AdmitCardModel data, pw.MemoryImage? logo, pw.Font titleFont, pw.Font subTitleFont, pw.Font boldFont) {
    return pw.Padding(
      padding: const pw.EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: pw.Column(
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Container(
                width: 100, height: 100,
                decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, border: pw.Border.all(color: PdfColors.black, width: 2)),
                child: logo != null ? pw.ClipOval(child: pw.Image(logo, fit: pw.BoxFit.cover)) : pw.SizedBox(),
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: pw.Column(
                  children: [
                    pw.Text("BENCHMARK", style: pw.TextStyle(font: titleFont, fontSize: 25, color: const PdfColor.fromInt(0xFF1E3A8A))),
                    pw.Text("School of Leadership", style: pw.TextStyle(font: subTitleFont, fontSize: 22, color: const PdfColor.fromInt(0xFF0284C7))),
                    pw.SizedBox(height: 8),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF1E293B), borderRadius: pw.BorderRadius.all(pw.Radius.circular(30))),
                      child: pw.Text("PLAY GROUP TO MATRIC", style: pw.TextStyle(font: boldFont, color: PdfColors.white, fontSize: 16)),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 110),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            "${data.examTitle} ${data.year}".toUpperCase(),
            style: pw.TextStyle(font: boldFont, fontSize: 18, color: PdfColors.black),
          ),
          pw.SizedBox(height: 10),
        ],
      ),
    );
  }

  pw.Widget _buildPdfTable(AdmitCardModel data, pw.Font boldFont, pw.Font regFont, pw.MemoryImage? studentPhoto) {
    return pw.Container(
      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 1.5)),
      child: pw.Column(
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 18,
                child: pw.Column(
                  children: [
                    _pdfGridRow([_pdfGridCell(6, "Student's Name", boldFont, isBold: true), _pdfGridCell(12, data.studentName, boldFont, isCenter: true, borderRight: false)]),
                    _pdfGridRow([_pdfGridCell(6, "Father's Name", boldFont, isBold: true), _pdfGridCell(12, data.fatherName, boldFont, isCenter: true, borderRight: false)]),
                    _pdfGridRow([
                      _pdfGridCell(6, "Class", boldFont, isBold: true), 
                      _pdfGridCell(6, data.classId.toString(), boldFont, isCenter: true), 
                      _pdfGridCell(3, "Section", boldFont, isBold: true), 
                      _pdfGridCell(3, data.section, boldFont, isCenter: true, borderRight: false)
                    ], borderBottom: false),
                  ],
                ),
              ),
              pw.Expanded(
                flex: 4,
                child: pw.Container(
                  height: 93,
                  decoration: const pw.BoxDecoration(border: pw.Border(left: pw.BorderSide(color: PdfColors.black, width: 1))),
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Center(
                    child: studentPhoto != null ? pw.Image(studentPhoto, fit: pw.BoxFit.cover) : pw.Text("PHOTO", style: pw.TextStyle(font: regFont, fontSize: 10)),
                  ),
                ),
              ),
            ],
          ),
          pw.Container(height: 1, color: PdfColors.black),
          pw.Row(
            children: [
              _pdfGridCell(7, "Class Desc", boldFont, isBold: true), 
              _pdfGridCell(6, data.className, boldFont, isCenter: true),
              _pdfGridCell(4, "G.R No.", boldFont, isBold: true),
              _pdfGridCell(4, data.grNo, boldFont, isCenter: true),
              _pdfGridCell(3, "Seat No.", boldFont, isBold: true),
              _pdfGridCell(3, data.seatNo.toString(), boldFont, isCenter: true, borderRight: false),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfGridRow(List<pw.Widget> cells, {bool borderBottom = true}) {
    return pw.Container(
      decoration: borderBottom ? const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1))) : null,
      child: pw.Row(children: cells),
    );
  }

  pw.Widget _pdfGridCell(int flex, String text, pw.Font font, {bool borderRight = true, bool isCenter = false, bool isBold = false}) {
    return pw.Expanded(
      flex: flex,
      child: pw.Container(
        decoration: borderRight ? const pw.BoxDecoration(border: pw.Border(right: pw.BorderSide(color: PdfColors.black, width: 1))) : null,
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        alignment: isCenter ? pw.Alignment.center : pw.Alignment.centerLeft,
        child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: 11, color: PdfColors.black)),
      ),
    );
  }

  pw.Widget _buildPdfSignatures(pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 40),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _pdfSignatureBox("Signature of Controller", font),
          _pdfSignatureBox("Signature of Class Teacher", font),
        ],
      ),
    );
  }

  pw.Widget _pdfSignatureBox(String title, pw.Font font) {
    return pw.Column(
      children: [
        pw.Container(width: 160, height: 1, color: PdfColors.black),
        pw.SizedBox(height: 8),
        pw.Text(title, style: pw.TextStyle(font: font, fontSize: 11)),
      ],
    );
  }
}