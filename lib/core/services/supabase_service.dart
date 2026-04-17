import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseClient get supabase => Supabase.instance.client;
  //final supabase = Supabase.instance.client;

  static Future<void> initSupabase() async {
    final url = dotenv.env["SUPABASE_URL"]!;
    final anonKey = dotenv.env["SUPABASE_ANON_KEY"]!;

    await Supabase.initialize(url: url, anonKey: anonKey);
  }

  Future<Map<String, dynamic>> fetchDiseaseDetails(String aiLabel) async {
    try {
      final debugTest = await supabase.from('diseases').select();
      print("SUPABASE DEBUG DUMP: $debugTest");
      // Look for the exact match in the supabase database
      final response = await supabase
          .from("diseases")
          .select()
          .eq("model_label", aiLabel)
          .maybeSingle();
      if (response == null) {
        final fallback = await supabase
            .from("diseases")
            .select()
            .eq("model_label", "Other")
            .single();
        return fallback;
      }
      return response;
    } catch (e) {
      debugPrint("Supabase error: $e");
    }
    return {
      "display_name": "Error Fetching Data",
      "description": "Please check your internet connection.",
      "severity_level": 0,
      "recommended_actions": [],
    };
  }
}
