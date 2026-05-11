class ReporteVenta {
  final String id;
  final String pedidoId;
  final DateTime fecha;
  final double subtotal;
  final double costoEnvio;
  final double total;
  final String metodoPago;
  final String estado;

  ReporteVenta({
    required this.id,
    required this.pedidoId,
    required this.fecha,
    required this.subtotal,
    required this.costoEnvio,
    required this.total,
    required this.metodoPago,
    required this.estado,
  });

  factory ReporteVenta.fromJson(Map<String, dynamic> json) {
    return ReporteVenta(
      id: json['id'].toString(),
      pedidoId: (json['pedido_id'] ?? json['id']).toString(),
      fecha: DateTime.parse(json['fecha_pedido'] ?? json['created_at'] ?? json['fecha_creacion']),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      costoEnvio: (json['costo_envio'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      metodoPago: json['metodo_pago'] ?? '',
      estado: json['estado'] ?? 'pendiente',
    );
  }
}

class ReportePorMes {
  final int mes;
  final int anio;
  final int cantidadVentas;
  final double montoTotal;
  final double gananciaTotal;

  ReportePorMes({
    required this.mes,
    required this.anio,
    required this.cantidadVentas,
    required this.montoTotal,
    required this.gananciaTotal,
  });

  String get nombreMes {
    const meses = [
      'ENERO', 'FEBRERO', 'MARZO', 'ABRIL', 'MAYO', 'JUNIO',
      'JULIO', 'AGOSTO', 'SEPTIEMBRE', 'OCTUBRE', 'NOVIEMBRE', 'DICIEMBRE'
    ];
    return meses[mes - 1];
  }
}

class ReporteAnual {
  final int anio;
  final int totalVentas;
  final double montoTotal;
  final double gananciaTotal;

  ReporteAnual({
    required this.anio,
    required this.totalVentas,
    required this.montoTotal,
    required this.gananciaTotal,
  });
}