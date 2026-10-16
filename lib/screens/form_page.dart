import 'package:flutter/material.dart';
import '../models/receita.dart';
import '../services/api_service.dart';

class FormPage extends StatefulWidget {
  final Receita? receita;
  final VoidCallback? onSalvo;

  const FormPage({super.key, this.receita, this.onSalvo});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nome;
  late final TextEditingController _ingredientes;
  late final TextEditingController _modoFazer;
  late final TextEditingController _img;
  late final TextEditingController _custo;
  String _tipo = 'SALGADA';
  bool _salvando = false;

  bool get _editando => widget.receita != null;

  @override
  void initState() {
    super.initState();
    final r = widget.receita;
    _nome = TextEditingController(text: r?.nome ?? '');
    _ingredientes = TextEditingController(text: r?.ingredientes ?? '');
    _modoFazer = TextEditingController(text: r?.modoFazer ?? '');
    _img = TextEditingController(text: r?.img ?? '');
    _custo = TextEditingController(
      text: r == null ? '' : r.custoAproximado.toStringAsFixed(2),
    );
    _tipo = r?.tipo ?? 'SALGADA';
  }

  @override
  void dispose() {
    _nome.dispose();
    _ingredientes.dispose();
    _modoFazer.dispose();
    _img.dispose();
    _custo.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);

    final nova = Receita(
      id: widget.receita?.id,
      nome: _nome.text.trim(),
      tipo: _tipo,
      ingredientes: _ingredientes.text.trim(),
      modoFazer: _modoFazer.text.trim(),
      img: _img.text.trim(),
      custoAproximado:
          double.tryParse(_custo.text.trim().replaceAll(',', '.')) ?? 0,
    );

    final messenger = ScaffoldMessenger.of(context);
    try {
      if (_editando) {
        await ApiService.atualizar(nova);
      } else {
        await ApiService.criar(nova);
      }
      messenger.showSnackBar(SnackBar(
        content: Text(_editando ? 'Receita atualizada!' : 'Receita cadastrada!'),
      ));
      if (!mounted) return;
      if (_editando) {
        Navigator.of(context).pop(true);
      } else {
        _formKey.currentState!.reset();
        _nome.clear();
        _ingredientes.clear();
        _modoFazer.clear();
        _img.clear();
        _custo.clear();
        setState(() => _tipo = 'SALGADA');
        widget.onSalvo?.call();
      }
    } catch (e) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Não foi possível salvar. Tente novamente.')),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  String? _obrigatorio(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Campo obrigatório' : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_editando ? 'Editar receita' : 'Nova receita')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nome,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nome da receita',
                  prefixIcon: Icon(Icons.restaurant_menu),
                ),
                validator: _obrigatorio,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _tipo,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: [
                  for (final t in Receita.tipos)
                    DropdownMenuItem(
                      value: t,
                      child: Text(Receita(
                              nome: '', tipo: t, ingredientes: '', modoFazer: '')
                          .tipoLabel),
                    ),
                ],
                onChanged: (v) => setState(() => _tipo = v ?? 'SALGADA'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _ingredientes,
                minLines: 3,
                maxLines: 8,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Ingredientes',
                  alignLabelWithHint: true,
                ),
                validator: _obrigatorio,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _modoFazer,
                minLines: 4,
                maxLines: 12,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Modo de fazer',
                  alignLabelWithHint: true,
                ),
                validator: _obrigatorio,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _img,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'URL da imagem (opcional)',
                  prefixIcon: Icon(Icons.image_outlined),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _custo,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Custo aproximado',
                  prefixText: 'R\$ ',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  return double.tryParse(v.trim().replaceAll(',', '.')) == null
                      ? 'Valor inválido'
                      : null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _salvando ? null : _salvar,
                icon: _salvando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_editando ? 'Salvar alterações' : 'Cadastrar receita'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
