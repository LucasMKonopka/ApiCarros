import 'dart:io';
import 'package:flutter/material.dart';
import '../helpers/carros_helpers.dart';
import 'package:image_picker/image_picker.dart';

class CarroPage extends StatefulWidget {
  CarroPage({this.carro});

  final Carro carro;

  @override
  State<CarroPage> createState() => _CarroPageState();
}

class _CarroPageState extends State<CarroPage> {
  Carro _editedCarro;
  bool _userEdited = false;
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _anoController = TextEditingController();
  final _marcaFocus = FocusNode();
  final _corController = TextEditingController();
  List<String> categorias = ['Sedan', 'SUV', 'Hatch', 'Caminhão'];
  String _categoriaSelecionada;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.carro == null) {
      _editedCarro = Carro();
    } else {
      _editedCarro = Carro.fromMap(widget.carro.toMap());
      _marcaController.text = _editedCarro.marca;
      _modeloController.text = _editedCarro.modelo;
      _anoController.text = _editedCarro.ano;
      _corController.text = _editedCarro.cor;
      _categoriaSelecionada = _editedCarro.categoria;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: requestPop,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            toolbarHeight: 80.0,
            backgroundColor: Colors.black,
            title: Text(_editedCarro.marca ?? "Novo Carro"),
            centerTitle: true,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (_formKey.currentState.validate()) {
                Navigator.pop(context, _editedCarro);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text("Por favor, preencha todos os campos!")),
                );
              }
            },
            child: const Icon(Icons.save),
            backgroundColor: Colors.grey[700],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(10.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    child: Container(
                      width: 140.0,
                      height: 140.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: _editedCarro.img != null
                              ? FileImage(File(_editedCarro.img))
                              : AssetImage("assets/imgs/carro.jpg"),
                        ),
                      ),
                    ),
                    onTap: () {
                      ImagePicker.pickImage(source: ImageSource.gallery)
                          .then((file) {
                        setState(() {
                          _editedCarro.img = file.path;
                        });
                      });
                    },
                  ),
                  TextFormField(
                    controller: _marcaController,
                    focusNode: _marcaFocus,
                    decoration: InputDecoration(labelText: "Marca"),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Preencha a marca";
                      }
                      return null;
                    },
                    onChanged: (text) {
                      _userEdited = true;
                      setState(() {
                        _editedCarro.marca = text;
                      });
                    },
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    controller: _modeloController,
                    decoration: InputDecoration(labelText: "Modelo"),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Preencha o modelo";
                      }
                      return null;
                    },
                    onChanged: (text) {
                      _userEdited = true;
                      setState(() {
                        _editedCarro.modelo = text;
                      });
                    },
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    controller: _anoController,
                    decoration: InputDecoration(labelText: "Ano"),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Preencha o ano";
                      }

                      final ano = int.tryParse(value);
                      if (ano == null) {
                        return "O ano deve ser um número válido";
                      }

                      if (ano < 1800) {
                        return "O ano não pode ser menor que 1800";
                      }
                      if (ano > 2025) {
                        return "O ano não pode ser maior que 2025";
                      }
                      if (ano < 0) {
                        return "O ano não pode ser negativo";
                      }

                      return null;
                    },
                    keyboardType: TextInputType.number,
                    onChanged: (text) {
                      _userEdited = true;
                      setState(() {
                        _editedCarro.ano = text;
                      });
                    },
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    controller: _corController,
                    decoration: InputDecoration(labelText: "Cor"),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Preencha a cor";
                      }
                      return null;
                    },
                    onChanged: (text) {
                      _userEdited = true;
                      setState(() {
                        _editedCarro.cor = text;
                      });
                    },
                  ),
                  SizedBox(height: 20.0),
                  DropdownButtonFormField<String>(
                    value: _editedCarro.categoria,
                    hint: Text("Selecione uma Categoria"),
                    isExpanded: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Selecione uma categoria";
                      }
                      return null;
                    },
                    items: categorias.map((String categoria) {
                      return DropdownMenuItem<String>(
                        value: categoria,
                        child: Text(categoria),
                      );
                    }).toList(),
                    onChanged: (String novaCategoria) {
                      setState(() {
                        _userEdited = true;
                        _editedCarro.categoria = novaCategoria;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Future<bool> requestPop() async {
    if (_userEdited) {
      bool shouldLeave = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Descartar Alterações"),
            content: const Text(
                "Se sair, as alterações serão perdidas. Deseja continuar?"),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text("Sim"),
              ),
            ],
          );
        },
      );

      return Future.value(shouldLeave ?? false);
    } else {
      return Future.value(true);
    }
  }
}
