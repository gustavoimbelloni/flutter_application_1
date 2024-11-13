import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

// Função para obter a cidade e o estado a partir das coordenadas usando Nominatim
Future<String?> getCityAndStateFromCoordinates(
    double latitude, double longitude) async {
  final url =
      'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&zoom=10&addressdetails=1';

  final response = await http.get(
    Uri.parse(url),
    headers: {
      'User-Agent': 'MyApp/1.0 (myemail@example.com)' // Adicione um User-Agent
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    print('Geocoding response: $data'); // Log de depuração

    final address = data['address'];
    if (address != null) {
      final city = address['city'];
      final town = address['town'];
      final village = address['village'];
      final municipality = address['municipality'];
      final state = address['state']; // Adicionado

      print(
          'City: $city, Town: $town, Village: $village, Municipality: $municipality, State: $state'); // Log de depuração

      final cityName = city ?? town ?? village ?? municipality;
      if (cityName != null && state != null) {
        return '$cityName - $state';
      }
    }
  } else {
    print(
        'Geocoding failed with status: ${response.statusCode}'); // Log de depuração
  }
  return null;
}

class AddPetScreen extends StatefulWidget {
  @override
  _AddPetScreenState createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _colorController = TextEditingController();
  final _ageController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _imageFile;
  Position? _currentPosition;
  String? _cityAndState; // Adicionando variável para armazenar cidade e estado

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    final position = await Geolocator.getCurrentPosition();
    print(
        'Current position: ${position.latitude}, ${position.longitude}'); // Log de depuração
    setState(() {
      _currentPosition = position;
    });

    // Obter a cidade e estado após obter a posição
    _cityAndState = await getCityAndStateFromCoordinates(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );
    print('City and State: $_cityAndState'); // Log de depuração
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() &&
        _imageFile != null &&
        _currentPosition != null) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final petId = FirebaseFirestore.instance.collection('Pets').doc().id;
        String imageUrl = '';

        if (_imageFile != null) {
          // Upload image to Firebase Storage
          final storageRef =
              FirebaseStorage.instance.ref().child('pets/$petId.jpg');
          await storageRef.putFile(_imageFile!);
          imageUrl = await storageRef.getDownloadURL();
        }

        final description = _descriptionController.text;
        final cityDescription =
            _cityAndState != null ? '\nCidade: $_cityAndState' : '';

        await FirebaseFirestore.instance.collection('Pets').doc(petId).set({
          'name': _nameController.text,
          'breed': _breedController.text,
          'color': _colorController.text,
          'age': _ageController.text,
          'description': description + cityDescription,
          'imageUrl': imageUrl,
          'userId': user.uid,
          'location': GeoPoint(_currentPosition!.latitude,
              _currentPosition!.longitude), // Use o GeoPoint do Firestore
        });

        // Adicione os detalhes do pet ao feed de notícias (User Posts)
        await FirebaseFirestore.instance.collection('User Posts').add({
          'UserEmail': user.email,
          'Message': 'Novo pet cadastrado:\n'
              'Nome: ${_nameController.text}\n'
              'Raça: ${_breedController.text}\n'
              'Cor: ${_colorController.text}\n'
              'Idade: ${_ageController.text}\n'
              'Descrição: ${description + cityDescription}',
          'TimeStamp': Timestamp.now(),
          'Likes': [],
          'imageUrl': imageUrl, // Adicione sempre a URL da imagem
          'location': GeoPoint(_currentPosition!.latitude,
              _currentPosition!.longitude), // Adicione a localização também
        });

        Navigator.pop(context);
      }
    } else {
      print('Form is not valid or location is null'); // Log de depuração
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastrar Pet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nome'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome do pet';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _breedController,
                decoration: InputDecoration(labelText: 'Raça'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a raça do pet';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _colorController,
                decoration: InputDecoration(labelText: 'Cor'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a cor do pet';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(labelText: 'Idade'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a idade do pet';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Descrição'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a descrição do pet';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              _imageFile == null
                  ? TextButton(
                      onPressed: _pickImage,
                      child: Text('Escolher Imagem'),
                    )
                  : Image.file(_imageFile!),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _getCurrentLocation,
                child: Text(
                  'Obter Localização Atual',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              if (_currentPosition != null)
                Text(
                    'Localização obtida: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}'),
              if (_cityAndState != null) // Exibir cidade e estado
                Text('Cidade e Estado: $_cityAndState',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(
                  'Cadastrar Pet',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
