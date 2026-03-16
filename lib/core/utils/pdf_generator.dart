// lib/core/utils/pdf_generator.dart

import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:marcat/models/sale_model.dart';
import 'package:marcat/models/sale_item_model.dart';
import 'package:marcat/models/store_model.dart';
import '../extensions/currency_extensions.dart';

class PdfGenerator {
  PdfGenerator._();

  /// Generate a thermal-style PDF receipt and return the raw bytes.
  static Future<Uint8List> generateReceipt({
    required SaleModel sale,
    required List<SaleItemModel> items,
    required StoreModel store,
    int? loyaltyEarned,
  }) async {
    final doc = pw.Document();

    final regular = await PdfGoogleFonts.notoSansArabicRegular();
    final bold = await PdfGoogleFonts.notoSansArabicBold();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            // ── Store header ─────────────────────────────────────────────────
            pw.Text(
              'MARCAT',
              style: pw.TextStyle(font: bold, fontSize: 24, letterSpacing: 4),
            ),
            pw.SizedBox(height: 4),
            pw.Text(store.name,
                style: pw.TextStyle(font: regular, fontSize: 12)),
            if (store.location != null)
              pw.Text(
                store.location!,
                style: pw.TextStyle(font: regular, fontSize: 10),
                textAlign: pw.TextAlign.center,
              ),
            if (store.phone != null)
              pw.Text(store.phone!,
                  style: pw.TextStyle(font: regular, fontSize: 10)),
            pw.SizedBox(height: 12),
            _divider(),
            pw.SizedBox(height: 8),

            // ── Reference & date ─────────────────────────────────────────────
            _row(bold, regular, 'Reference', sale.referenceNumber,
                fontSize: 11),
            _row(bold, regular, 'Date', _formatDate(sale.createdAt),
                fontSize: 11),
            pw.SizedBox(height: 8),
            _divider(),
            pw.SizedBox(height: 8),

            // ── Line items ───────────────────────────────────────────────────
            ...items.map((item) => _itemRow(regular, bold, item)),

            pw.SizedBox(height: 8),
            _divider(),
            pw.SizedBox(height: 8),

            // ── Totals ───────────────────────────────────────────────────────
            _row(bold, regular, 'Subtotal', sale.subtotal.toJOD()),
            if (sale.discountTotal > 0)
              _row(bold, regular, 'Discount', '-${sale.discountTotal.toJOD()}'),
            if (sale.taxTotal > 0)
              _row(bold, regular, 'Tax', sale.taxTotal.toJOD()),
            if (sale.shippingCost > 0)
              _row(bold, regular, 'Shipping', sale.shippingCost.toJOD()),
            pw.SizedBox(height: 4),
            _divider(),
            pw.SizedBox(height: 4),
            _row(bold, bold, 'TOTAL', sale.grandTotal.toJOD(), fontSize: 14),

            pw.SizedBox(height: 8),

            // ── Loyalty earned badge ─────────────────────────────────────────
            if (loyaltyEarned != null && loyaltyEarned > 0)
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.amber),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  '★ You earned $loyaltyEarned loyalty points!',
                  style: pw.TextStyle(font: bold, fontSize: 11),
                  textAlign: pw.TextAlign.center,
                ),
              ),

            pw.SizedBox(height: 16),
            _divider(),
            pw.SizedBox(height: 12),

            // ── Thank you ────────────────────────────────────────────────────
            pw.Text(
              'Thank you for shopping with us!',
              style: pw.TextStyle(font: bold, fontSize: 12),
              textAlign: pw.TextAlign.center,
            ),
            pw.Text(
              'شكراً لتسوقك معنا!',
              style: pw.TextStyle(font: bold, fontSize: 12),
              textAlign: pw.TextAlign.center,
            ),

            pw.SizedBox(height: 16),

            // ── Barcode ──────────────────────────────────────────────────────
            pw.BarcodeWidget(
              barcode: pw.Barcode.code128(),
              data: sale.referenceNumber,
              width: 160,
              height: 48,
            ),
            pw.SizedBox(height: 4),
            pw.Text(sale.referenceNumber,
                style: pw.TextStyle(font: regular, fontSize: 9)),
          ],
        ),
      ),
    );

    return doc.save();
  }

  /// Print a receipt directly to a connected thermal printer.
  static Future<void> printReceipt({
    required SaleModel sale,
    required List<SaleItemModel> items,
    required StoreModel store,
    int? loyaltyEarned,
  }) async {
    final bytes = await generateReceipt(
      sale: sale,
      items: items,
      store: store,
      loyaltyEarned: loyaltyEarned,
    );
    await Printing.layoutPdf(onLayout: (_) => bytes);
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  static pw.Widget _divider() => pw.Divider(color: PdfColors.grey400);

  static pw.Widget _row(
    pw.Font labelFont,
    pw.Font valueFont,
    String label,
    String value, {
    double fontSize = 12,
  }) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(label,
                style: pw.TextStyle(font: labelFont, fontSize: fontSize)),
            pw.Text(value,
                style: pw.TextStyle(font: valueFont, fontSize: fontSize)),
          ],
        ),
      );

  static pw.Widget _itemRow(pw.Font regular, pw.Font bold, SaleItemModel item) {
    final name = item.productName ?? 'Item #${item.productId}';
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(name, style: pw.TextStyle(font: regular, fontSize: 10)),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                '${item.quantity} \u00D7 ${item.unitPrice.toJOD()}',
                style: pw.TextStyle(font: regular, fontSize: 10),
              ),
              pw.Text(
                (item.unitPrice * item.quantity).toJOD(),
                style: pw.TextStyle(font: bold, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime dt) {
    final y = dt.year;
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/$y $h:$min';
  }
}
