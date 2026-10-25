import 'package:flutter/material.dart';
import '../validadores.dart';

Future<String?> askTeamName(
  BuildContext context, {
  required String title,
  String initial = '',
}) => showDialog<String>(
  context: context,
  builder: (_) => TeamNameDialog(title: title, initial: initial),
);

class TeamNameDialog extends StatefulWidget {
  final String title;
  final String initial;
  const TeamNameDialog({super.key, required this.title, this.initial = ''});

  @override
  State<TeamNameDialog> createState() => _TeamNameDialogState();
}

class _TeamNameDialogState extends State<TeamNameDialog> {
  final form = GlobalKey<FormState>();
  late final name = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  void submit() {
    if (form.currentState!.validate()) Navigator.pop(context, name.text.trim());
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: Form(
      key: form,
      child: TextFormField(
        controller: name,
        autofocus: true,
        maxLength: 24,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(labelText: 'Nombre del equipo'),
        validator: validarNombreEquipo,
        onFieldSubmitted: (_) => submit(),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(onPressed: submit, child: const Text('Guardar')),
    ],
  );
}
