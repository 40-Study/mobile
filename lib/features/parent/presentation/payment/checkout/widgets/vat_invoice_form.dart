import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/parent_payment_model.dart';

class VatInvoiceForm extends StatefulWidget {
  const VatInvoiceForm({
    super.key,
    required this.onChanged,
  });

  final ValueChanged<VatInvoiceRequestInfo?> onChanged;

  @override
  State<VatInvoiceForm> createState() => _VatInvoiceFormState();
}

class _VatInvoiceFormState extends State<VatInvoiceForm> {
  bool _requestVat = false;
  final _companyController = TextEditingController();
  final _taxCodeController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _companyController.dispose();
    _taxCodeController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _notifyChange() {
    if (!_requestVat) {
      widget.onChanged(null);
      return;
    }
    final info = VatInvoiceRequestInfo(
      companyName: _companyController.text.trim(),
      taxCode: _taxCodeController.text.trim(),
      companyAddress: _addressController.text.trim(),
      email: _emailController.text.trim(),
    );
    widget.onChanged(info);
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 13.5),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 13,
                color: Color(0xFF94A3B8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFF1D4ED8),
                  width: 1.5,
                ),
              ),
            ),
            onChanged: (_) => _notifyChange(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Yêu cầu xuất hóa đơn GTGT (VAT)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Hóa đơn điện tử sẽ gửi về email trong 24h',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _requestVat,
                activeThumbColor: const Color(0xFF1D4ED8),
                onChanged: (val) {
                  setState(() => _requestVat = val);
                  _notifyChange();
                },
              ),
            ],
          ),
          if (_requestVat) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 0.5),
            const SizedBox(height: 14),
            _buildField(
              controller: _companyController,
              label: 'Tên công ty / Đơn vị',
              hint: 'VD: Công ty TNHH Giải pháp Giáo dục ABC',
            ),
            _buildField(
              controller: _taxCodeController,
              label: 'Mã số thuế (MST)',
              hint: 'VD: 0101234567',
              keyboardType: TextInputType.number,
            ),
            _buildField(
              controller: _addressController,
              label: 'Địa chỉ trụ sở theo ĐKKD',
              hint: 'VD: Tầng 5, Tòa nhà Landmark, Hà Nội',
            ),
            _buildField(
              controller: _emailController,
              label: 'Email nhận hóa đơn điện tử',
              hint: 'VD: ketoan@congty.com',
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ],
      ),
    );
  }
}
