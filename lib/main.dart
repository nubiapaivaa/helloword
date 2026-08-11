import 'package:flutter/material.dart';

void main() {
  runApp(const MinhasTarefasApp());
}

// ===============================
// APLICATIVO
// ===============================

class MinhasTarefasApp extends StatelessWidget {
  const MinhasTarefasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Minhas Tarefas',

      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: const Color(0xFFFFF7FA),
      ),

      home: const TelaTarefas(),
    );
  }
}

// ===============================
// MODELO DA TAREFA
// ===============================

class Tarefa {
  String nome;
  String horario;
  bool concluida;

  Tarefa({required this.nome, required this.horario, this.concluida = false});
}

// ===============================
// TELA PRINCIPAL
// ===============================

class TelaTarefas extends StatefulWidget {
  const TelaTarefas({super.key});

  @override
  State<TelaTarefas> createState() => _TelaTarefasState();
}

class _TelaTarefasState extends State<TelaTarefas> {
  // ===============================
  // LISTAS
  // ===============================

  List<Tarefa> tarefasHoje = [
    Tarefa(nome: 'Estudar Flutter', horario: '10:00'),
    Tarefa(nome: 'Reunião com equipe', horario: '14:00'),
    Tarefa(nome: 'Enviar relatório', horario: '16:30'),
  ];

  List<Tarefa> tarefasAmanha = [
    Tarefa(nome: 'Fazer compras', horario: '09:00'),
    Tarefa(nome: 'Ler livro', horario: '20:00'),
  ];

  List<Tarefa> tarefasConcluidas = [
    Tarefa(nome: 'Pagar conta de luz', horario: '08:00', concluida: true),
    Tarefa(nome: 'Academia', horario: '18:00', concluida: true),
  ];

  // ===============================
  // ADICIONAR TAREFA
  // ===============================

  void adicionarTarefa() {
    String nome = '';
    String horario = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Nova tarefa',
            style: TextStyle(color: Colors.pink, fontWeight: FontWeight.bold),
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Nome da tarefa',
                  prefixIcon: Icon(Icons.task),
                ),
                onChanged: (valor) {
                  nome = valor;
                },
              ),

              TextField(
                decoration: const InputDecoration(
                  labelText: 'Horário',
                  prefixIcon: Icon(Icons.access_time),
                ),
                onChanged: (valor) {
                  horario = valor;
                },
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),

              onPressed: () {
                if (nome.isNotEmpty) {
                  setState(() {
                    tarefasHoje.add(Tarefa(nome: nome, horario: horario));
                  });

                  Navigator.pop(context);
                }
              },

              child: const Text(
                'Adicionar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // ===============================
  // CONCLUIR TAREFA
  // ===============================

  void concluirTarefa(Tarefa tarefa) {
    setState(() {
      if (tarefa.concluida == false) {
        tarefa.concluida = true;

        tarefasHoje.remove(tarefa);
        tarefasAmanha.remove(tarefa);

        tarefasConcluidas.add(tarefa);
      } else {
        tarefa.concluida = false;

        tarefasConcluidas.remove(tarefa);

        tarefasHoje.add(tarefa);
      }
    });
  }

  // ===============================
  // EXCLUIR TAREFA
  // ===============================

  void excluirTarefa(Tarefa tarefa) {
    setState(() {
      tarefasHoje.remove(tarefa);
      tarefasAmanha.remove(tarefa);
      tarefasConcluidas.remove(tarefa);
    });
  }

  // ===============================
  // CARD DA TAREFA
  // ===============================

  Widget criarTarefa(Tarefa tarefa) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(12),

        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.08),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: ListTile(
        leading: Checkbox(
          value: tarefa.concluida,

          activeColor: Colors.pink,

          onChanged: (valor) {
            concluirTarefa(tarefa);
          },
        ),

        title: Text(
          tarefa.nome,

          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,

            color: tarefa.concluida ? Colors.grey : Colors.black87,

            decoration: tarefa.concluida
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),

        subtitle: Row(
          children: [
            const Icon(Icons.access_time, size: 15, color: Colors.pink),

            const SizedBox(width: 5),

            Text(tarefa.horario, style: const TextStyle(color: Colors.grey)),
          ],
        ),

        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.pink),

          onPressed: () {
            excluirTarefa(tarefa);
          },
        ),
      ),
    );
  }

  // ===============================
  // SEÇÃO
  // ===============================

  Widget criarSecao(String titulo, List<Tarefa> tarefas) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        const SizedBox(height: 10),

        Text(
          titulo,

          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE91E63),
          ),
        ),

        const SizedBox(height: 10),

        if (tarefas.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 10),

            child: Text(
              'Nenhuma tarefa aqui.',
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          ...tarefas.map((tarefa) => criarTarefa(tarefa)),
      ],
    );
  }

  // ===============================
  // INTERFACE
  // ===============================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ===============================
      // APP BAR
      // ===============================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          'Minhas Tarefas',

          style: TextStyle(
            color: Color(0xFFE91E63),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            onPressed: adicionarTarefa,

            icon: const Icon(Icons.add, color: Color(0xFFE91E63), size: 30),
          ),
        ],
      ),

      // ===============================
      // CORPO
      // ===============================
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const Text(
                'Olá! 👋',

                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 5),

              const Text(
                'Organize suas tarefas',

                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              // ===============================
              // CARTÃO ROSA
              // ===============================
              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF48FB1), Color(0xFFE91E63)],
                  ),

                  borderRadius: BorderRadius.circular(15),
                ),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          'Suas tarefas',

                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),

                        SizedBox(height: 5),

                        Text(
                          'Organize seu dia!',

                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    Container(
                      width: 55,
                      height: 55,

                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.check,
                        color: Colors.pink,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ===============================
              // LISTA
              // ===============================
              criarSecao('Hoje', tarefasHoje),

              criarSecao('Amanhã', tarefasAmanha),

              criarSecao('Concluídas', tarefasConcluidas),
            ],
          ),
        ),
      ),

      // ===============================
      // BOTÃO +
      // ===============================
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink,

        onPressed: adicionarTarefa,

        child: const Icon(Icons.add, color: Colors.white),
      ),

      // ===============================
      // MENU INFERIOR
      // ===============================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,

        type: BottomNavigationBarType.fixed,

        selectedItemColor: Colors.pink,

        unselectedItemColor: Colors.grey,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box),
            label: 'Tarefas',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendário',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.star_border),
            label: 'Prioridades',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
