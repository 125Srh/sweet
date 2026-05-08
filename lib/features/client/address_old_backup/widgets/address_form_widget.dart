import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/address_provider.dart';
import '../../cart/provider/cart_provider.dart';
import '../../checkout/screen/checkout_screen.dart';



class AddressFormWidget extends StatelessWidget {
  const AddressFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return Consumer<AddressProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
          child: Form(
            key: provider.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // Título
                Text(
                  'Dirección de entrega',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 24 : 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFF1362),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Subtítulo
                Text(
                  'Completa tus datos para continuar',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: Colors.grey[600],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Campo: Dirección
                _buildInputField(
                  controller: provider.direccionController,
                  label: 'Dirección',
                  hint: 'Ej: Calle Los Pinos 123, Urb. Las Flores',
                  icon: Icons.location_on_outlined,
                  minLines: 2,
                  maxLines: 3,
                  isSmallScreen: isSmallScreen,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La dirección no puede estar vacía';
                    }
                    if (value.trim().length < 10) {
                      return 'La dirección debe tener mínimo 10 caracteres';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Campo: Referencias
                _buildInputField(
                  controller: provider.referenciasController,
                  label: 'Referencias',
                  hint: 'Ej: Frente al parque, Casa blanca con reja negra',
                  icon: Icons.info_outline,
                  minLines: 2,
                  maxLines: 3,
                  isSmallScreen: isSmallScreen,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Las referencias no pueden estar vacías';
                    }
                    if (value.trim().length < 15) {
                      return 'Las referencias deben tener mínimo 15 caracteres';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Campo: Celular
                _buildInputField(
                  controller: provider.celularController,
                  label: 'Celular',
                  hint: 'Ej: 987654321',
                  icon: Icons.phone_android_outlined,
                  keyboardType: TextInputType.phone,
                  isSmallScreen: isSmallScreen,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El celular no puede estar vacío';
                    }
                    if (value.trim().length < 8) {
                      return 'El celular debe tener mínimo 8 dígitos';
                    }
                    // Validar que solo sean números
                    if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
                      return 'Solo se permiten números';
                    }
                    return null;
                  },
                ),
                
                const Spacer(),
                
                // Botones
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: provider.isLoading
                            ? null
                            : () async {
                                final success = await provider.guardarDireccion();
                                if (success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('✅ Dirección guardada correctamente'),
                                      backgroundColor: Colors.green,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                } else if (context.mounted && provider.error != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('❌ Error: ${provider.error}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: isSmallScreen ? 14 : 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: provider.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Guardar dirección',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 14 : 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: provider.isLoading
                            ? null
                            : () {
                                if (provider.validateForm()) {
                                  // Obtener datos de dirección
                                  final addressData = {
                                    'direccion': provider.direccionController.text.trim(),
                                    'referencias': provider.referenciasController.text.trim(),
                                    'celular': provider.celularController.text.trim(),
                                  };
                                  
                                  // Obtener datos del carrito
                                  final cartProvider = context.read<CartProvider>();
                                  
                                  // Navegar al checkout
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CheckoutScreen(),
                                      settings: RouteSettings(
                                        arguments: {
                                          'subtotal': cartProvider.subtotal,
                                          'totalItems': cartProvider.totalItems,
                                          'items': cartProvider.items,
                                          'direccion': addressData,
                                        },
                                      ),
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF1362),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: isSmallScreen ? 14 : 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          'Continuar',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int minLines = 1,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    required bool isSmallScreen,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        minLines: minLines,
        maxLines: maxLines,
        keyboardType: keyboardType,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: isSmallScreen ? 12 : 14,
            color: Colors.grey[400],
          ),
          labelStyle: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFFF1362),
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFFFF1362),
            size: isSmallScreen ? 20 : 24,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFF1362), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12 : 16,
            vertical: isSmallScreen ? 12 : 14,
          ),
        ),
        validator: validator,
      ),
    );
  }
}