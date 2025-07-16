import 'package:expensem_app/pages/database.dart';
import 'package:expensem_app/pages/info.dart';
import 'package:flutter/material.dart';

class Listpg extends StatefulWidget {
  const Listpg({super.key});

  @override
  State<Listpg> createState() => _ListpgState();
}

class _ListpgState extends State<Listpg> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Item Details')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "/add");
        },
        child: const Icon(Icons.add),
      ),

      // body: ListView.builder(
      //   padding: const EdgeInsets.all(8),
      //   itemCount: 4,
      //   itemBuilder: (context, index) {
      //     return Card(
      //       elevation: 3,
      //       shape: RoundedRectangleBorder(
      //         borderRadius: BorderRadius.circular(10),
      //       ),
      //       child: ListTile(
      //         leading: CircleAvatar(child: Text('test')),
      //         title: Text(
      //           'item$index',
      //           style: const TextStyle(fontWeight: FontWeight.bold),
      //         ),
      //         subtitle: Column(
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           children: [
      //             Text('des'),
      //             Text('Quantity: ${'qty'}'),
      //             Text('Amount: ${'amt'}'),
      //           ],
      //         ),

      //         // trailing: PopupMenuButton<String>(
      //         //   onSelected: (value) {
      //         //     // Handle actions
      //         //   },
      //         //   // itemBuilder: (context) => const [
      //         //   //   PopupMenuItem(value: 'edit', child: Text('Edit')),
      //         //   //   PopupMenuItem(value: 'delete', child: Text('Delete')),
      //         //   // ],
      //         // ),
      //       ),
      //     );
      //   },
      // ), //ls,
      body: FutureBuilder<List<Info>>(
        future: DatabaseHelper.instance.getinfos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.inbox, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No data found',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            );
          }

          final items = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(item.name[0].toUpperCase()),
                    ),
                    title: Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.des),
                        Text('Quantity: ${item.qty}'),
                        Text('Amount (in \$): ${item.amt}'),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          
                          Navigator.pushNamed(
                            context,
                            "/add",
                            arguments: item, 
                          );
                        } else if (value == 'delete') {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text('Delete "${item.name}"?'),
                              content: const Text(
                                'Are you sure you want to delete this item?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await DatabaseHelper.instance.delete(item.id!);
                            setState(() {}); 
                          }
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ),
                );
              },
            ), //ls
          );
        },
      ),
    );
  }
}
