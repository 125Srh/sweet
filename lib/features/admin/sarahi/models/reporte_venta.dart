class ReporteVenta {
  final String id;
  final String pedidoId;
  final DateTime fecha;
  final double subtotal;
  final double costoEnvio;
  final double total;
  final double costoInversion; // Novedad: para calcular ganancia
  final String metodoPago;
  final String estado;

  ReporteVenta({
    required this.id,
    required this.pedidoId,
    required this.fecha,
    required this.subtotal,
    required this.costoEnvio,
    required this.total,
    required this.costoInversion,
    required this.metodoPago,
    required this.estado,
  });

  factory ReporteVenta.fromJson(Map<String, dynamic> json) {
    double costoInv = 0.0;
    if (json['pedido_detalle'] != null) {
      for (var detalle in json['pedido_detalle']) {
        final cantidad = (detalle['cantidad'] as num?)?.toInt() ?? 0;
        final productoObj = detalle['producto'];
        
        double precioAdq = 0.0;
        if (productoObj is List && productoObj.isNotEmpty) {
          precioAdq = (productoObj.first['precio_adquisicion'] as num?)?.toDouble() ?? 0.0;
        } else if (productoObj is Map) {
          precioAdq = (productoObj['precio_adquisicion'] as num?)?.toDouble() ?? 0.0;
        }
        
        costoInv += (cantidad * precioAdq);
      }
    }

    return ReporteVenta(
      id: json['id'].toString(),
      pedidoId: (json['pedido_id'] ?? json['id']).toString(),
      fecha: DateTime.parse(json['fecha_pedido'] ?? json['created_at'] ?? json['fecha_creacion']),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      costoEnvio: (json['costo_envio'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      costoInversion: costoInv,
      metodoPago: json['metodo_pago'] ?? '',
      estado: json['estado'] ?? 'pendiente',
    );
  }
}

class ReporteAgrupado {
  final String periodo;
  final int cantidadVentas;
  final double montoTotal; // Total Recaudado
  final double costoInversion;
  
  ReporteAgrupado({
    required this.periodo,
    required this.cantidadVentas,
    required this.montoTotal,
    required this.costoInversion,
  });

  double get gananciaBruta => montoTotal - costoInversion;
}

class ReporteResumen {
  final int totalVentas;
  final double montoTotal; // Total Recaudado
  final double costoInversion;

  ReporteResumen({
    required this.totalVentas,
    required this.montoTotal,
    required this.costoInversion,
  });

  double get gananciaBruta => montoTotal - costoInversion;
}