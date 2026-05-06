import 'package:cloud_firestore/cloud_firestore.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  Future<List<Map<String, dynamic>>> getUsers() async {
    var snapshot = await FirebaseFirestore.instance.collection('users').get();

    return snapshot.docs.map((e) => e.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: FutureBuilder(
        future: getUsers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var data = snapshot.data as List<Map<String, dynamic>>;

          if (data.isEmpty) {
            return const Center(child: Text("Data kosong"));
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(data[index]['name'] ?? 'No Name'),
                subtitle: Text("Age: ${data[index]['age'] ?? '-'}"),
              );
            },
          );
        },
      ),
    );
  }
}
