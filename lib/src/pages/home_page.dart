import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qrreaderapp/src/pages/mapas_page.dart';
import 'package:qrreaderapp/src/pages/direcciones_page.dart';

import 'package:qrreaderapp/src/bloc/scans_bloc.dart';
import 'package:qrreaderapp/src/models/scan_model.dart';

import 'package:qrcode_reader/qrcode_reader.dart';
import 'package:qrreaderapp/src/utils/utils.dart' as utils; //Alias

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final scansBloc = new ScansBloc();

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Scanner'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: (){
              scansBloc.borrarScansTODOS();              
            },
          )
        ],
      ),
      body: _callPage(currentIndex),
      bottomNavigationBar: _crearBottomNaviigationBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo, // o traer el tema global de la app
        child: Icon(Icons.filter_center_focus),
        onPressed: () => _scanQR(context)
      ),
    );
  }

  _scanQR(BuildContext context) async{
    // https://www.facebook.com/angel.rosillo.144
    // geo:40.72215149405802,-73.99770155390627
    
    String futureString = '';
    
    try {
      futureString = await new QRCodeReader().scan();
    } catch (e) {
      futureString = e.toString();
    }
    // print('futureString:   $futureString');
    if(futureString != null){
      final scan = ScanModel(valor: futureString);
      // DBProvider.db.nuevoScan(scan); No se debe usar la bd directamente sino centralizado desde scanBloc
      scansBloc.agregarScan(scan);

      if(Platform.isIOS){ // ESTA VALIDACION ES PARA SOLUCIONAR ERROR EN IOS
        Future.delayed(Duration(milliseconds: 750), (){
          utils.abrirScan(context, scan);
        });
      }else{
        utils.abrirScan(context, scan);
      }

    }
  }

  Widget _callPage(int paginaActual){

    switch (paginaActual) {
      case 0: {
        
        return MapasPage();
      }
      case 1: return DireccionesPage();
        
        break;
      default:
      return MapasPage();
    }

  }

  Widget _crearBottomNaviigationBar(){

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index){
        setState(() {
         currentIndex = index; 
        });
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          title: Text('mapas')
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.brightness_5),
          title: Text('Direcciones')
        )
      ],
    );
  }
}