import 'package:expensem_app/pages/database.dart';
import 'package:expensem_app/pages/info.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Add extends StatefulWidget {
  const Add({super.key});

  @override
  State<Add> createState() => _AddState();
}

class _AddState extends State<Add> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  Info? existingInfo;

  double _income = 0.0;
  double _remainingBudget = 0.0;
  bool _showWarning = false;

  @override
  void initState() {
    super.initState();
    _loadIncome();
  }

  Future<void> _loadIncome() async {
    final prefs = await SharedPreferences.getInstance();
    final storedIncome = prefs.getString('user_income') ?? '0';
    setState(() {
      _income = double.tryParse(storedIncome) ?? 0.0;
    });
    _updateRemainingBudget();
  }

  void _updateRemainingBudget() {
    final amt = double.tryParse(_amountController.text) ?? 0.0;
    final remaining = _income - amt;

    setState(() {
      _remainingBudget = remaining;
      _showWarning = remaining < (_income * 0.3);
    });
  }

  void _handleSave() async {
    if (_nameController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty ||
        _quantityController.text.trim().isEmpty ||
        _amountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('All fields are required.')));
      return;
    }

    final int? quantity = int.tryParse(_quantityController.text);
    final double? amount = double.tryParse(_amountController.text);

    if (quantity == null || amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter valid numeric values for Quantity and Amount.'),
        ),
      );
      return;
    }

    if (amount > _income) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Expense amount exceeds your income budget.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final info = Info(
      id: existingInfo?.id,
      name: _nameController.text.trim(),
      des: _descriptionController.text.trim(),
      qty: quantity,
      amt: amount,
    );

    try {
      if (existingInfo == null) {
        await DatabaseHelper.instance.add(info);
      } else {
        await DatabaseHelper.instance.update(info);
      }
      Navigator.of(context).pop();
    } catch (e) {
      print('Database error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save data. Please try again.')),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Info && existingInfo == null) {
      existingInfo = args;
      _nameController.text = existingInfo!.name;
      _descriptionController.text = existingInfo!.des;
      _quantityController.text = existingInfo!.qty.toString();
      _amountController.text = existingInfo!.amt.toString();
      _updateRemainingBudget();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          existingInfo == null ? 'Add Item' : 'Edit Item',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
      ),
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset('images/back.jpg', fit: BoxFit.cover),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.white.withAlpha((0.92 * 255).round()),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        existingInfo == null
                            ? 'Add New Expense'
                            : 'Update Expense',
                        style: GoogleFonts.montserrat(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Item Name',
                          prefixIcon: Icon(Icons.shopping_cart),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          prefixIcon: Icon(Icons.description),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Quantity',
                          prefixIcon: Icon(Icons.confirmation_num),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          prefixIcon: Icon(Icons.attach_money),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => _updateRemainingBudget(),
                      ),
                      SizedBox(height: 20),

                      if (_income > 0) ...[
                        Center(
                          child: Row(
                            children: [
                              Icon(
                                Icons.account_balance_wallet,
                                color: _remainingBudget >= 0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              Text(
                                'Remaining Budget: \$${_remainingBudget.toStringAsFixed(2)}',
                                style: GoogleFonts.roboto(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _remainingBudget >= 0
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_showWarning)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.warning, color: Colors.red),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Warning: Remaining budget is less than 30% of your income.',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        SizedBox(height: 20),
                      ],

                      ElevatedButton.icon(
                        icon: Icon(
                          existingInfo == null ? Icons.add : Icons.save,
                        ),
                        label: Text(
                          existingInfo == null
                              ? 'Add Expense'
                              : 'Update Expense',
                          style: GoogleFonts.roboto(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _handleSave,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
