import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';

import 'firebase_controller.dart';

class StableManager {
  Future<List<dynamic>> convertTextToImage(
      String prompt, String seed, String negativePrompt) async {
    var seed0 = int.parse(seed);

    final url = Uri.parse(MyFire.box.read("diffusion_url"));

    // 요청 본문 데이터 설정
    Map<String, dynamic> requestData = {
      "prompt": prompt,
      "negative_prompt": "no sexual,$negativePrompt",
      "seed": seed0,
      "height": 1024,
      "width": 1024,
      "scheduler": "KLMS",
      "num_inference_steps": 30,
      "guidance_scale": 10,
      "strength": 0.5,
      "num_images": 2
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode != 200) {
        print("200 실패");
        print(response.body);
        return ["null"];
      } else {
        try {
          final responseData = jsonDecode(response.body);
          final resultImages = responseData['images'] as List<dynamic>;
          return resultImages.map((image) => image.toString()).toList();
        } catch (e) {
          print("응답 데이터 파싱 오류: $e");
          return ["null"];
        }
      }
    } catch (e) {
      print("HTTP 요청 실패: $e");
      return ["null"];
    }
  }
}
