import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:anttec_movil/app/core/styles/colors.dart';

// --- A. INPUT PERSONALIZADO (MEJORADO PARA BORDES) ---
class BoletaInputField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final bool isNumeric;
  final int? maxLength;
  final Color? borderColor; // ✅ NUEVO: Color de borde opcional

  const BoletaInputField({
    super.key,
    required this.label,
    required this.icon,
    required this.controller,
    this.isNumeric = false,
    this.maxLength,
    this.borderColor, // ✅
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        maxLength: maxLength,
        inputFormatters: [
          if (isNumeric) FilteringTextInputFormatter.digitsOnly,
          if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
        ],
        decoration: InputDecoration(
          counterText: "",
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primaryP),
          filled: true,
          fillColor: AppColors.primaryS,
          // ✅ LÓGICA DE BORDE (Si borderColor no es null, se pinta)
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: borderColor != null
                ? BorderSide(color: borderColor!, width: 1.5)
                : BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: borderColor != null
                ? BorderSide(color: borderColor!, width: 1.5)
                : BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: borderColor != null
                ? BorderSide(color: borderColor!, width: 2.0)
                : const BorderSide(color: AppColors.primaryP, width: 2.0),
          ),
        ),
      ),
    );
  }
}

// --- B. SELECTOR DNI / CE ---
class ClientHeaderSection extends StatelessWidget {
  final String tipoDocumento;
  final Function(String) onTypeChanged;
  final TextEditingController docController;
  final bool isSearching;
  final VoidCallback onSearch;

  const ClientHeaderSection({
    super.key,
    required this.tipoDocumento,
    required this.onTypeChanged,
    required this.docController,
    required this.isSearching,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.primaryS,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(children: [_buildTypeBtn("DNI"), _buildTypeBtn("CE")]),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: BoletaInputField(
                label:
                    tipoDocumento == 'DNI' ? "DNI (8 dígitos)" : "Carnet Ext.",
                icon: Symbols.badge,
                controller: docController,
                isNumeric: true,
                maxLength: tipoDocumento == 'DNI' ? 8 : 12,
              ),
            ),
            if (tipoDocumento == 'DNI') ...[
              const SizedBox(width: 10),
              GestureDetector(
                onTap: isSearching ? null : onSearch,
                child: Container(
                  margin: const EdgeInsets.only(top: 15),
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primaryP,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: isSearching
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Symbols.search, color: Colors.white),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildTypeBtn(String type) {
    bool isSelected = tipoDocumento == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTypeChanged(type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryP : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              type,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.semidarkT,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- C. MÉTODOS DE PAGO ---
class PaymentMethodsSelector extends StatelessWidget {
  final String selectedPayment;
  final Function(String) onPaymentChanged;

  const PaymentMethodsSelector({
    super.key,
    required this.selectedPayment,
    required this.onPaymentChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildCard("Efectivo", Symbols.payments, 'efectivo'),
        const SizedBox(width: 10),
        _buildCard("Digital", Symbols.qr_code_scanner, 'yape'),
        const SizedBox(width: 10),
        _buildCard("Otros", Symbols.more_horiz, 'otros'),
      ],
    );
  }

  Widget _buildCard(String title, IconData icon, String value) {
    bool isSelected = selectedPayment == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onPaymentChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryP : AppColors.primaryS,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? AppColors.primaryP : AppColors.tertiaryS,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : AppColors.primaryP),
              const SizedBox(height: 5),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.extradarkT,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- D. PANELES DE PAGO ---

class CashPaymentPanel extends StatelessWidget {
  final TextEditingController controller;
  final double total;
  final double vuelto;
  final Function(String) onChanged;

  const CashPaymentPanel({
    super.key,
    required this.controller,
    required this.total,
    required this.vuelto,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryS,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryP.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*[\.,]?\d*')),
            ],
            onChanged: onChanged,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryP,
            ),
            decoration: const InputDecoration(
              hintText: "0.00",
              labelText: "EFECTIVO RECIBIDO",
              border: InputBorder.none,
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "VUELTO:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkT,
                ),
              ),
              Text(
                "S/. ${vuelto.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: vuelto > 0 ? Colors.green[700] : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DigitalWalletPanel extends StatelessWidget {
  final String selectedWallet;
  final Function(String) onWalletChanged;
  final bool isLoadingQr;
  final String? qrImageUrl;
  final TextEditingController opController;

  const DigitalWalletPanel({
    super.key,
    required this.selectedWallet,
    required this.onWalletChanged,
    required this.isLoadingQr,
    required this.qrImageUrl,
    required this.opController,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Determinar longitud máxima visualmente
    int maxLen = selectedWallet == 'yape' ? 8 : 7;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryS,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildChip("Yape", 'yape'),
              const SizedBox(width: 10),
              _buildChip("Plin", 'plin'),
            ],
          ),
          const SizedBox(height: 20),
          if (isLoadingQr)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: CircularProgressIndicator(),
            )
          else if (qrImageUrl != null)
            Padding(
              padding: const EdgeInsets.all(10),
              child: CachedNetworkImage(
                imageUrl: qrImageUrl!,
                height: 180,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) =>
                    const Icon(Symbols.broken_image, size: 80),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Icon(Symbols.qr_code_2, size: 80, color: Colors.grey),
            ),

          // ✅ INPUT CON BORDE NEGRO Y LONGITUD DINÁMICA
          BoletaInputField(
            label: "Nro. Operación",
            icon: Symbols.receipt_long,
            controller: opController,
            isNumeric: true,
            maxLength: maxLen,
            borderColor: Colors.black, // Borde negro solicitado
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, String value) {
    bool isSelected = selectedWallet == value;
    return Expanded(
      child: ActionChip(
        label: Text(label),
        onPressed: () => onWalletChanged(value),
        backgroundColor:
            isSelected ? AppColors.primaryP.withValues(alpha: 0.2) : null,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primaryP : AppColors.semidarkT,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class OtherPaymentPanel extends StatelessWidget {
  final String selectedType;
  final Function(String) onTypeChanged;
  final TextEditingController refController;

  const OtherPaymentPanel({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
    required this.refController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryS,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tipo de Transacción",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.semidarkT,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              _buildChip("Tarjeta", Symbols.credit_card, "card"),
              const SizedBox(width: 12),
              _buildChip("Transf.", Symbols.account_balance, "transfers"),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildChip("Depósito", Symbols.savings, "deposits"),
              const SizedBox(width: 12),
              _buildChip("Otros", Symbols.confirmation_number, "others"),
            ],
          ),
          BoletaInputField(
            label: "Referencia",
            icon: Symbols.receipt_long,
            controller: refController,
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, IconData icon, String value) {
    bool isSelected = selectedType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTypeChanged(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryP : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primaryP : Colors.grey.shade300,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : AppColors.semidarkT,
              ),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.semidarkT,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- E. RESUMEN DE MONTO ---
class AmountSummary extends StatelessWidget {
  final double total;
  const AmountSummary({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryS,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Monto Final:",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.semidarkT,
            ),
          ),
          Text(
            "S/. ${total.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryP,
            ),
          ),
        ],
      ),
    );
  }
}

// --- F. FOOTER Y BOTÓN FINAL ---
class BoletaFooter extends StatelessWidget {
  final double total;
  final bool isProcessing;
  final VoidCallback onProcess;

  const BoletaFooter({
    super.key,
    required this.total,
    required this.isProcessing,
    required this.onProcess,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: isProcessing ? null : onProcess,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryP,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: isProcessing
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : const Text(
                "REALIZAR VENTA",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
      ),
    );
  }
}
