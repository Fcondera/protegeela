import 'package:flutter/material.dart';

class NeutralPage extends StatelessWidget {
  const NeutralPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Pagina neutra. A saida rapida nao apaga historico do navegador.'),
        ),
      ),
    );
  }
}
