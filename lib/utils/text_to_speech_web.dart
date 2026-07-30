import 'dart:html' as html;
import 'package:flutter/material.dart';

void speakText(String text, {VoidCallback? onComplete}) {
  stopSpeaking();

  final synth = html.window.speechSynthesis;
  if (synth == null) return;

  final utterance = html.SpeechSynthesisUtterance(text);

  if (onComplete != null) {
    utterance.onEnd.listen((_) {
      onComplete();
    });
  }

  synth.speak(utterance);
}

void stopSpeaking() {
  final synth = html.window.speechSynthesis;
  if (synth != null && synth.speaking == true) {
    synth.cancel();
  }
}

bool isSpeechActive() {
  final synth = html.window.speechSynthesis;
  return synth?.speaking ?? false;
}
