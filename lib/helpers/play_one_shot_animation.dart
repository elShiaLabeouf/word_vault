import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class PlayOneShotAnimation extends StatefulWidget {
  const PlayOneShotAnimation({
    Key? key,
    required this.assetPath,
    required this.animName,
  }) : super(key: key);
  final String assetPath;
  final String animName;
  @override
  _PlayOneShotAnimationState createState() => _PlayOneShotAnimationState();
}

class _PlayOneShotAnimationState extends State<PlayOneShotAnimation> {
  SMITrigger? _bump;

  void _onRiveInit(Artboard artboard) {
    final controller =
        StateMachineController.fromArtboard(artboard, 'State Machine 1');
    artboard.addController(controller!);
    _bump = controller.findInput<bool>('Pressed') as SMITrigger;
  }

  void _hitBump() => _bump?.fire();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Animation'),
      ),
      body: Center(
        child: GestureDetector(
          child: RiveAnimation.asset(
            'assets/animations/duck3.riv',
            fit: BoxFit.cover,
            onInit: _onRiveInit,
          ),
          onTap: _hitBump,
        ),
      ),
    );
  }

  /// Controller for playback
//   late OneShotAnimation _controller;

//   /// Is the animation currently playing?
//   bool _isPlaying = false;

//   @override
//   void initState() {
//     super.initState();
//     _controller = OneShotAnimation(
//       'Pressed',
//       autoplay: false,
//       onStop: () => setState(() => _isPlaying = false),
//       onStart: () => setState(() => _isPlaying = true),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {

//     return Column(
//       children: [
//         SizedBox(
//               width: 200,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   Material(
//                     shape: CircleBorder(
//                       side: BorderSide.none,
//                     ),
//                     child: CircleAvatar(
//                       backgroundColor: Colors.black,
//                       radius: 55.0,
//                       child: RiveAnimation.asset(
//               'assets/animations/duck3.riv',
//               artboard: 'Bubble',
//               fit: BoxFit.fitWidth,
//               alignment: Alignment.center,
//               animations: const ['Idle' ,'Pressed', 'Pressed'],
//               stateMachines: const ['State Machine 1'],
//               controllers: [_controller],
//             ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//         // const SizedBox(height: 200,),
//         InkWell(
//           // disable the button while playing the animation
//           onTap: () {
//             print(
//                 "_isPlaying ${_isPlaying}; _controller.isActive ${_controller.isActive}");
//             // _isPlaying ? null : _controller.isActive = true;

//             _controller.reset();
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//   _controller.isActive = !_controller.isActive;
// });
//           },
//           child: const Icon(Icons.arrow_upward),
//         )
//       ],
//     );
  // }
}
