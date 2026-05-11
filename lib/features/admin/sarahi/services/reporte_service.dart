import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/reporte_venta.dart';

class ReporteService {
  static final _db = Supabase.instance.client;

  // Obtener todas las ventas completadas
  Future<List<ReporteVenta>> getVentas() async {
    try {
      final response = await _db
          .from('pedido')
          .select()
          .or('estado.eq.completado,estado.eq.pendiente')
          .order('fecha_pedido', ascending: false);

      return response.map((json) => ReporteVenta.fromJson(json)).toList();
    } catch (e) {
      print('Error al obtener ventas: $e');
      rethrow;
    }
  }

  // Obtener ventas por año
  Future<List<ReporteVenta>> getVentasPorAnio(int anio) async {
    try {
      final inicio = DateTime(anio, 1, 1);
      final fin = DateTime(anio, 12, 31, 23, 59, 59);

      final response = await _db
          .from('pedido')
          .select()
          .or('estado.eq.completado,estado.eq.pendiente')
          .gte('fecha_pedido', inicio.toIso8601String())
          .lte('fecha_pedido', fin.toIso8601String())
          .order('fecha_pedido', ascending: true);

      return response.map((json) => ReporteVenta.fromJson(json)).toList();
    } catch (e) {
      print('Error al obtener ventas por año: $e');
      rethrow;
    }
  }

  // Obtener reporte agrupado por mes
  Future<List<ReportePorMes>> getReportePorMes(int anio) async {
    final ventas = await getVentasPorAnio(anio);
    final Map<String, ReportePorMes> reportePorMes = {};

    for (var venta in ventas) {
      final mes = venta.fecha.month;
      final key = '$anio-$mes';

      if (!reportePorMes.containsKey(key)) {
        reportePorMes[key] = ReportePorMes(
          mes: mes,
          anio: anio,
          cantidadVentas: 0,
          montoTotal: 0,
          gananciaTotal: 0,
        );
      }

      final actual = reportePorMes[key]!;
      final ganancia = venta.total * 0.7; // 70% ganancia estimada

      reportePorMes[key] = ReportePorMes(
        mes: mes,
        anio: anio,
        cantidadVentas: actual.cantidadVentas + 1,
        montoTotal: actual.montoTotal + venta.total,
        gananciaTotal: actual.gananciaTotal + ganancia,
      );
    }

    var resultado = reportePorMes.values.toList();
    resultado.sort((a, b) => a.mes.compareTo(b.mes));
    return resultado;
  }

  // Obtener reporte anual completo
  Future<ReporteAnual> getReporteAnual(int anio) async {
    final ventas = await getVentasPorAnio(anio);
    final totalVentas = ventas.length;
    final montoTotal = ventas.fold(0.0, (sum, v) => sum + v.total);
    final gananciaTotal = montoTotal * 0.7;

    return ReporteAnual(
      anio: anio,
      totalVentas: totalVentas,
      montoTotal: montoTotal,
      gananciaTotal: gananciaTotal,
    );
  }

  // Confirmar venta (cambiar estado a completado)
  Future<void> confirmarVenta(String pedidoId) async {
    try {
      await _db
          .from('pedido')
          .update({'estado': 'completado'})
          .eq('id', pedidoId);
    } catch (e) {
      throw Exception('Error al confirmar venta: $e');
    }
  }
}