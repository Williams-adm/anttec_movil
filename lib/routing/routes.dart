abstract final class Routes {
  static const splash = '/';
  static const login = '/login';
  static const home = '/home';
  static const scan = '/scan';
  static const cart = '/cart';

  // ✅ Puedes usar esta que ya tienes o agregar 'checkout' abajo
  static const finalizarVenta = '/finalizar-venta';

  // Agrega esta si quieres seguir el nombre que usamos en el código anterior:
  static const checkout = '/checkout';

  // 🔥 NUEVA: Ruta relativa
  static const productDetail = '/producto/:sku';
}
