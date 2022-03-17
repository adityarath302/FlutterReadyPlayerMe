



import 'package:flutter/material.dart';

import 'package:model_viewer_plus/model_viewer_plus.dart';

class Model extends StatelessWidget {
  const Model
({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ModelViewer( src: "assets/9cbdf9b6-2ef4-4408-8ecf-0862b13082a6.glb", alt: "A 3D model of an astronaut",
          ar: true,
          autoRotate: false,
          cameraControls: true,),
    );
  }
}


