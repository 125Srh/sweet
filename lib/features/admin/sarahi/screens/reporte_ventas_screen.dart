import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../services/reporte_service.dart';
import '../models/reporte_venta.dart';
import '../../home/widgets/admin_appbar.dart';
import '../../home/widgets/admin_drawer.dart';

class ReporteVentasScreen extends StatefulWidget {
  const ReporteVentasScreen({super.key});

  @override
  State<ReporteVentasScreen> createState() => _ReporteVentasScreenState();
}

class _ReporteVentasScreenState extends State<ReporteVentasScreen> {
  final ReporteService _reporteService = ReporteService();
  int _selectedYear = DateTime.now().year;
  List<ReportePorMes> _reportes = [];
  bool _isLoading = true;
  String? _errorMessage;

  final List<int> _availableYears = [2023, 2024, 2025, 2026, 2027];

  @override
  void initState() {
    super.initState();
    _cargarReportes();
  }

  Future<void> _cargarReportes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final reportes = await _reporteService.getReportePorMes(_selectedYear);
      setState(() {
        _reportes = reportes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar reportes: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _imprimirReporte() async {
    final pdf = pw.Document();
    final reporteAnual = await _reporteService.getReporteAnual(_selectedYear);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        orientation: pw.PageOrientation.landscape,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'REPORTE DE VENTAS',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Text('Año: $_selectedYear'),
                pw.Text(
                  'Generado: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now())}',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                ),
                pw.Divider(),
              ],
            ),
          ),
          pw.Table.fromTextArray(
            headers: ['MES', 'VENTAS', 'MONTO (Bs)'],
            data: _reportes.map((r) => [
              r.nombreMes,
              '${r.cantidadVentas}',
              r.montoTotal.toStringAsFixed(2),
            ]).toList(),
            border: pw.TableBorder.all(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignment: pw.Alignment.center,
          ),
          pw.SizedBox(height: 20),
          pw.Container(
            padding: pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('RESUMEN ANUAL', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Text('Total Ventas: ${reporteAnual.totalVentas}'),
                pw.Text('Monto Total: Bs. ${reporteAnual.montoTotal.toStringAsFixed(2)}'),
              ],
            ),
          ),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'reporte_ventas_$_selectedYear.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBar(),
      drawer: const AdminDrawer(selectedIndex: 4),
      backgroundColor: const Color(0xFFFFF0F5),
      body: Column(
        children: [
          _buildSelectorAnio(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF69B4)))
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, color: Colors.red, size: 60),
                            const SizedBox(height: 16),
                            Text(_errorMessage!),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _cargarReportes,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF69B4),
                              ),
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      )
                    : _reportes.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.bar_chart, size: 60, color: Colors.grey),
                                SizedBox(height: 16),
                                Text('No hay ventas registradas para este año'),
                              ],
                            ),
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _buildGrafica(),
                                const SizedBox(height: 24),
                                _buildTabla(),
                                const SizedBox(height: 24),
                                _buildResumenAnual(),
                              ],
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorAnio() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Seleccionar año:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              if (!_isLoading && _reportes.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.print, color: Color(0xFFD81B60)),
                  onPressed: _imprimirReporte,
                  tooltip: 'Imprimir reporte',
                ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFFF69B4)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<int>(
                  value: _selectedYear,
                  underline: const SizedBox(),
                  items: _availableYears.map((year) {
                    return DropdownMenuItem(
                      value: year,
                      child: Text(year.toString()),
                    );
                  }).toList(),
                  onChanged: (year) {
                    if (year != null) {
                      setState(() {
                        _selectedYear = year;
                      });
                      _cargarReportes();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGrafica() {
    final maxMonto = _reportes.isEmpty
        ? 1.0
        : _reportes.map((r) => r.montoTotal).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gráfica de Ventas por Mes',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFD81B60)),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: _reportes.map((reporte) {
                  final altura = (reporte.montoTotal / maxMonto) * 180;
                  return Container(
                    width: 70,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Bs. ${reporte.montoTotal.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: altura,
                          width: 40,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Color(0xFFFF69B4), Color(0xFFFF1493)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          reporte.nombreMes,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabla() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 20,
          headingRowColor: WidgetStateProperty.all(const Color(0xFFFFF0F5)),
          columns: const [
            DataColumn(label: Text('MES', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('CANTIDAD', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('MONTO TOTAL', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: _reportes.map((reporte) {
            return DataRow(cells: [
              DataCell(Text(reporte.nombreMes)),
              DataCell(Text('${reporte.cantidadVentas}')),
              DataCell(Text('Bs. ${reporte.montoTotal.toStringAsFixed(2)}')),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildResumenAnual() {
    final totalVentas = _reportes.fold(0, (sum, r) => sum + r.cantidadVentas);
    final montoTotal = _reportes.fold(0.0, (sum, r) => sum + r.montoTotal);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RESUMEN ANUAL',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFD81B60)),
          ),
          const SizedBox(height: 12),
          _buildResumenItem('Total Ventas:', '$totalVentas'),
          _buildResumenItem('Monto Total:', 'Bs. ${montoTotal.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  Widget _buildResumenItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 14, color: Color(0xFFD81B60), fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}