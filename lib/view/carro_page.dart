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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.carro == null){
      _editedCarro = Carro();
    }else{
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
        backgroundColor: Colors.blue,
        title: Text(_editedCarro.marca ?? "Novo Carro"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          if(_editedCarro.marca != null && _editedCarro.marca.isNotEmpty){
            Navigator.pop(context, _editedCarro);
          }else{
            FocusScope.of(context).requestFocus(_marcaFocus);
          }
        },
        child: const Icon(Icons.save),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            GestureDetector(
              child: Container(
                width: 140.0,
                height: 140.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(image: _editedCarro.img != null ? FileImage(File(_editedCarro.img)) : AssetImage("assets/imgs/carro.jpg")),
                ),
              ),
              onTap: (){
                ImagePicker.pickImage(source: ImageSource.gallery).then((file){
                  setState(() {
                    _editedCarro.img = file.path;
                  });
                });
              },
            ),
            TextField(
              controller: _marcaController,
              focusNode: _marcaFocus,
              decoration: InputDecoration(labelText: "Marca"),
              onChanged: (text){
                _userEdited = true;
                setState(() {
                  _editedCarro.marca = text;
                });
              },
            ),
            SizedBox(height: 10.0),
            TextField(
              controller: _modeloController,
              decoration: InputDecoration(labelText: "Modelo"),
              onChanged: (text){
                _userEdited = true;
                setState(() {
                  _editedCarro.modelo = text;
                });
              },
              //keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 10.0),
            TextField(
              controller: _anoController,
              decoration: InputDecoration(labelText: "Ano"),
              onChanged: (text){
                _userEdited = true;
                setState(() {
                  _editedCarro.ano = text;
                });
              },
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 10.0),
            TextField(
              controller: _corController,
              decoration: InputDecoration(labelText: "Cor"),
              onChanged: (text) {
                _userEdited = true;
                setState(() {
                  _editedCarro.cor = text;
                });
              },
            ),
            SizedBox(height: 20.0),
            DropdownButton<String>(
              value: _editedCarro.categoria,
              hint: Text("Selecione uma Categoria"),
              isExpanded: true,
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
    )
    );
  }

  Future<bool> requestPop(){
    if(_userEdited){
      showDialog(context: context, builder: (context){
        return AlertDialog(
          title: const Text("Descartar Alterações"),
          content: const Text("Se sair, as alterações serão perdidas"),
          actions: <Widget>[
            TextButton(onPressed: (){
              Navigator.pop(context);
            }, child: const Text("Cancelar"),),
            TextButton(onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            }, child: const Text("sim"),),
          ],
        );
      });
      return Future.value(false);
    }else{
      return Future.value(true);
    }
  }
}