import 'package:flutter/material.dart';
import 'package:qrreaderapp/src/bloc/scans_bloc.dart';
import 'package:qrreaderapp/src/models/scan_model.dart';
import 'package:qrreaderapp/src/utils/utils.dart' as utils;

class DireccionesPage extends StatelessWidget {

  final scansBloc = new ScansBloc();
  @override
  Widget build(BuildContext context) {

    scansBloc.obtenerScans();

    return StreamBuilder <List<ScanModel>>(
      stream: scansBloc.scanStreamHttp,
      builder: (BuildContext context, AsyncSnapshot <List<ScanModel>> snapshot) {
        if(!snapshot.hasData){
          return Center(child: CircularProgressIndicator(),);
        }
        final scans = snapshot.data;

        if(scans.length == 0){
          return Center(child: Text('No hay informacion'),);
        }
        return ListView.builder(
          itemCount: scans.length,
          itemBuilder: (context, i) => Dismissible(
            background: Container(color: Colors.indigo, child: Center(child: Text('Borrar')),),
            key: UniqueKey(),
            onDismissed: (direcion) => scansBloc.borrarScan(scans[i].id),
            child: ListTile(
              leading: Icon(Icons.description, color: Theme.of(context).copyWith().primaryColor,),
              title: Text(scans[i].valor),
              subtitle: Text('ID: ${scans[i].id}'),
              trailing: Icon(Icons.chevron_right),
              onTap: (){
                utils.abrirScan(context, scans[i]);
              },
            ),
          )
        );
      },
    );
  }
}