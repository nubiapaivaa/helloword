import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class Task {
  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    this.createdAt,
  });


  final String id;
  final String title;
  final String description;
  final String priority;
  final String status;
  final String? createdAt;


  bool get isDone => status == 'concluida';


  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: '${json['id'] ?? ''}',
    title: '${json['titulo'] ?? ''}',
    description: '${json['descricao'] ?? ''}',
    priority: '${json['prioridade'] ?? 'media'}',
    status: '${json['status'] ?? 'pendente'}',
    createdAt: json['criado_em']?.toString(),
  );


  Map<String, dynamic> toJson() => {
    'titulo': title,
    'descricao': description,
    'prioridade': priority,
    'status': status,
  };
}


class ApiException implements Exception {
  const ApiException(this.message);
  final String message;


  @override
  String toString() => message;
}


class TaskApi {
  TaskApi({http.Client? client, String? endpoint})
    : _client = client ?? http.Client(),
      endpoint =
          endpoint ??
          const String.fromEnvironment(
            'TASKS_API_URL',
            defaultValue: 'http://10.140.170.33/pdm_api/tarefas.php',
          );


  final http.Client _client;
  final String endpoint;


  Uri get _baseUri {
    final uri = Uri.tryParse(endpoint);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw const ApiException('O endereço da API não é válido.');
    }
    return uri;
  }


  Future<List<Task>> fetchTasks() async {
    final response = await _client.get(_baseUri, headers: _headers);
    final body = _decode(response);
    _ensureSuccess(response, body);
    final rows = body['dados'];
    if (rows is! List) {
      throw const ApiException(
        'A API não devolveu uma lista de tarefas válida.',
      );
    }
    return rows
        .whereType<Map>()
        .map((row) => Task.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }


  Future<String> createTask(Task task) async {
    final response = await _client.post(
      _baseUri,
      headers: _headers,
      body: jsonEncode(task.toJson()),
    );
    final body = _decode(response);
    _ensureSuccess(response, body);
    return '${body['id'] ?? ''}';
  }


  Future<void> updateTask(Task task) async {
    final uri = _baseUri.replace(
      queryParameters: {..._baseUri.queryParameters, 'id': task.id},
    );
    final response = await _client.put(
      uri,
      headers: _headers,
      body: jsonEncode(task.toJson()),
    );
    _ensureSuccess(response, _decode(response));
  }


  Future<void> deleteTask(String id) async {
    final uri = _baseUri.replace(
      queryParameters: {..._baseUri.queryParameters, 'id': id},
    );
    final response = await _client.delete(uri, headers: _headers);
    _ensureSuccess(response, _decode(response));
  }


  Map<String, String> get _headers => const {
    'Accept': 'application/json',
    'Content-Type': 'application/json; charset=UTF-8',
  };


  Map<String, dynamic> _decode(http.Response response) {
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, dynamic>) return decoded;
      throw const ApiException('Formato JSON inesperado na resposta da API.');
    } on FormatException {
      throw ApiException(
        'A resposta da API não é JSON válido (HTTP ${response.statusCode}).',
      );
    }
  }


  void _ensureSuccess(http.Response response, Map<String, dynamic> body) {
    final ok = response.statusCode >= 200 && response.statusCode < 300;
    if (!ok || body['sucesso'] != true) {
      throw ApiException(
        body['mensagem']?.toString() ??
            'Pedido falhou (HTTP ${response.statusCode}).',
      );
    }
  }
}


void main() => runApp(const TaskApp());


class _AppPalette {
  static const ink = Color(0xFF0F172A);
  static const navy = Color(0xFF172554);
  static const blue = Color(0xFF2563EB);
  static const blueDark = Color(0xFF1D4ED8);
  static const blueMid = Color(0xFF3B82F6);
  static const sky = Color(0xFF60A5FA);
  static const blueLight = Color(0xFFDBEAFE);
  static const cardBlue = Color(0xFFE7F0FF);
  static const bluePale = Color(0xFFEFF6FF);
  static const slate = Color(0xFF64748B);
  static const muted = Color(0xFF94A3B8);
  static const border = Color(0xFFE2E8F0);
  static const white = Color(0xFFFFFFFF);
}


