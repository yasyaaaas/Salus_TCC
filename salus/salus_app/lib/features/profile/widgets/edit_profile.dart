import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';

class EditProfileSheet extends StatefulWidget {
  final Map<String, dynamic> currentProfile;

  const EditProfileSheet({super.key, required this.currentProfile});

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;
  late String _selectedGender;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // preenche os campos com os dados ATUAIS pra pessoa editar em cima
    _nameController = TextEditingController(text: widget.currentProfile['full_name']);
    _ageController = TextEditingController(text: widget.currentProfile['age'].toString());
    _weightController = TextEditingController(text: widget.currentProfile['weight_kg'].toString());
    _heightController = TextEditingController(text: widget.currentProfile['height_cm'].toString());
    _selectedGender = widget.currentProfile['gender'];
  }

  @override
  void dispose() {
    // libera os controladores de texto ao encerrar o formulário
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  // valida os dados, envia a atualização para a API e trata o resultado
  Future<void> _handleSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);

    final resultado = await ApiService().updateProfile( // chama a função de atualização do perfil na API
      fullName: _nameController.text.trim(),
      age: int.parse(_ageController.text),
      weightKg: double.parse(_weightController.text.replaceAll(',', '.')),
      heightCm: int.parse(_heightController.text),
      gender: _selectedGender,
    );

    if (!mounted) return;
    setState(() => _isSaving = false); // desativa o estado de salvamento para reativar o botão

    if (resultado.isSuccess) {
      Navigator.pop(context, true); // devolve "true" avisando que salvou
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado.error ?? 'Erro ao salvar'),
          backgroundColor: AppColors.urgencyHigh,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // empurra o conteúdo pra cima do teclado quando ele aparece
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Editar perfil',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              TextFormField( // NOME
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome completo'),
                validator: (v) => (v == null || v.isEmpty) ? 'Informe seu nome' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded( // IDADE
                    child: TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Idade'),
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null || n <= 0) return 'Idade inválida';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded( // GÊNERO
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedGender,
                      decoration: const InputDecoration(labelText: 'Gênero'),
                      items: const [
                        DropdownMenuItem(value: 'Feminino', child: Text('Feminino')),
                        DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                        DropdownMenuItem(value: 'Outro', child: Text('Outro')),
                      ],
                      onChanged: (v) => setState(() => _selectedGender = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded( // PESO
                    child: TextFormField(
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Peso (kg)'),
                      validator: (v) {
                        final n = double.tryParse((v ?? '').replaceAll(',', '.'));
                        if (n == null || n <= 0) return 'Peso inválido';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded( // ALTURA
                    child: TextFormField(
                      controller: _heightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Altura (cm)'),
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null || n <= 0) return 'Altura inválida';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                        )
                      : const Text('Salvar alterações'),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}