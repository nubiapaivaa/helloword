import 'package:flutter/material.dart';

import 'audio_feedback.dart';

void main() {
  runApp(const TreinoApp());
}

class TreinoApp extends StatelessWidget {
  const TreinoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        scaffoldBackgroundColor: const Color(0xFFF4F5F7),
        useMaterial3: true,
      ),
      home: const MainScaffold(),
    );
  }
}

// ---------------------------------------------------------------------------
// MODELOS
// ---------------------------------------------------------------------------

class Treino {
  final String nome;
  final IconData icone;
  bool marcado;

  Treino({required this.nome, required this.icone, this.marcado = false});
}

class GrupoMuscular {
  final String nome;
  final IconData icone;
  final List<String> exercicios;

  GrupoMuscular({
    required this.nome,
    required this.icone,
    required this.exercicios,
  });
}

// ---------------------------------------------------------------------------
// ESTRUTURA PRINCIPAL (Header + Main trocável + Footer com navegação)
// ---------------------------------------------------------------------------

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _indiceSelecionado = 0;

  // Dados de treinos (compartilhados entre as páginas)
  final List<Treino> _treinos = [
    Treino(nome: 'Peito e Tríceps', icone: Icons.fitness_center),
    Treino(nome: 'Costas e Bíceps', icone: Icons.sports_gymnastics),
    Treino(nome: 'Pernas', icone: Icons.directions_run),
    Treino(nome: 'Ombro e Abdômen', icone: Icons.accessibility_new),
  ];

  final List<GrupoMuscular> _grupos = [
    GrupoMuscular(
      nome: 'Peito',
      icone: Icons.fitness_center,
      exercicios: ['Supino reto', 'Supino inclinado', 'Crucifixo', 'Crossover'],
    ),
    GrupoMuscular(
      nome: 'Costas',
      icone: Icons.rowing,
      exercicios: [
        'Puxada frontal',
        'Remada baixa',
        'Remada curvada',
        'Barra fixa',
      ],
    ),
    GrupoMuscular(
      nome: 'Bíceps',
      icone: Icons.sports_gymnastics,
      exercicios: ['Rosca direta', 'Rosca alternada', 'Rosca scott'],
    ),
    GrupoMuscular(
      nome: 'Tríceps',
      icone: Icons.sports_kabaddi,
      exercicios: ['Tríceps corda', 'Tríceps testa', 'Tríceps francês'],
    ),
    GrupoMuscular(
      nome: 'Pernas',
      icone: Icons.directions_run,
      exercicios: [
        'Agachamento',
        'Leg press',
        'Cadeira extensora',
        'Cadeira flexora',
      ],
    ),
    GrupoMuscular(
      nome: 'Abdômen',
      icone: Icons.accessibility_new,
      exercicios: ['Abdominal supra', 'Prancha', 'Elevação de pernas'],
    ),
  ];

  void _irParaTreino() {
    setState(() => _indiceSelecionado = 1);
  }

  @override
  Widget build(BuildContext context) {
    final paginas = [
      HomePage(treinos: _treinos, aoDetalhar: _irParaTreino),
      TreinoPage(grupos: _grupos),
      const PerfilPage(),
    ];

    return Scaffold(
      body: SafeArea(child: paginas[_indiceSelecionado]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indiceSelecionado,
        onDestinationSelected: (i) {
          AudioFeedback.playClick();
          setState(() => _indiceSelecionado = i);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Treino',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PÁGINA PRINCIPAL
// ---------------------------------------------------------------------------

class HomePage extends StatefulWidget {
  final List<Treino> treinos;
  final VoidCallback aoDetalhar;

  const HomePage({super.key, required this.treinos, required this.aoDetalhar});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const List<String> _diasDaSemana = [
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
    'Domingo',
  ];

  @override
  Widget build(BuildContext context) {
    final agora = DateTime.now();
    final diaSemana = _diasDaSemana[agora.weekday - 1];
    final data =
        '${agora.day.toString().padLeft(2, '0')}/${agora.month.toString().padLeft(2, '0')}/${agora.year}';

    return Column(
      children: [
        // HEADER
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              const Icon(Icons.bolt, color: Colors.deepOrange, size: 32),
              const SizedBox(width: 8),
              const Text(
                'FitTrack',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    diaSemana,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    data,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // MAIN
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: widget.treinos.length,
            itemBuilder: (context, index) {
              final treino = widget.treinos[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.deepOrange.withValues(
                          alpha: 0.1,
                        ),
                        child: Icon(treino.icone, color: Colors.deepOrange),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          treino.nome,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Checkbox(
                        value: treino.marcado,
                        onChanged: (v) {
                          AudioFeedback.playClick();
                          setState(() => treino.marcado = v ?? false);
                        },
                      ),
                      TextButton(
                        onPressed: () {
                          AudioFeedback.playClick();
                          widget.aoDetalhar();
                        },
                        child: const Text('Detalhar'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// PÁGINA TREINO
// ---------------------------------------------------------------------------

class TreinoPage extends StatelessWidget {
  final List<GrupoMuscular> grupos;

  const TreinoPage({super.key, required this.grupos});

  void _abrirExercicios(BuildContext context, GrupoMuscular grupo) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(grupo.icone, color: Colors.deepOrange),
                  const SizedBox(width: 8),
                  Text(
                    'Exercícios de ${grupo.nome}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...grupo.exercicios.map(
                (e) => ListTile(
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text(e),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Grupamentos musculares',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              itemCount: grupos.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemBuilder: (context, index) {
                final grupo = grupos[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(grupo.icone, size: 36, color: Colors.deepOrange),
                        const SizedBox(height: 8),
                        Text(
                          grupo.nome,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            AudioFeedback.playClick();
                            _abrirExercicios(context, grupo);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                          ),
                          child: const Text(
                            'Exercícios',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PÁGINA PERFIL
// ---------------------------------------------------------------------------

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.deepOrange,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nome do Usuário',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Inscrito desde 01/01/2025',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          _botaoPerfil(context, Icons.edit, 'Editar perfil', () {}),
          _botaoPerfil(
            context,
            Icons.settings,
            'Configurações do aplicativo',
            () {},
          ),
          _botaoPerfil(context, Icons.logout, 'Sair', () {}, cor: Colors.red),
        ],
      ),
    );
  }

  Widget _botaoPerfil(
    BuildContext context,
    IconData icone,
    String texto,
    VoidCallback onTap, {
    Color? cor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icone, color: cor ?? Colors.deepOrange),
        title: Text(texto, style: TextStyle(color: cor)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          AudioFeedback.playClick();
          onTap();
        },
      ),
    );
  }
}
