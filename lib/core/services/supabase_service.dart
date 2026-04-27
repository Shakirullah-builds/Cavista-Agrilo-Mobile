import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseClient get supabase => Supabase.instance.client;

  static Future<void> initSupabase() async {
    final url = dotenv.env["SUPABASE_URL"]!;
    final anonKey = dotenv.env["SUPABASE_ANON_KEY"]!;

    await Supabase.initialize(url: url, anonKey: anonKey);
  }

  Future<Map<String, dynamic>> fetchDiseaseDetails(String aiLabel, String imagePath) async {
    try {
      // 1. Look for the exact match in the supabase database
      final response = await supabase
          .from("diseases")
          .select()
          .eq("model_label", aiLabel)
          .maybeSingle();
          
      // Flip the permanent memory switch
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_scanned', true);
      final deviceID = prefs.getString('device_id');

      // 2. Generate a clean, safe fallback name if Supabase doesn't have it yet
      final prettyName = aiLabel.replaceAll('___', ' - ').replaceAll('_', ' ');
      
      final Map<String, dynamic> finalData = response ?? {
        "disease_name": prettyName, 
        "description": "Our AI detected $prettyName, but detailed agronomy treatment plans are not yet registered in our database.",
        "severity_level": aiLabel.toLowerCase().contains("healthy") ? 0 : 1, 
        "recommended_actions": ["Monitor closely for changes"],
      };

      // 3. The Image Path Lock
      //final uniqueScanId = '${imagePath}_${DateTime.now().millisecondsSinceEpoch}';
      final lastSavedImage = prefs.getString('last_saved_image_path');

      if (deviceID != null && imagePath != lastSavedImage && imagePath.isNotEmpty) {
        // THE CLOUD WRITE: Save the scan to history using the safe finalData!
        await supabase.from('scan_history').insert({
          'device_id': deviceID,
          'disease_name': finalData['disease_name'],
          'severity_level': finalData['severity_level'],
        });

        // Lock the database using the new unique string!
        await prefs.setString('last_saved_image_path', imagePath);
        debugPrint("✅ NEW Scan saved to history successfully.");
      } else {
        debugPrint("⏳ Image already saved. Ignored duplicate database write.");
      }
      
      // 🚨 FIX 2: Returns the safe finalData instead of crashing with .single()
      return finalData;
      
    } catch (e) {
      debugPrint("Supabase error: $e");
    }
    
    // Safety return if something goes horribly wrong
    return {
      "disease_name": "Error Fetching Data",
      "description": "Please check your internet connection.",
      "severity_level": 0,
      "recommended_actions": [],
    };
  }

  // // 🚨 1. We added imagePath to the required arguments here!
  // Future<Map<String, dynamic>> fetchDiseaseDetails(String aiLabel, String imagePath) async {
  //   try {
  //     // Look for the exact match in the supabase database
  //     final response = await supabase
  //         .from("diseases")
  //         .select()
  //         .eq("model_label", aiLabel)
  //         .maybeSingle();
          
  //     // Flip the permanent memory switch
  //     final prefs = await SharedPreferences.getInstance();
  //     await prefs.setBool('has_scanned', true);
  //     final deviceID = prefs.getString('device_id');

  //     // THE ULTIMATE FIX: The Image Path Lock
  //     final uniqueScanId = '${imagePath}_${DateTime.now().millisecondsSinceEpoch}';
  //     final lastSavedImage = prefs.getString('last_saved_image_path');

  //     if (deviceID != null && uniqueScanId != lastSavedImage && imagePath.isNotEmpty) {

  //       final diseaseName = response != null ? response['disease_name'] : 'Unknown';
  //       final severityLevel = response != null ? response['severity_level'] : 0;

  //       // THE CLOUD WRITE: Save the scan to history!
  //       await supabase.from('scan_history').insert({
  //         'device_id': deviceID,
  //         'disease_name': diseaseName,
  //         'severity_level': severityLevel,
  //       });

  //       // 🚨 Lock the database using the new unique string!
  //       await prefs.setString('last_saved_image_path', uniqueScanId);
  //       debugPrint("✅ NEW Scan saved to history successfully.");
  //     } else {
  //       debugPrint("⏳ Image already saved. Ignored duplicate database write.");
  //     }
      
  //     // if (deviceID != null && imagePath != lastSavedImage && imagePath.isNotEmpty) {
        
  //     //   final diseaseName = response != null ? response['disease_name'] : 'Unknown';
  //     //   final severityLevel = response != null ? response['severity_level'] : 0;

  //     //   // THE CLOUD WRITE: Save the scan to history!
  //     //   await supabase.from('scan_history').insert({
  //     //     'device_id': deviceID,
  //     //     'disease_name': diseaseName,
  //     //     'severity_level': severityLevel,
  //     //   });

  //     //   // 🚨 Lock the database by remembering this exact image path!
  //     //   await prefs.setString('last_saved_image_path', imagePath);
  //     //   debugPrint("✅ NEW Scan saved to history successfully.");
  //     // } else {
  //     //   debugPrint("⏳ Image already saved. Ignored duplicate database write.");
  //     // }

  //     // Fallback if no exact disease matches
  //     if (response == null) {
  //       final fallback = await supabase
  //           .from("diseases")
  //           .select()
  //           .eq("model_label", "Other")
  //           .single();
  //       return fallback;
  //     }
      
  //     return response;
      
  //   } catch (e) {
  //     debugPrint("Supabase error: $e");
  //   }
    
  //   return {
  //     "display_name": "Error Fetching Data",
  //     "description": "Please check your internet connection.",
  //     "severity_level": 0,
  //     "recommended_actions": [],
  //   };
  // }

  Future<List<dynamic>> fetchScanHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final deviceId = prefs.getString('device_id');
    
    if (deviceId == null) return [];

    try {
      // Fetch all scans for this device, ordered strictly by newest first
      final response = await supabase
          .from('scan_history')
          .select()
          .eq('device_id', deviceId)
          .order('created_at', ascending: false);
          
      return response as List<dynamic>;
    } catch (e) {
      debugPrint("Error fetching history: $e");
      return [];
    }
  }
}