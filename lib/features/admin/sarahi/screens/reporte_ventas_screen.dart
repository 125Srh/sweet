import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../services/reporte_service.dart';
import '../models/reporte_venta.dart';
import '../../home/widgets/admin_drawer.dart';

class ReporteVentasScreen extends StatefulWidget {
  const ReporteVentasScreen({super.key});

  @override
  State<ReporteVentasScreen> createState() => _ReporteVentasScreenState();
}

class _ReporteVentasScreenState extends State<ReporteVentasScreen> {
  final ReporteService _reporteService = ReporteService();

  String _tipoVista = 'Por Año (Mensual)';
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  List<ReporteAgrupado> _reportes = [];
  ReporteResumen? _resumen;
  bool _isLoading = true;
  String? _errorMessage;

  final List<int> _availableYears = [2023, 2024, 2025, 2026, 2027];
  final List<String> _tiposVista = [
    'Por Año (Mensual)',
    'Por Mes (Semanal)',
    'Por Mes (Diario)',
  ];
  final List<String> _mesesNombres = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  static const _pink = Color(0xFFFF69B4);

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
      List<ReporteAgrupado> reportes;
      if (_tipoVista == 'Por Año (Mensual)') {
        reportes = await _reporteService.getReportePorAnio(_selectedYear);
      } else if (_tipoVista == 'Por Mes (Semanal)') {
        reportes = await _reporteService.getReportePorMes(
          _selectedYear,
          _selectedMonth,
        );
      } else {
        reportes = await _reporteService.getReporteDiario(
          _selectedYear,
          _selectedMonth,
        );
      }

      final resumen = _reporteService.calcularResumen(reportes);

      setState(() {
        _reportes = reportes;
        _resumen = resumen;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar reportes: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshReportes() async {
    await _cargarReportes();
  }

  Future<void> _imprimirReporte() async {
    if (_resumen == null) return;
    final pdf = pw.Document();

    String tituloReporte = 'REPORTE DE VENTAS';
    if (_tipoVista == 'Por Año (Mensual)') {
      tituloReporte += ' - $_selectedYear';
    } else {
      tituloReporte += ' - ${_mesesNombres[_selectedMonth - 1]} $_selectedYear';
    }

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
                  tituloReporte,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text('Agrupación: $_tipoVista'),
                pw.Text(
                  'Generado: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now())}',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                ),
                pw.Divider(),
              ],
            ),
          ),
          pw.Table.fromTextArray(
            headers: [
              'PERIODO',
              'TOTAL PEDIDOS',
              'TOTAL RECAUDADO (Bs)',
              'GANANCIA (Bs)',
              'INVERSIÓN (Bs)',
            ],
            data: _reportes
                .map(
                  (r) => [
                    r.periodo,
                    '${r.cantidadVentas}',
                    r.montoTotal.toStringAsFixed(2),
                    r.gananciaBruta.toStringAsFixed(2),
                    r.costoInversion.toStringAsFixed(2),
                  ],
                )
                .toList(),
            border: pw.TableBorder.all(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignment: pw.Alignment.center,
          ),
          pw.SizedBox(height: 20),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'RESUMEN',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 8),
                pw.Text('Total Ventas: ${_resumen!.totalVentas}'),
                pw.Text(
                  'Total Recaudado: Bs. ${_resumen!.montoTotal.toStringAsFixed(2)}',
                ),
                pw.Text(
                  'Costo de Inversión: Bs. ${_resumen!.costoInversion.toStringAsFixed(2)}',
                ),
                pw.Text(
                  'Ganancia Bruta: Bs. ${_resumen!.gananciaBruta.toStringAsFixed(2)}',
                ),
              ],
            ),
          ),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'reporte_ventas_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      drawer: const AdminDrawer(selectedIndex: 3),
      appBar: AppBar(
        backgroundColor: _pink,
        elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: const Text(
          'Reportes de Ventas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          if (!_isLoading && _reportes.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.print, color: Colors.white),
              onPressed: _imprimirReporte,
              tooltip: 'Imprimir reporte',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshReportes,
        color: _pink,
        backgroundColor: Colors.white,
        child: Column(
          children: [
            _buildFiltros(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF69B4),
                      ),
                    )
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
                          Text('No hay ventas registradas para este periodo'),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildGrafica(),
                          const SizedBox(height: 24),
                          _buildTabla(),
                          const SizedBox(height: 24),
                          if (_resumen != null) _buildResumen(),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltros() {
    final showMonthSelector = _tipoVista != 'Por Año (Mensual)';

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      child: Column(
        children: [
          const Row(
            children: [
              Text(
                'Filtros de Reporte',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildDropdown<String>(
                value: _tipoVista,
                items: _tiposVista,
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _tipoVista = val);
                    _cargarReportes();
                  }
                },
              ),
              _buildDropdown<int>(
                value: _selectedYear,
                items: _availableYears,
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedYear = val);
                    _cargarReportes();
                  }
                },
              ),
              if (showMonthSelector)
                _buildDropdown<int>(
                  value: _selectedMonth,
                  items: List.generate(12, (i) => i + 1),
                  itemLabelBuilder: (val) => _mesesNombres[val - 1],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedMonth = val);
                      _cargarReportes();
                    }
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    String Function(T)? itemLabelBuilder,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFFF69B4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<T>(
        value: value,
        underline: const SizedBox(),
        isDense: true,
        items: items.map((item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(
              itemLabelBuilder != null
                  ? itemLabelBuilder(item)
                  : item.toString(),
            ),
          );
        }).toList(),
        onChanged: onChanged,
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
            'Gráfica de Ventas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD81B60),
            ),
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
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
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
                          reporte.periodo,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
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
            DataColumn(
              label: Text(
                'PERIODO',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'TOTAL PEDIDOS',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'TOTAL RECAUDADO',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'GANANCIA',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'PRECIO DE ADQUISICIÓN',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: _reportes.map((reporte) {
            return DataRow(
              cells: [
                DataCell(Text(reporte.periodo)),
                DataCell(Text('${reporte.cantidadVentas}')),
                DataCell(Text('Bs. ${reporte.montoTotal.toStringAsFixed(2)}')),
                DataCell(
                  Text(
                    'Bs. ${reporte.gananciaBruta.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataCell(
                  Text('Bs. ${reporte.costoInversion.toStringAsFixed(2)}'),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildResumen() {
    return Container(
      width: double.infinity,
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
            'RESUMEN DEL REPORTE',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD81B60),
            ),
          ),
          const SizedBox(height: 12),
          _buildResumenItem(
            'Total Ventas:',
            '${_resumen!.totalVentas} pedidos',
          ),
          _buildResumenItem(
            'Total Recaudado:',
            'Bs. ${_resumen!.montoTotal.toStringAsFixed(2)}',
            color: Colors.blue,
          ),
          _buildResumenItem(
            'Costo de Inversión:',
            'Bs. ${_resumen!.costoInversion.toStringAsFixed(2)}',
            color: Colors.red,
          ),
          const Divider(),
          _buildResumenItem(
            'Ganancia Bruta:',
            'Bs. ${_resumen!.gananciaBruta.toStringAsFixed(2)}',
            color: Colors.green,
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildResumenItem(
    String label,
    String value, {
    Color color = Colors.black87,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isBold ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 18 : 14,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
