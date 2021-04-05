import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

void main()=>runApp(new MaterialApp(
  home: Bluetooth(),

));

class Bluetooth extends StatefulWidget {
  @override
  _BluetoothState createState() => _BluetoothState();
}

class _BluetoothState extends State<Bluetooth> {


  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection connection;
  BluetoothDevice mydevice;
  String op="Press ConnectBT Button";
  Color status;
  bool isConnectButtonEnabled=true;
  bool isDisConnectButtonEnabled=false;




  void _connect() async  {
    List<BluetoothDevice> devices = [];
    setState(() {
      isConnectButtonEnabled=false;
      isDisConnectButtonEnabled=true;
    });
    devices = await _bluetooth.getBondedDevices();
    // ignore: unnecessary_statements
    devices.forEach((device) {

      print(device);
      if(device.name=="HC-05")
      {
        mydevice=device;
      }
    });

    await BluetoothConnection.toAddress(mydevice.address)
        .then((_connection) {
      print('Connected to the device'+ mydevice.toString());

      connection = _connection;});


    connection.input.listen((Uint8List data) {
      print('Arduino Data : ${ascii.decode(data)}');
      setState(() {
        if(double.parse(ascii.decode(data)) >= 1.3)
          {
            op= "Battery is Healthy " + ascii.decode(data) +" v";
            status=Colors.green;
          }
        else if(double.parse(ascii.decode(data)) >= 1.0 && double.parse(ascii.decode(data)) <= 1.3)
          {
            op= "Battery is getting bad " + ascii.decode(data) +" v";
            status=Colors.amber;
          }
        else
          {
            op="Either is Battery is not connected or Dead";
            status=Colors.red;
          }

      });

    });

    connection.input.listen(null).onDone(() {

      print('Disconnected remotely!');
    });

  }

  void _disconnect()
  {

    setState(() {
      op="Disconnected";
      isConnectButtonEnabled=true;
      isDisConnectButtonEnabled=false;
    });
    connection.close();
    connection.dispose();

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text("Arduino Battery Meter",style: TextStyle(color: Colors.black),),
        backgroundColor:Colors.blue,
      ),
      backgroundColor: Colors.white,

      body: Column(
        children: [

          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                Card(color: Colors.white,elevation: 50,shadowColor: Colors.grey,
                 child:Text("Please make sure you paired your HC-05, its default password is 1234",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.black),),
                )
              ],
            )
          ),


          Container(
            child: Row(

              children: [

                Container(padding: EdgeInsets.fromLTRB(15, 100, 0, 0),child:FlatButton(onPressed:isConnectButtonEnabled?_connect:null ,child: Text("Connect BT") ,color: Colors.greenAccent,disabledColor: Colors.grey,)
                  ,),
                SizedBox(width: 60,),


                Container(padding: EdgeInsets.fromLTRB(0, 100, 0, 0),child:FlatButton(onPressed:isDisConnectButtonEnabled?_disconnect:null,child: Text("Disconnect BT"),color: Colors.redAccent,disabledColor: Colors.grey,)
                  ,),


              ],
            ),
          ),
          SizedBox(height: 200),

          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Card(color: Colors.white,elevation: 100,shadowColor: Colors.black,
                  child: Text(op,style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: status),),
                ),

              ],



            ),
          )


        ],

      ),


    );
  }
}
