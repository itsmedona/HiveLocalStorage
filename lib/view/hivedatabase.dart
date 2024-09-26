import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import '../utils/constants/color_constant/color_constant.dart';

class HiveDatabase extends StatefulWidget {
  const HiveDatabase({super.key});

  @override
  State<HiveDatabase> createState() => _HiveDatabaseState();
}

class _HiveDatabaseState extends State<HiveDatabase> {
  late Box dummyBox;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initializing Hive Box
    dummyBox = Hive.box("MyBox");
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    super.dispose();
  }

  // Function to add or update data
  void addOrUpdate({String? key}) {
    if (key != null) {
      final person = dummyBox.get(key);
      if (person != null) {
        nameController.text = person['name'] ?? "";
        ageController.text = person['age']?.toString() ?? '';
      }
    } else {
      nameController.clear();
      ageController.clear();
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 15,
            right: 15,
            top: 15,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Enter name"),
              ),
              TextField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Enter age"),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  final name = nameController.text;
                  final ageText = ageController.text;

                  // Validation
                  if (name.isEmpty || ageText.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text("Please enter valid name and age")),
                    );
                    return;
                  }
                  final age = int.tryParse(ageText);
                  if (age == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text("Please enter a valid number for age")),
                    );
                    return;
                  }
                  if (key == null) {
                    final newKey =
                        DateTime.now().millisecondsSinceEpoch.toString();
                    dummyBox.put(newKey, {"name": name, "age": age});
                  } else {
                    dummyBox.put(key, {"name": name, "age": age});
                  }
                  Navigator.pop(context);
                },
                child: Text(key == null ? 'Add' : 'Update'),
              ),
              SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  //Function for Delete operation
  void deleteOperation(String key) {
    dummyBox.delete(key);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.ScaffoldBg,
      appBar: AppBar(
        title: Text("Flutter Hive Database"),
        backgroundColor: ColorConstant.AppbarBg,
      ),
      body: ValueListenableBuilder(
        valueListenable: dummyBox.listenable(),
        builder: (context, box, widget) {
          if (box.isEmpty) {
            return Center(child: Text("No items added yet"));
          }
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final key = box.keyAt(index).toString();
              final items = box.get(key);
              return Padding(
                  padding: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(items?["name"] ?? "Unknown"),
                    subtitle: Text("Age: ${items?['age'] ?? 'Unknown'}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => addOrUpdate(key: key),
                        ),
                        IconButton(
                          onPressed: () {
                            deleteOperation(key);
                          },
                          icon: Icon(Icons.delete),
                        ),
                      ],
                    ),
                  ));
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorConstant.Blue,
        foregroundColor: ColorConstant.White,
        onPressed: () => addOrUpdate(),
        child: Icon(Icons.add),
      ),
    );
  }
}
