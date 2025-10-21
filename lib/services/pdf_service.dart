import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/material.dart';
import '../models/word_study_model.dart';

class PDFService {
  static Future<void> generateAndSharePDF(
    WordStudy wordStudy,
    BuildContext context,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.only(
          top: 60,
          bottom: 60,
          left: 50,
          right: 50,
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(wordStudy),
              pw.SizedBox(height: 30),
              _buildPassageSection(wordStudy),
              pw.SizedBox(height: 25),
              _buildWordSection(wordStudy),
              pw.SizedBox(height: 25),
              _buildDefinitionSection(wordStudy),
              pw.SizedBox(height: 25),
              _buildCrossReferencesSection(wordStudy),
              pw.SizedBox(height: 25),
              _buildNotesSection(wordStudy),
              pw.Spacer(),
              _buildFooter(wordStudy),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Word Study - ${wordStudy.selectedWord}',
    );
  }

  static pw.Widget _buildHeader(WordStudy wordStudy) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 20),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.blue800, width: 3),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Word Study',
            style: pw.TextStyle(
              fontSize: 32,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              pw.Text(
                'Created: ${_formatDate(wordStudy.createdAt)}',
                style: pw.TextStyle(fontSize: 14, color: PdfColors.grey600),
              ),
              pw.Spacer(),
              pw.Text(
                'Word Study App',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey500,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPassageSection(WordStudy wordStudy) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(width: 4, height: 20, color: PdfColors.blue600),
              pw.SizedBox(width: 12),
              pw.Text(
                'Bible Passage',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            wordStudy.passageReference,
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
          if (wordStudy.lessonName != null) ...[
            pw.SizedBox(height: 8),
            pw.Text(
              'Lesson: ${wordStudy.lessonName}',
              style: pw.TextStyle(
                fontSize: 14,
                color: PdfColors.grey600,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          ],
          if (wordStudy.studySource != null) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              'Source: ${wordStudy.studySource}',
              style: pw.TextStyle(fontSize: 12, color: PdfColors.grey500),
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildWordSection(WordStudy wordStudy) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        border: pw.Border.all(color: PdfColors.blue200),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(width: 4, height: 20, color: PdfColors.blue600),
              pw.SizedBox(width: 12),
              pw.Text(
                'Selected Word',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              border: pw.Border.all(color: PdfColors.blue300),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Text(
              wordStudy.selectedWord,
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildDefinitionSection(WordStudy wordStudy) {
    if (wordStudy.chosenDefinition == null) return pw.Container();

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.green50,
        border: pw.Border.all(color: PdfColors.green200),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(width: 4, height: 20, color: PdfColors.green600),
              pw.SizedBox(width: 12),
              pw.Text(
                'Definition',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.green800,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              border: pw.Border.all(color: PdfColors.green300),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Text(
              wordStudy.chosenDefinition!,
              style: pw.TextStyle(
                fontSize: 15,
                color: PdfColors.grey800,
                height: 1.4,
              ),
            ),
          ),
          if (wordStudy.definitionSource != null) ...[
            pw.SizedBox(height: 8),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: pw.BoxDecoration(
                color: PdfColors.green100,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Text(
                'Source: ${wordStudy.definitionSource}',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.green700,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildCrossReferencesSection(WordStudy wordStudy) {
    if (wordStudy.crossReferences == null ||
        wordStudy.crossReferences!.isEmpty) {
      return pw.Container();
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.orange50,
        border: pw.Border.all(color: PdfColors.orange200),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(width: 4, height: 20, color: PdfColors.orange600),
              pw.SizedBox(width: 12),
              pw.Text(
                'Cross References',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.orange800,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              border: pw.Border.all(color: PdfColors.orange300),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: wordStudy.crossReferences!
                  .map(
                    (ref) => pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 6),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Container(
                            margin: const pw.EdgeInsets.only(top: 6, right: 8),
                            width: 6,
                            height: 6,
                            decoration: const pw.BoxDecoration(
                              color: PdfColors.orange500,
                              shape: pw.BoxShape.circle,
                            ),
                          ),
                          pw.Expanded(
                            child: pw.Text(
                              ref,
                              style: pw.TextStyle(
                                fontSize: 14,
                                color: PdfColors.grey800,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildNotesSection(WordStudy wordStudy) {
    if (wordStudy.notes == null && wordStudy.refinedDefinition == null) {
      return pw.Container();
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.purple50,
        border: pw.Border.all(color: PdfColors.purple200),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(width: 4, height: 20, color: PdfColors.purple600),
              pw.SizedBox(width: 12),
              pw.Text(
                'Notes & Refined Definition',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.purple800,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          if (wordStudy.notes != null) ...[
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                border: pw.Border.all(color: PdfColors.purple300),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Personal Notes:',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.purple700,
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    wordStudy.notes!,
                    style: pw.TextStyle(
                      fontSize: 14,
                      color: PdfColors.grey800,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 12),
          ],
          if (wordStudy.refinedDefinition != null) ...[
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                border: pw.Border.all(color: PdfColors.purple300),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Refined Definition:',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.purple700,
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    wordStudy.refinedDefinition!,
                    style: pw.TextStyle(
                      fontSize: 14,
                      color: PdfColors.grey800,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(WordStudy wordStudy) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 20),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey300, width: 1),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Generated by Word Study App',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey500,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
          pw.Text(
            'Page 1',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
