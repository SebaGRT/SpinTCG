import 'package:flutter/material.dart';
import 'presentation/theme.dart';
import 'presentation/widgets/court_button.dart';

void main() => runApp(
  MaterialApp(
    title: kBrand,
    theme: buildTheme(),
    home: Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(kBrand, style: display(40)),
            Text(
              'Tema, fuentes y botones',
              style: body(15, color: Court.muted),
            ),
            const SizedBox(height: 24),
            CourtButton('Primario', onPressed: () {}),
            const SizedBox(height: 8),
            CourtButton(
              'Acento',
              variant: ButtonVariant.accent,
              icon: Icons.sports_baseball_outlined,
              onPressed: () {},
            ),
            const SizedBox(height: 8),
            CourtButton(
              'Secundario',
              variant: ButtonVariant.secondary,
              onPressed: () {},
            ),
            const SizedBox(height: 8),
            const CourtButton('Deshabilitado'),
          ],
        ),
      ),
    ),
  ),
);
