import 'package:flutter/material.dart';
import 'todo_model.dart';
import 'todo_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TodoPage(),
    );
  }
}

class TodoPage extends StatefulWidget {
  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final ApiService apiService = ApiService();
  List<Todo> todos = [];

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  void _loadTodos() async {
    try {
      final todosFromApi = await apiService.fetchTodos();
      setState(() {
        todos = todosFromApi;
      });
    } catch (e) {
      print(e);
    }
  }

  void _addTodo() async {
    String newTodoTitle = '';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Thêm công việc mới'),
          content: TextField(
            onChanged: (value) {
              newTodoTitle = value;
            },
            decoration: InputDecoration(hintText: "Nhập tên công việc"),
          ),
          actions: [
            TextButton(
              child: Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Thêm'),
              onPressed: () async {
                if (newTodoTitle.isNotEmpty) {
                  final newTodo = Todo(
                    id: todos.length + 1, // Fake ID vì JSONPlaceholder không yêu cầu ID thật
                    title: newTodoTitle,
                    completed: false,
                  );
                  try {
                    final createdTodo = await apiService.createTodo(newTodo);
                    setState(() {
                      todos.add(createdTodo);
                    });
                  } catch (e) {
                    print(e);
                  }
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteTodo(Todo todo) async {
    try {
      await apiService.deleteTodo(todo.id);
      setState(() {
        todos.remove(todo);
      });
    } catch (e) {
      print(e);
    }
  }

  void _toggleCompletion(Todo todo) async {
    todo.completed = !todo.completed;
    try {
      await apiService.updateTodo(todo);
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addTodo, // Hiển thị hộp thoại thêm công việc
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final todo = todos[index];
          return ListTile(
            title: Text(todo.title),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteTodo(todo),
            ),
            leading: Checkbox(
              value: todo.completed,
              onChanged: (value) => _toggleCompletion(todo),
            ),
          );
        },
      ),
    );
  }
}
