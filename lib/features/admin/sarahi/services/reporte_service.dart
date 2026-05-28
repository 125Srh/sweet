import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../models/reporte_venta.dart';

class ReporteService {
  static final _db = Supabase.instance.client;

  // Obtener ventas en un rango de fechas con detalles y costo
  Future<List<ReporteVenta>> getVentasRango(DateTime inicio, DateTime fin) async {
    try {
      // 1. Obtener los pedidos con sus detalles
      final response = await _db
          .from('pedido')
          .select('*, pedido_detalle(*)')
          .or('estado.eq.recibido,estado.eq.pendiente')
          .gte('fecha_pedido', inicio.toIso8601String())
          .lte('fecha_pedido', fin.toIso8601String())
          .order('fecha_pedido', ascending: true);

      // 2. Obtener TODOS los productos para mapear el precio_adquisicion de forma segura
      final productosRes = await _db.from('producto').select('id, precio_adquisicion');
      final Map<String, double> mapaPreciosAdq = {};
      for (var p in productosRes) {
        mapaPreciosAdq[p['id'].toString()] = (p['precio_adquisicion'] as num?)?.toDouble() ?? 0.0;
      }

      // 3. Inyectar el precio de adquisición en el JSON antes de enviarlo al modelo
      final List<Map<String, dynamic>> listaPedidos = List<Map<String, dynamic>>.from(response);
      for (var pedido in listaPedidos) {
        if (pedido['pedido_detalle'] != null) {
          for (var detalle in pedido['pedido_detalle']) {
            final productoId = detalle['producto_id']?.toString();
            if (productoId != null) {
              detalle['producto'] = {
                'precio_adquisicion': mapaPreciosAdq[productoId] ?? 0.0
              };
            }
          }
        }
      }

      return listaPedidos.map((json) => ReporteVenta.fromJson(json)).toList();
    } catch (e) {
      print('Error al obtener ventas por rango: $e');
      rethrow;
    }
  }

  // Reporte agrupado por MES (Todo el Año)
  Future<List<ReporteAgrupado>> getReportePorAnio(int anio) async {
    final inicio = DateTime(anio, 1, 1);
    final fin = DateTime(anio, 12, 31, 23, 59, 59);
    final ventas = await getVentasRango(inicio, fin);
    
    final Map<int, ReporteAgrupado> agrupado = {};
    const meses = ['ENERO', 'FEBRERO', 'MARZO', 'ABRIL', 'MAYO', 'JUNIO', 'JULIO', 'AGOSTO', 'SEPTIEMBRE', 'OCTUBRE', 'NOVIEMBRE', 'DICIEMBRE'];

    for (var venta in ventas) {
      final mes = venta.fecha.month;

      if (!agrupado.containsKey(mes)) {
        agrupado[mes] = ReporteAgrupado(
          periodo: meses[mes - 1],
          cantidadVentas: 0,
          montoTotal: 0,
          costoInversion: 0,
        );
      }

      final actual = agrupado[mes]!;
      agrupado[mes] = ReporteAgrupado(
        periodo: meses[mes - 1],
        cantidadVentas: actual.cantidadVentas + 1,
        montoTotal: actual.montoTotal + venta.subtotal,
        costoInversion: actual.costoInversion + venta.costoInversion,
      );
    }

    var resultado = agrupado.entries.toList();
    resultado.sort((a, b) => a.key.compareTo(b.key));
    return resultado.map((e) => e.value).toList();
  }

  // Reporte agrupado por SEMANA (Un Mes específico)
  Future<List<ReporteAgrupado>> getReportePorMes(int anio, int mes) async {
    final inicio = DateTime(anio, mes, 1);
    final fin = DateTime(anio, mes + 1, 0, 23, 59, 59); // Último día del mes
    final ventas = await getVentasRango(inicio, fin);
    
    final Map<int, ReporteAgrupado> agrupado = {};

    // Precargar exactamente 4 semanas
    for (int i = 1; i <= 4; i++) {
      agrupado[i] = ReporteAgrupado(
        periodo: 'SEMANA $i',
        cantidadVentas: 0,
        montoTotal: 0,
        costoInversion: 0,
      );
    }

    for (var venta in ventas) {
      // Calcular a qué semana del mes pertenece (limitado a 4 semanas)
      final dia = venta.fecha.day;
      int semana = ((dia - 1) / 7).floor() + 1;
      if (semana > 4) semana = 4; // Los últimos días del mes entran en la semana 4

      final actual = agrupado[semana]!;
      agrupado[semana] = ReporteAgrupado(
        periodo: 'SEMANA $semana',
        cantidadVentas: actual.cantidadVentas + 1,
        montoTotal: actual.montoTotal + venta.subtotal,
        costoInversion: actual.costoInversion + venta.costoInversion,
      );
    }

    var resultado = agrupado.entries.toList();
    resultado.sort((a, b) => a.key.compareTo(b.key));
    return resultado.map((e) => e.value).toList();
  }

  // Reporte agrupado por DÍA (Un Mes específico)
  Future<List<ReporteAgrupado>> getReporteDiario(int anio, int mes) async {
    final inicio = DateTime(anio, mes, 1);
    final fin = DateTime(anio, mes + 1, 0, 23, 59, 59); // Último día del mes
    final ventas = await getVentasRango(inicio, fin);
    
    final Map<int, ReporteAgrupado> agrupado = {};

    for (var venta in ventas) {
      final dia = venta.fecha.day;

      if (!agrupado.containsKey(dia)) {
        agrupado[dia] = ReporteAgrupado(
          periodo: DateFormat('dd/MM/yyyy').format(venta.fecha),
          cantidadVentas: 0,
          montoTotal: 0,
          costoInversion: 0,
        );
      }

      final actual = agrupado[dia]!;
      agrupado[dia] = ReporteAgrupado(
        periodo: DateFormat('dd/MM/yyyy').format(venta.fecha),
        cantidadVentas: actual.cantidadVentas + 1,
        montoTotal: actual.montoTotal + venta.subtotal,
        costoInversion: actual.costoInversion + venta.costoInversion,
      );
    }

    var resultado = agrupado.entries.toList();
    resultado.sort((a, b) => a.key.compareTo(b.key));
    return resultado.map((e) => e.value).toList();
  }

  // Obtener reporte resumen general de una lista de agrupados
  ReporteResumen calcularResumen(List<ReporteAgrupado> reportes) {
    int totalVentas = 0;
    double montoTotal = 0;
    double costoInversion = 0;

    for (var r in reportes) {
      totalVentas += r.cantidadVentas;
      montoTotal += r.montoTotal;
      costoInversion += r.costoInversion;
    }

    return ReporteResumen(
      totalVentas: totalVentas,
      montoTotal: montoTotal,
      costoInversion: costoInversion,
    );
  }
}