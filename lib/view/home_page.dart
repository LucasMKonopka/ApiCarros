import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:agenda_contatos/helpers/carros_helpers.dart';
import 'package:agenda_contatos/view/carro_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

enum OrderOptions{orderAZ, orderZA}



class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CarrosHelper helper = CarrosHelper();
  List<Carro> carros = List();

  @override
  void initState(){
    super.initState();
    getAllCarros();
  }

  void getAllCarros(){
    helper.getAllCarros().then((list){
      setState((){
        carros = list;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80.0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            Image.asset('assets/imgs/logo.jpg',
                fit: BoxFit.contain, height: 50),
                const Text("  Lista de Carros"),
          ],
        ),
        backgroundColor: Colors.black,
        
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
            const PopupMenuItem<OrderOptions>(
              child: Text("Ordenar de A-Z"),
              value: OrderOptions.orderAZ),
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de Z-A"),
                value: OrderOptions.orderZA),
              ],
              onSelected: _orderList,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          showCarroPage();
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.grey [700],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: carros.length,
        itemBuilder: (context, index){
          return carroCard(context, index);
        },
      ),
    );
  }

  Widget carroCard(BuildContext context, int index){
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(image: carros[index].img != null ? FileImage(File(carros[index].img)) : AssetImage("assets/imgs/carro.jpg")),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      carros[index].marca,
                      style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold)
                    ),
                    Text(
                      carros[index].modelo ?? "",
                      style: TextStyle(fontSize: 22.0)
                    ),
                    Text(
                      carros[index].ano ?? "",
                      style: TextStyle(fontSize: 22.0)
                    ),
                    Text(
                      carros[index].cor ?? "",
                      style: TextStyle(fontSize: 18.0),
                    ),
                    Text(
                      carros[index].categoria ?? "",
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        ShowOptions(context, index);
      }
    );
  }

  void showCarroPage({Carro carro}) async{
    final recCarro = await Navigator.push(context, MaterialPageRoute(builder: (context) => CarroPage(carro: carro)));
    if(recCarro != null){
      if(carro != null){
        await helper.updateCarro(recCarro);
      }else{
        await helper.saveCarro(recCarro);
      }
      getAllCarros();
    }
  }

  void ShowOptions(BuildContext context, int index){
    showModalBottomSheet(context: context,
    builder: (context){
      return BottomSheet(
        onClosing: () {},
        builder:(context) {
         return Container(
          padding: EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextButton(
                child: const Text("Editar",
                style: TextStyle(color: Colors.blue, fontSize: 20.0 )),
                onPressed: () {
                  Navigator.pop(context);
                  showCarroPage(carro: carros[index]);
                },
              ),
              TextButton(
                child: const Text("Excluir",
                style: TextStyle(color: Colors.red, fontSize: 20.0 )),
                onPressed: () {
                  helper.deleteCarro(carros[index].id);
                  setState(() {
                    carros.removeAt(index);
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          ),
         ); 
        });
    });
  }
  void _orderList(OrderOptions result){
    switch(result){
      case OrderOptions.orderAZ:
        carros.sort(((a, b) {
          return a.marca.toLowerCase().compareTo(b.marca.toLowerCase());
        }));
      break;
      case OrderOptions.orderZA:
        carros.sort(((a, b) {
          return b.marca.toLowerCase().compareTo(a.marca.toLowerCase());
        }));
      break;
    }
    setState(() {
      
    });
  }

}