import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class InvoiceService {
  Future<void> printInvoice({
    required String orderId,
    required String date,
    required String customerName,
    required String customerEmail,
    required String address,
    required String paymentMethod,
    required List<Map<String, dynamic>> products,
    required double subtotal,
    required double shipping,
    required double total,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'SWEET',
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.pink,
                  ),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'Tu tienda de belleza favorita',
                  style: pw.TextStyle(fontSize: 12, color: PdfColors.grey),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text(
                  'FACTURA ELECTRÓNICA',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 10),

              // Info pedido
              pw.Text('N° Pedido: $orderId'),
              pw.Text('Fecha: $date'),
              pw.SizedBox(height: 10),

              // Info cliente
              pw.Text(
                'DATOS DEL CLIENTE',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 5),
              pw.Text('Cliente: $customerName'),
              pw.Text('Email: $customerEmail'),
              pw.Text('Dirección: $address'),
              pw.Text('Método de pago: $paymentMethod'),
              pw.SizedBox(height: 15),

              // Productos
              pw.Text(
                'DETALLE DE PRODUCTOS',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),
              pw.Table.fromTextArray(
                headers: ['Producto', 'Cantidad', 'Precio Unit.', 'Subtotal'],
                data: products
                    .map(
                      (p) => [
                        p['name'],
                        '${p['quantity']}',
                        'Bs. ${p['price'].toStringAsFixed(2)}',
                        'Bs. ${(p['quantity'] * p['price']).toStringAsFixed(2)}',
                      ],
                    )
                    .toList(),
                border: pw.TableBorder.all(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
              ),
              pw.SizedBox(height: 20),

              // Totales
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Subtotal: Bs. ${subtotal.toStringAsFixed(2)}'),
                      pw.Text('Envío: Bs. ${shipping.toStringAsFixed(2)}'),
                      pw.Text(
                        'TOTAL: Bs. ${total.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  '¡Gracias por tu compra en Sweet!',
                  style: pw.TextStyle(fontSize: 12, color: PdfColors.grey),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'www.sweet.com | contacto@sweet.com',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'factura_$orderId.pdf',
    );
  }
}
