import 'package:flutter/material.dart';

// Renderiza um subconjunto simples de Markdown: **negrito**, listas com "*" e títulos com "###"
// Não é um parser completo cobre o que o Gemini costuma gerar nas respostas do chatbot
class FormattedText extends StatelessWidget {
  final String text;
  final TextStyle baseStyle;

  const FormattedText({super.key, required this.text, required this.baseStyle});

  @override
  Widget build(BuildContext context) {
    final linhas = text.split('\n'); // quebra o texto em linhas pra tratar cada uma separadamente

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: linhas.map((linha) => _construirLinha(linha)).toList(),
    );
  }

  Widget _construirLinha(String linha) {
    final linhaSemEspacos = linha.trim();

    if (linhaSemEspacos.isEmpty) {
      return const SizedBox(height: 8);
    }

    if (linhaSemEspacos.startsWith('###')) {
      final tituloTexto = linhaSemEspacos.replaceFirst(RegExp(r'^#+\s*'), ''); 
      return Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 4),
        child: Text(
          tituloTexto,
          style: baseStyle.copyWith(fontWeight: FontWeight.w800, fontSize: baseStyle.fontSize! + 1),
        ),
      );
    }

    final ehItemDeLista = linhaSemEspacos.startsWith('* ') || linhaSemEspacos.startsWith('- ');
    final textoDaLinha = ehItemDeLista ? linhaSemEspacos.substring(2) : linhaSemEspacos;

    final conteudo = Text.rich( // permite alterar estilos entre a frase
      TextSpan(children: _parsearNegrito(textoDaLinha, baseStyle)),
    );

    if (!ehItemDeLista) {
      return Padding(padding: const EdgeInsets.only(bottom: 2), child: conteudo);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('•  ', style: baseStyle),
          Expanded(child: conteudo),
        ],
      ),
    );
  }

  /// Transforma "texto **negrito** normal" numa lista de TextSpan,
  /// alternando entre estilo normal e estilo em negrito.
  List<TextSpan> _parsearNegrito(String texto, TextStyle baseStyle) {
    final regex = RegExp(r'\*\*(.+?)\*\*');// uma expressão regular que encontra padrões **bla**
    final spans = <TextSpan>[];
    int posicaoAtual = 0;

    for (final match in regex.allMatches(texto)) { // percorre o texto encontrando todas as ocorrências do padrão setado
      if (match.start > posicaoAtual) {
        spans.add(TextSpan(text: texto.substring(posicaoAtual, match.start), style: baseStyle));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: baseStyle.copyWith(fontWeight: FontWeight.w700),
      ));
      posicaoAtual = match.end;
    }

    if (posicaoAtual < texto.length) {
      spans.add(TextSpan(text: texto.substring(posicaoAtual), style: baseStyle));
    }

    return spans;
  }
}