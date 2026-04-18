import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/medicine_model.dart';
import '../../providers/medicine_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_textfield.dart';
import '../../core/utils/date_utils.dart';

class AddMedicineScreen extends StatefulWidget {
  final Medicine? medicine;
  const AddMedicineScreen({super.key, this.medicine});

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
  DateTime? _expiryDate;
  bool _isLoading = false;

  bool get _isEdit => widget.medicine != null;

  @override
  void initState() {
    super.initState();
    final m = widget.medicine;
    _name = TextEditingController(text: m?.name ?? '');
    _category = TextEditingController(text: m?.category ?? '');
    _quantity =
        TextEditingController(text: m?.quantity.toString() ?? '');
    _price = TextEditingController(text: m?.price.toString() ?? '');
    _threshold = TextEditingController(
        text: m?.lowStockThreshold.toString() ?? '10');
    _expiryDate = m?.expiryDate;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ??
          DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _expiryDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select expiry date')));
      return;
    }
    setState(() => _isLoading = true);

    final medicine = Medicine(
      id: _isEdit ? widget.medicine!.id : const Uuid().v4(),
      name: _name.text.trim(),
      category: _category.text.trim(),
      quantity: int.parse(_quantity.text),
      price: double.parse(_price.text),
      expiryDate: _expiryDate!,
      lowStockThreshold: int.parse(_threshold.text),
    );

    final provider = context.read<MedicineProvider>();
    if (_isEdit) {
      await provider.updateMedicine(medicine);
    } else {
      await provider.addMedicine(medicine);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(title: Text(_isEdit ? 'Edit Medicine' : 'Add Medicine')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                label: 'Medicine Name',
                controller: _name,
               // prefixIcon: Icons.medical_services,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Category',
                controller: _category,
               // prefixIcon: Icons.label,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Quantity',
                controller: _quantity,
               // prefixIcon: Icons.format_list_numbered,
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Price (৳)',
                controller: _price,
               // prefixIcon: Icons.money,
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Low Stock Threshold',
                controller: _threshold,
                //prefixIcon: Icons.warning,
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: Colors.grey),
                      const SizedBox(width: 12),
                      Text(
                        _expiryDate != null
                            ? 'Expiry: ${AppDateUtils.format(_expiryDate!)}'
                            : 'Select Expiry Date',
                        style: TextStyle(
                            color: _expiryDate != null
                                ? Colors.black
                                : Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                label:
                _isEdit ? 'Update Medicine' : 'Add Medicine',
                isLoading: _isLoading,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}