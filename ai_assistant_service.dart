class AIAssistantService {
  static Future<String> getResponse(String message) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _getLocalExpertResponse(message.toLowerCase());
  }

  static String _getLocalExpertResponse(String query) {
    if (query.contains("engine")) {
      return "[ENGINE] Engine issues detected. I recommend checking your oil levels and spark plugs first. Would you like to see our engine parts catalog?";
    } else if (query.contains("brake")) {
      return "[BRAKE] Brake safety is priority! For squeaking or soft pedals, you likely need new pads. Check out our Brake & Suspension section.";
    } else if (query.contains("oil")) {
      return "[OIL] For most modern cars, synthetic oil is recommended. We have Castrol Edge and Mobil 1 available!";
    } else if (query.contains("hello") || query.contains("hi")) {
      return "[GREETING] Hello! I'm your AutoParts AI Assistant. Ask me about car parts, repair advice, or how to use the app.";
    } else if (query.contains("mechanic")) {
      return "[MECHANIC] You can request a professional mechanic to your location using the 'Need a Mechanic?' banner on the home screen.";
    } else if (query.contains("price") || query.contains("cost")) {
      return "[PRICE] Our prices vary by part. Please browse the catalog or contact support for specific pricing!";
    } else if (query.contains("tire") || query.contains("tyre")) {
      return "[TIRE] We have a wide selection of tires from top brands like Michelin, Bridgestone, and Goodyear!";
    } else if (query.contains("battery")) {
      return "[BATTERY] Need a new battery? We have DieHard, Optima, and Interstate batteries in stock!";
    } else {
      return "[AI] Thanks for your question! Our AI assistant is here to help. Please browse our catalog or contact support for more specific assistance.";
    }
  }
}