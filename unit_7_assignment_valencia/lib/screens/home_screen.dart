import 'package:flutter/material.dart';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String apiUrl = "http://universities.hipolabs.com/search?country=United+States";
  List<ExpandedTileController> tileControllers = [];

  Future<List<Map<String, dynamic>>> fetchItems() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<Map<String, dynamic>> items = data.map((item) {
        return {
          'name': item['name'] ?? 'No Name',
          'country': item['country'] ?? 'No Country',
          'web_pages': item['web_pages'] ?? [],
        };
      }).toList();

      // Sort alphabetically by name
      items.sort((a, b) => (a['name'] ?? "").compareTo(b['name'] ?? ""));

      // Initialize a controller for each tile
      tileControllers = List.generate(items.length, (index) => ExpandedTileController());

      return items;
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> _launchURL(String url) async {
    // ignore: deprecated_member_use
    if (await canLaunch(url)) {
      // ignore: deprecated_member_use
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Unit 7 - API Calls by Valencia BSCS 3-B AI",
        style: TextStyle(color: Colors.white70),),
        backgroundColor: Colors.black87,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ExpandedTileList.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index, controller) {
                final item = snapshot.data![index];
                return ExpandedTile(
                  controller: tileControllers[index],  // Assign each tile its own controller
                  title: Text(
                    item['name'] ?? "No Name",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey[900],
                    ),
                  ),
                  content: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Country: ${item['country']}",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blueGrey[700],
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        if (item['web_pages'] != null && item['web_pages'].isNotEmpty)
                          TextButton(
                            onPressed: () => _launchURL(item['web_pages'][0]),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              backgroundColor: Colors.blueGrey[800],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: const Text(
                              "Visit Website",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                      ],
                    ),
                  ),
                  theme: ExpandedTileThemeData(
                    headerColor: Colors.blueGrey[50],
                    contentBackgroundColor: Colors.blueGrey[50],
                    contentPadding: const EdgeInsets.all(8),
                    headerPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text("No data available"));
          }
        },
      ),
    );
  }
}
