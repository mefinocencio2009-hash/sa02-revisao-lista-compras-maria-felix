import 'package:flutter/material.dart';

void main() {
  runApp(const MeuApp());
}

// ===================================================================
// PALETA DE CORES DO APP
// ===================================================================
class Cores {
  static const Color primaria = Color(0xFF6C63FF);      // Roxo moderno
  static const Color secundaria = Color(0xFF4ECDC4);    // Verde água
  static const Color destaque = Color(0xFFFF6B6B);      // Coral
  static const Color fundo = Color(0xFFF7F8FC);         // Cinza bem claro
  static const Color texto = Color(0xFF2D3142);         // Grafite
  static const Color textoSecundario = Color(0xFF9095A6); // Cinza
  static const Color sucesso = Color(0xFF3DD598);       // Verde sucesso
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Compras',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Cores.fundo,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: Cores.primaria),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
        ),
      ),
      home: const TelaLista(),
    );
  }
}

// ===================================================================
// MODELO Item
// ===================================================================
class Item {
  String nome;
  int quantidade;
  bool comprado;

  Item({
    required this.nome,
    required this.quantidade,
    this.comprado = false,
  });
}

// ===================================================================
// TELA PRINCIPAL
// ===================================================================
class TelaLista extends StatefulWidget {
  const TelaLista({super.key});

  @override
  State<TelaLista> createState() => _TelaListaState();
}

class _TelaListaState extends State<TelaLista> {
  final List<Item> itens = [];

  Future<void> abrirTelaAdicionar() async {
    final Item? novoItem = await Navigator.push<Item>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const TelaAdicionarItem(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );

    if (!mounted || novoItem == null) return;

    setState(() => itens.add(novoItem));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text('${novoItem.nome} adicionado à lista')),
          ],
        ),
        backgroundColor: Cores.sucesso,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void removerItem(int indice) {
    final Item removido = itens[indice];

    setState(() => itens.removeAt(indice));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.delete_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text('${removido.nome} removido')),
          ],
        ),
        backgroundColor: Cores.destaque,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int comprados = itens.where((i) => i.comprado).length;
    final int total = itens.length;
    final double progresso = total == 0 ? 0 : comprados / total;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ---------- CABEÇALHO COM GRADIENTE ----------
            _construirCabecalho(comprados, total, progresso),

            // ---------- LISTA ----------
            Expanded(
              child: itens.isEmpty
                  ? _estadoVazio()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      itemCount: itens.length,
                      itemBuilder: (context, indice) {
                        return _construirCardItem(indice);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: abrirTelaAdicionar,
        backgroundColor: Cores.primaria,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add),
        label: const Text(
          'Adicionar',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // ---------- CABEÇALHO ----------
  Widget _construirCabecalho(int comprados, int total, double progresso) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Cores.primaria, Cores.secundaria],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Minha Lista',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Lista de Compras',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Contador
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$comprados de $total comprados',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                total == 0
                    ? '0%'
                    : '${(progresso * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Barra de progresso
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progresso,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- CARD DE ITEM ----------
  Widget _construirCardItem(int indice) {
    final Item item = itens[indice];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() => item.comprado = !item.comprado);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Checkbox customizado
                _construirCheckbox(item),

                const SizedBox(width: 12),

                // Nome e quantidade
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: item.comprado
                              ? Cores.textoSecundario
                              : Cores.texto,
                          decoration: item.comprado
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          decorationColor: Cores.textoSecundario,
                          decorationThickness: 2,
                        ),
                        child: Text(item.nome),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: item.comprado
                                  ? Cores.sucesso.withOpacity(0.15)
                                  : Cores.primaria.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Qtd: ${item.quantidade}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: item.comprado
                                    ? Cores.sucesso
                                    : Cores.primaria,
                              ),
                            ),
                          ),
                          if (item.comprado) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.check_circle,
                              size: 14,
                              color: Cores.sucesso,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Comprado',
                              style: TextStyle(
                                fontSize: 11,
                                color: Cores.sucesso,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Botão de remover
                IconButton(
                  onPressed: () => removerItem(indice),
                  icon: const Icon(Icons.delete_outline),
                  color: Cores.destaque,
                  splashRadius: 22,
                  tooltip: 'Remover item',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- CHECKBOX PERSONALIZADO ----------
  Widget _construirCheckbox(Item item) {
    return GestureDetector(
      onTap: () {
        setState(() => item.comprado = !item.comprado);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: item.comprado ? Cores.sucesso : Colors.transparent,
          border: Border.all(
            color: item.comprado ? Cores.sucesso : Cores.textoSecundario,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: item.comprado
            ? const Icon(Icons.check, color: Colors.white, size: 18)
            : null,
      ),
    );
  }

  // ---------- ESTADO VAZIO ----------
  Widget _estadoVazio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Cores.primaria.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: Cores.primaria.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Sua lista está vazia',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Cores.texto,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Toque em "+ Adicionar" para começar',
            style: TextStyle(fontSize: 14, color: Cores.textoSecundario),
          ),
        ],
      ),
    );
  }
}

// ===================================================================
// TELA ADICIONAR ITEM
// ===================================================================
class TelaAdicionarItem extends StatefulWidget {
  const TelaAdicionarItem({super.key});

  @override
  State<TelaAdicionarItem> createState() => _TelaAdicionarItemState();
}

class _TelaAdicionarItemState extends State<TelaAdicionarItem> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _quantidadeController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _quantidadeController.dispose();
    super.dispose();
  }

  void salvar() {
    final String nome = _nomeController.text.trim();
    final int quantidade =
        int.tryParse(_quantidadeController.text.trim()) ?? 1;

    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Digite o nome do item!')),
            ],
          ),
          backgroundColor: Cores.destaque,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    Navigator.pop(context, Item(nome: nome, quantidade: quantidade));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores.fundo,
      body: SafeArea(
        child: Column(
          children: [
            // ---------- CABEÇALHO ----------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(8, 12, 24, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Cores.primaria, Cores.secundaria],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Novo Item',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Preencha os dados abaixo',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ---------- FORMULÁRIO ----------
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    _labelCampo('Nome do item'),
                    const SizedBox(height: 8),
                    _campoTexto(
                      controller: _nomeController,
                      hint: 'Ex: Arroz, Feijão, Leite...',
                      icone: Icons.shopping_basket_outlined,
                      autofocus: true,
                    ),

                    const SizedBox(height: 24),

                    _labelCampo('Quantidade'),
                    const SizedBox(height: 8),
                    _campoTexto(
                      controller: _quantidadeController,
                      hint: 'Ex: 1, 2, 3...',
                      icone: Icons.numbers,
                      tecladoNumerico: true,
                    ),

                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Cores.primaria,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: Cores.primaria.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: salvar,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Salvar Item',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _labelCampo(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Cores.texto,
      ),
    );
  }

  Widget _campoTexto({
    required TextEditingController controller,
    required String hint,
    required IconData icone,
    bool tecladoNumerico = false,
    bool autofocus = false,
  }) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: tecladoNumerico ? TextInputType.number : TextInputType.text,
      textCapitalization:
          tecladoNumerico ? TextCapitalization.none : TextCapitalization.sentences,
      style: const TextStyle(fontSize: 16, color: Cores.texto),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Cores.textoSecundario),
        prefixIcon: Icon(icone, color: Cores.primaria),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Cores.primaria, width: 2),
        ),
      ),
    );
  }
}