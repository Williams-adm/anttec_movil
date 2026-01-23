abstract final class Routes {
  static const splash = '/';
  static const login = '/login';
  static const home = '/home';
  static const scan = '/scan';
  static const cart = '/cart';
  static const finalizarVenta = '/finalizar-venta';

  // 🔥 NUEVA: Ruta relativa (sin slash al inicio) para usar dentro del Home
  static const productDetail = '/producto/:sku';
}
