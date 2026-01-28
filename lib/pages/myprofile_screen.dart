import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_1/api_client.dart';
import 'menu_button.dart';
import '../config.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  DateTime? selectedDate;
  String? selectedGender;
  bool isLoading = false;
  late ApiClient api;
  late Future<Map<String, String?>> user;
  String? avatarUrl;

  @override
  void initState() {
    super.initState();
    api = ApiClient();
    loadUserData();
  }

  void loadUserData() {
    user = getCachedUser();
    user.then((data) {
      setState(() {
        selectedGender = data['gender'];
        avatarUrl = data['avatar'];
        if (data['birthDate'] != null) {
          selectedDate = DateTime.tryParse(data['birthDate']!)?.toLocal();
        }
      });
    });
  }

  Future<void> pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime(2005),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> saveProfile() async {
    if (selectedDate == null || selectedGender == null) return;

    setState(() => isLoading = true);

    final res = await api.post(updateProfile, {
      'birthDate': selectedDate!.toIso8601String(),
      'gender': selectedGender,
    });

    setState(() => isLoading = false);

    if (res.statusCode == 200) {
      await getInfoAndCache();
      loadUserData(); // 🔄 Обновляем профиль после сохранения

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: ${res.body}')),
      );
    }
  }

  Future<void> updateProfileWithAvatar({String? avatarPath}) async {
    final request = await api.multipartRequest(updateProfile);

    if (avatarPath != null) {
      request.files.add(await MultipartFile.fromPath('avatar', avatarPath));
    }

    final response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Avatar upload failed');
    }
  }

  Future<void> pickAvatar() async {
    final picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final image = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image != null) {
                    await uploadAvatar(image.path);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final image = await picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (image != null) {
                    await uploadAvatar(image.path);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> uploadAvatar(String path) async {
    try {
      await updateProfileWithAvatar(avatarPath: path);
      await getInfoAndCache();
      setState(() {
        avatarUrl = '/assets/photos/avatars/${path.split('/').last}';
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка загрузки аватара: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: Text('No user data')));
        }

        final userData = snapshot.data!;
        return Scaffold(
          drawer: const MenuDrawer(),
          body: Stack(
            children: [
              Container(color: Colors.white),
              Opacity(
                opacity: 0.3,
                child: Image.asset(
                  'assets/bg5.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Row(
                      children: const [
                        MenuButton(),
                        SizedBox(width: 12),
                        Text(
                          "My profile",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(60, 57, 103, 1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // 🔹 Аватар
                    GestureDetector(
                      onTap: pickAvatar,
                      child: CircleAvatar(
                        radius: 80,
                        backgroundImage: avatarUrl != null
                            ? NetworkImage('$url$avatarUrl')
                            : const AssetImage('assets/avatar.png')
                                  as ImageProvider,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text("Birth date"),
                    const SizedBox(height: 8),
                    userData['birthDate'] != null
                        ? Text(
                            DateTime.parse(
                              userData['birthDate']!,
                            ).toLocal().toString().split(' ')[0],
                          )
                        : GestureDetector(
                            onTap: pickBirthDate,
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                selectedDate == null
                                    ? 'Select date'
                                    : '${selectedDate!.day}.${selectedDate!.month}.${selectedDate!.year}',
                              ),
                            ),
                          ),
                    const SizedBox(height: 30),
                    const Text("Gender"),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: ['male', 'female', 'other'].map((g) {
                        Color chipColor;
                        if (g == 'male') {
                          chipColor = selectedGender == 'male'
                              ? Colors.blue
                              : Colors.blue.shade100;
                        } else if (g == 'female') {
                          chipColor = selectedGender == 'female'
                              ? Colors.pink
                              : Colors.pink.shade100;
                        } else {
                          chipColor = selectedGender == 'other'
                              ? Colors.grey
                              : Colors.grey.shade300;
                        }
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ChoiceChip(
                            label: Text(g),
                            selected: selectedGender == g,
                            selectedColor: chipColor,
                            backgroundColor: chipColor.withOpacity(0.3),
                            onSelected: (_) {
                              setState(() => selectedGender = g);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: isLoading ? null : saveProfile,
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Save'),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
