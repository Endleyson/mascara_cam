import 'dart:convert';
import 'dart:io';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:examplo_pagina/store/register_store.dart';
import 'package:examplo_pagina/ui/widget/images_widget.dart';

import 'package:examplo_pagina/main.dart';

import '../app_localizations.dart';
import '../bloc/login_bloc.dart';
import '../service/router_service.dart';

class ConfirmaPage extends StatefulWidget {
  const ConfirmaPage({Key? key}) : super(key: key);

  @override
  State<ConfirmaPage> createState() => _ConfirmaPageState();
}

class _ConfirmaPageState extends State<ConfirmaPage>
    with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _color = Color.fromARGB(188, 233, 15, 102);
  final _controller = ConfirmaStore();
  CameraImage? cameraImage;
  CameraController? cameraController;
  String output = "";
  bool _camFront = true;

  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    super.initState();
    loadCamera();
  }

  loadCamera() {
    int _cam;
    !_camFront ? _cam = 0 : _cam = 1;
    if (camera!.length <= 1) {
      cameraController = CameraController(camera![0], ResolutionPreset.high);
    } else {
      cameraController = CameraController(camera![_cam], ResolutionPreset.high);
    }

    cameraController!.initialize().then((value) {
      if (!mounted) {
        return;
      } else {
        setState(() {});
      }
    });
  }

  takePicture() async {
    XFile image = await cameraController!.takePicture();
    File imageFile = File(image.path);
    final List<int> bytes = imageFile.readAsBytesSync();
    String selfieBase64 = base64Encode(bytes);
    _controller.setListImagen(selfieBase64);
    await salvar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
          color: _color,
        ),
        title: Text(
          S.of(context)!.translate('confirmar')!,
          style: TextStyle(color: _color),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _camFront = !_camFront;
                loadCamera();
              });
            },
            icon: Icon(
              Icons.cameraswitch_outlined,
              color: _color,
            ),
          ),
          IconButton(
              onPressed: () {
                Navigator.pushReplacementNamed(
                    context, RouterService.loginRoute);
                BlocProvider.getBloc<LoginBloc>().logout();
              },
              icon: Icon(
                Icons.exit_to_app_rounded,
                color: _color,
              ))
        ],
      ),
      body: Form(
        key: _formKey,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              child: !cameraController!.value.isInitialized
                  ? Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                    )
                  : Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: AspectRatio(
                        aspectRatio: cameraController!.value.aspectRatio,
                        child: CameraPreview(cameraController!),
                      ),
                    ),
            ),
            // codigo responsavel pela máscara --------
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.9), BlendMode.srcOut),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                        color: Colors.black,
                        backgroundBlendMode: BlendMode.dstOut),
                  ),
                  //
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      child: Center(
                        child: Text(
                          S
                              .of(context)!
                              .translate('confirmar_msg')!
                              .toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                      height: MediaQuery.of(context).size.height * 0.2,
                      width: MediaQuery.of(context).size.width * 0.7,
                    ),
                  ),
                  //parte demarcada transparente
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: 305,
                      width: 250,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(130),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // fim do codigo da máscara ---------
            ElevatedButton.icon(
                style: TextButton.styleFrom(
                    minimumSize: Size(150, 50),
                    backgroundColor: _color,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                    )),
                onPressed: () {
                  takePicture();
                },
                icon: Icon(Icons.camera_alt_outlined),
                label: Text("confirmar")),
            Text(
              output,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      // ),
    );
  }

  Future salvar() async {
    // função do processo de confirmação
  }

// controle de ciclo da câmera --------
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? _cameraController = cameraController;

    if (_cameraController == null || !_cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      loadCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
    cameraController!.dispose();
  }
}