class TaskApp extends StatelessWidget {
  const TaskApp({super.key});


  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Tarefas',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _AppPalette.blue,
        brightness: Brightness.light,
        surface: _AppPalette.white,
      ),
      scaffoldBackgroundColor: _AppPalette.bluePale,
      appBarTheme: const AppBarTheme(
        backgroundColor: _AppPalette.bluePale,
        surfaceTintColor: Colors.transparent,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _AppPalette.blue,
        foregroundColor: _AppPalette.white,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _AppPalette.blue,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _AppPalette.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _AppPalette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _AppPalette.blue, width: 1.5),
        ),
      ),
    ),
    home: const TaskHomePage(),
  );
}


class TaskHomePage extends StatefulWidget {
  const TaskHomePage({super.key});


  @override
  State<TaskHomePage> createState() => _TaskHomePageState();
}


class _TaskHomePageState extends State<TaskHomePage> {
  final TaskApi _api = TaskApi();
  List<Task> _tasks = [];
  bool _loading = true;
  bool _saving = false;
  String? _error;
  String _filter = 'todas';


  @override
  void initState() {
    super.initState();
    _loadTasks();
  }


  Future<void> _loadTasks() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final tasks = await _api.fetchTasks();
      if (!mounted) return;
      setState(() => _tasks = tasks);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _friendlyError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }


  String _friendlyError(Object error) {
    if (error is ApiException) return error.message;
    if (error.toString().contains('SocketException')) {
      return 'Sem ligação à API. Confirme a rede e o endereço do servidor.';
    }
    return 'Não foi possível concluir o pedido. Tente novamente.';
  }


  List<Task> get _visibleTasks => switch (_filter) {
    'pendentes' => _tasks.where((task) => !task.isDone).toList(),
    'concluidas' => _tasks.where((task) => task.isDone).toList(),
    _ => _tasks,
  };


  Future<void> _openForm({Task? task}) async {
    final result = await showModalBottomSheet<TaskDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskFormSheet(task: task),
    );
    if (result == null) return;
    setState(() => _saving = true);
    try {
      if (task == null) {
        await _api.createTask(result.toTask());
      } else {
        await _api.updateTask(result.toTask(id: task.id));
      }
      await _loadTasks();
      if (mounted)
        _showMessage(task == null ? 'Tarefa criada.' : 'Tarefa atualizada.');
    } catch (error) {
      if (mounted) _showMessage(_friendlyError(error), isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }


  Future<void> _deleteTask(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar tarefa?'),
        content: Text('“${task.title}” será removida da lista.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _saving = true);
    try {
      await _api.deleteTask(task.id);
      await _loadTasks();
      if (mounted) _showMessage('Tarefa eliminada.');
    } catch (error) {
      if (mounted) _showMessage(_friendlyError(error), isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }


  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? _AppPalette.navy : _AppPalette.blueDark,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }


  @override
  Widget build(BuildContext context) {
    final done = _tasks.where((task) => task.isDone).length;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 22,
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: _AppPalette.blue, size: 25),
            SizedBox(width: 9),
            Text(
              'Tarefas',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Atualizar lista',
            onPressed: _loading ? null : _loadTasks,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_AppPalette.bluePale, _AppPalette.white],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(
              child: CustomPaint(painter: _DotPatternPainter()),
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 8, 22, 16),
                    child: _summary(done),
                  ),
                  SizedBox(
                    height: 42,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      scrollDirection: Axis.horizontal,
                      children: [
                        _filterChip('todas', 'Todas', _tasks.length),
                        const SizedBox(width: 8),
                        _filterChip(
                          'pendentes',
                          'Por fazer',
                          _tasks.where((t) => !t.isDone).length,
                        ),
                        const SizedBox(width: 8),
                        _filterChip('concluidas', 'Concluídas', done),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(child: _buildList()),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saving ? null : () => _openForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Nova tarefa',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }


  Widget _summary(int done) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [_AppPalette.navy, _AppPalette.blueDark, _AppPalette.blueMid],
      ),
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: _AppPalette.blueDark.withValues(alpha: 0.2),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'UM PASSO DE CADA VEZ',
                style: TextStyle(
                  color: _AppPalette.blueLight,
                  fontSize: 10,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _tasks.isEmpty
                    ? 'Comece por aqui.'
                    : '$done de ${_tasks.length} concluídas',
                style: const TextStyle(
                  color: _AppPalette.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'As suas tarefas, num só lugar.',
                style: TextStyle(color: Color(0xFFBFDBFE), fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Image.asset(
          'assets/images/logo.png',
          width: 52,
          height: 52,
          fit: BoxFit.contain,
        ),
      ],
    ),
  );


  Widget _filterChip(String value, String label, int count) {
    final selected = _filter == value;
    return ChoiceChip(
      selected: selected,
      onSelected: (_) => setState(() => _filter = value),
      label: Text('$label  $count'),
      showCheckmark: false,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: selected ? _AppPalette.white : _AppPalette.blueDark,
      ),
      selectedColor: _AppPalette.blueDark,
      backgroundColor: _AppPalette.bluePale,
      side: BorderSide(
        color: selected ? _AppPalette.blueDark : _AppPalette.border,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
    );
  }


  Widget _buildList() {
    if (_loading && _tasks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _tasks.isEmpty) {
      return _emptyState(
        icon: Icons.cloud_off_rounded,
        title: 'Não foi possível ligar',
        detail: _error!,
        action: FilledButton.tonalIcon(
          onPressed: _loadTasks,
          icon: const Icon(Icons.refresh),
          label: const Text('Tentar novamente'),
        ),
      );
    }
    final tasks = _visibleTasks;
    if (tasks.isEmpty) {
      return _emptyState(
        icon: _filter == 'todas'
            ? Icons.edit_note_rounded
            : Icons.done_all_rounded,
        title: _filter == 'todas' ? 'Ainda sem tarefas' : 'Nada por aqui',
        detail: _filter == 'todas'
            ? 'Toque em “Nova tarefa” para registar a primeira.'
            : 'Experimente outro filtro ou adicione uma tarefa.',
      );
    }
    return RefreshIndicator(
      onRefresh: _loadTasks,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 100),
        itemCount: tasks.length,
        separatorBuilder: (_, __) => const SizedBox(height: 11),
        itemBuilder: (context, index) => _taskCard(tasks[index]),
      ),
    );
  }


  Widget _emptyState({
    required IconData icon,
    required String title,
    required String detail,
    Widget? action,
  }) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 38, color: _AppPalette.muted),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            detail,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _AppPalette.slate, height: 1.4),
          ),
          if (action != null) ...[const SizedBox(height: 16), action],
        ],
      ),
    ),
  );


  Widget _taskCard(Task task) {
    final priorityColor = switch (task.priority) {
      'alta' => _AppPalette.navy,
      'baixa' => _AppPalette.muted,
      _ => _AppPalette.blue,
    };
    return Material(
      color: task.isDone ? _AppPalette.blueLight : _AppPalette.cardBlue,
      elevation: 2,
      shadowColor: _AppPalette.blueDark.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: task.isDone ? _AppPalette.sky : _AppPalette.blueLight,
        ),
      ),
      child: InkWell(
        onTap: _saving ? null : () => _openForm(task: task),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 15, 10, 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 1),
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: task.isDone
                      ? _AppPalette.blueLight
                      : _AppPalette.bluePale,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  task.isDone
                      ? Icons.check_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: task.isDone ? _AppPalette.blueDark : _AppPalette.slate,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: task.isDone
                            ? _AppPalette.slate
                            : _AppPalette.ink,
                        decoration: task.isDone
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        task.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          color: _AppPalette.slate,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 7,
                      runSpacing: 6,
                      children: [
                        _tag(task.priority.toUpperCase(), priorityColor),
                        _tag(
                          task.isDone ? 'CONCLUÍDA' : 'PENDENTE',
                          task.isDone
                              ? _AppPalette.blueDark
                              : _AppPalette.slate,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Ações da tarefa',
                onSelected: (action) {
                  if (action == 'editar') _openForm(task: task);
                  if (action == 'eliminar') _deleteTask(task);
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'editar',
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Editar'),
                      dense: true,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'eliminar',
                    child: ListTile(
                      leading: Icon(
                        Icons.delete_outline,
                        color: _AppPalette.navy,
                      ),
                      title: Text('Eliminar'),
                      dense: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _tag(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: color.withOpacity(0.10),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: color,
        fontSize: 9,
        letterSpacing: .45,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}


class TaskDraft {
  const TaskDraft({
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
  });
  final String title;
  final String description;
  final String priority;
  final String status;


  Task toTask({String id = ''}) => Task(
    id: id,
    title: title,
    description: description,
    priority: priority,
    status: status,
  );
}


class TaskFormSheet extends StatefulWidget {
  const TaskFormSheet({super.key, this.task});
  final Task? task;


  @override
  State<TaskFormSheet> createState() => _TaskFormSheetState();
}


class _TaskFormSheetState extends State<TaskFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late String _priority;
  late String _status;


  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.task?.title ?? '');
    _description = TextEditingController(text: widget.task?.description ?? '');
    _priority = widget.task?.priority ?? 'media';
    _status = widget.task?.status ?? 'pendente';
  }


  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: _AppPalette.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    padding: EdgeInsets.fromLTRB(
      22,
      13,
      22,
      MediaQuery.viewInsetsOf(context).bottom + 22,
    ),
    child: SafeArea(
      top: false,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _AppPalette.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 21),
              Text(
                widget.task == null ? 'Nova tarefa' : 'Editar tarefa',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.5,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Detalhes claros ajudam a avançar.',
                style: TextStyle(color: _AppPalette.slate, fontSize: 13),
              ),
              const SizedBox(height: 20),
              const _FieldLabel('TÍTULO'),
              const SizedBox(height: 7),
              TextFormField(
                controller: _title,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Ex.: Preparar apresentação',
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Escreva um título.'
                    : null,
              ),
              const SizedBox(height: 15),
              const _FieldLabel('DESCRIÇÃO'),
              const SizedBox(height: 7),
              TextFormField(
                controller: _description,
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'O que precisa de fazer?',
                ),
              ),
              const SizedBox(height: 15),
              const _FieldLabel('PRIORIDADE'),
              const SizedBox(height: 7),
              DropdownButtonFormField<String>(
                value: _priority,
                decoration: const InputDecoration(),
                items: const [
                  DropdownMenuItem(value: 'baixa', child: Text('Baixa')),
                  DropdownMenuItem(value: 'media', child: Text('Média')),
                  DropdownMenuItem(value: 'alta', child: Text('Alta')),
                ],
                onChanged: (value) =>
                    setState(() => _priority = value ?? 'media'),
              ),
              const SizedBox(height: 15),
              const _FieldLabel('ESTADO'),
              const SizedBox(height: 7),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(),
                items: const [
                  DropdownMenuItem(value: 'pendente', child: Text('Pendente')),
                  DropdownMenuItem(
                    value: 'concluida',
                    child: Text('Concluída'),
                  ),
                ],
                onChanged: (value) =>
                    setState(() => _status = value ?? 'pendente'),
              ),
              const SizedBox(height: 21),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;
                    Navigator.pop(
                      context,
                      TaskDraft(
                        title: _title.text.trim(),
                        description: _description.text.trim(),
                        priority: _priority,
                        status: _status,
                      ),
                    );
                  },
                  child: Text(
                    widget.task == null ? 'Criar tarefa' : 'Guardar alterações',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}


class _DotPatternPainter extends CustomPainter {
  const _DotPatternPainter();


  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 24.0;
    const radius = 1.5;
    final paint = Paint();


    for (double x = 12; x < size.width; x += spacing) {
      final colorProgress = x / size.width;
      paint.color = Color.lerp(
        _AppPalette.blueDark,
        _AppPalette.sky,
        colorProgress,
      )!.withOpacity(0.2);


      for (double y = 12; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }


  @override
  bool shouldRepaint(covariant _DotPatternPainter oldDelegate) => false;
}


class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);
  final String label;


  @override
  Widget build(BuildContext context) => Text(
    label,
    style: const TextStyle(
      fontSize: 10,
      letterSpacing: 1.1,
      fontWeight: FontWeight.w800,
      color: _AppPalette.slate,
    ),
  );
}