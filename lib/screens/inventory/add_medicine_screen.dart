import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/medicine_model.dart';
import '../../providers/medicine_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_textfield.dart';
import '../../core/utils/date_utils.dart';

class AddMedicineScreen extends StatefulWidget {
  final Medicine? existing; // null → add mode, non-null → edit mode

  const AddMedicineScreen({super.key, this.existing});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _category;
  late final TextEditingController _quantity;
  late final TextEditingController _price;
  late final TextEditingController _threshold;
  late final TextEditingController _expiryCtrl;
  DateTime? _expiryDate;
  bool _loading = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final m = widget.existing;
    _name = TextEditingController(text: m?.name ?? '');
    _category = TextEditingController(text: m?.category ?? '');
    _quantity = TextEditingController(text: m?.quantity.toString() ?? '');
    _price = TextEditingController(text: m?.price.toString() ?? '');
    _threshold =
        TextEditingController(text: m?.lowStockThreshold.toString() ?? '10');
    _expiryDate = m?.expiryDate;
    _expiryCtrl = TextEditingController(
        text: m != null ? AppDateUtils.format(m.expiryDate) : '');
  }

  @override
  void dispose() {
    for (var c in [_name, _category, _quantity, _price, _threshold, _expiryCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickExpiry() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _expiryDate = picked;
        _expiryCtrl.text = AppDateUtils.format(picked);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select expiry date')));
      return;
    }

    setState(() => _loading = true);

    final medicine = Medicine(
      id: _isEdit ? widget.existing!.id : const Uuid().v4(),
      name: _name.text.trim(),
      category: _category.text.trim(),
      quantity: int.parse(_quantity.text.trim()),
      price: double.parse(_price.text.trim()),
      expiryDate: _expiryDate!,
      lowStockThreshold: int.tryParse(_threshold.text.trim()) ?? 10,
    );

    final prov = context.read<MedicineProvider>();
    if (_isEdit) {
      await prov.updateMedicine(medicine);
    } else {
      await prov.addMedicine(medicine);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Medicine' : 'Add Medicine',
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                label: 'Medicine Name',
                controller: _name,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Category',
                controller: _category,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Quantity',
                      controller: _quantity,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      label: 'Price (₦)',
                      controller: _price,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Low Stock Threshold',
                controller: _threshold,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                hint: 'Default: 10',
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Expiry Date',
                controller: _expiryCtrl,
                readOnly: true,
                onTap: _pickExpiry,
                prefixIcon: const Icon(Icons.calendar_today_outlined),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 28),
              CustomButton(
                label: _isEdit ? 'Update Medicine' : 'Add Medicine',
                onPressed: _submit,
                isLoading: _loading,
                icon: _isEdit ? Icons.save : Icons.add,
              ),
            ],
          ),
        ),
      ),
    );
  }
}