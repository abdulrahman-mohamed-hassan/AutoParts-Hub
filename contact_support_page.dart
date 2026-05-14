import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../utils/app_theme.dart';
import '../../services/ai_assistant_service.dart';

class ContactSupportPage extends StatefulWidget {
  @override
  _ContactSupportPageState createState() => _ContactSupportPageState();
}

class _ContactSupportPageState extends State<ContactSupportPage> {
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Contact Repair Shop")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Icon(Icons.support_agent, size: 100, color: AppTheme.primaryColor),
                  SizedBox(height: 10),
                  Text("How can we help you?", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Text("Our experts are ready to assist with your repairs", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            SizedBox(height: 40),

            // --- Instant Chat ---
            _buildContactCard(
              title: "AI Parts Expert",
              subtitle: "Instant AI advice on parts & repairs",
              icon: Icons.auto_awesome,
              color: Colors.purple,
              onTap: () {
                _showAIDialog(context);
              },
            ),
            _buildContactCard(
              title: "Instant Chat",
              subtitle: "Average wait time: 2 mins",
              icon: Icons.chat_bubble,
              color: Colors.blue,
              onTap: () {
                _showChatDialog(context);
              },
            ),

            // --- Call Support ---
            _buildContactCard(
              title: "Call Professional Support",
              subtitle: "Available 24/7 for emergencies",
              icon: Icons.phone,
              color: Colors.green,
              onTap: () {
                _showCallDialog(context);
              },
            ),

            // --- WhatsApp ---
            _buildContactCard(
              title: "WhatsApp Support",
              subtitle: "Send photos of your car parts",
              icon: Icons.message,
              color: Color(0xFF25D366),
              onTap: () {
                _showWhatsAppDialog(context);
              },
            ),

            SizedBox(height: 30),
            Text("Send us a Message", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 15),
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(
                labelText: "Subject",
                prefixIcon: Icon(Icons.subject),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: _messageController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: "Describe your issue",
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 60),
                  child: Icon(Icons.edit_note),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_subjectController.text.isEmpty || _messageController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please fill in both subject and message")),
                    );
                    return;
                  }
                  _subjectController.clear();
                  _messageController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 10),
                          Text("Support request sent successfully!"),
                        ],
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: Text("Submit Request"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Card(
      margin: EdgeInsets.only(bottom: 15),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  // --- Contact action dialogs ---

  void _showChatDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => _buildActionSheet(
        icon: Icons.chat_bubble,
        iconColor: Colors.blue,
        title: "Live Chat",
        message: "Starting a live chat session with our support team...\n\nA technician will respond within 2 minutes.",
        buttonText: "Start Chat",
        onPressed: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Chat session started!"), backgroundColor: Colors.blue),
          );
        },
      ),
    );
  }

  void _showCallDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => _buildActionSheet(
        icon: Icons.phone,
        iconColor: Colors.green,
        title: "Call Support",
        message: "Our professional support line:\n\n📞  +1 (800) AUTO-HUB\n\nAvailable 24/7 for emergencies.",
        buttonText: "Call Now",
        onPressed: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Dialing support..."), backgroundColor: Colors.green),
          );
        },
      ),
    );
  }

  void _showWhatsAppDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => _buildActionSheet(
        icon: Icons.message,
        iconColor: Color(0xFF25D366),
        title: "WhatsApp Support",
        message: "Send us a message on WhatsApp:\n\n📱  +1 (800) 288-6482\n\nYou can send photos of damaged parts for quick diagnostics.",
        buttonText: "Open WhatsApp",
        onPressed: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Opening WhatsApp..."), backgroundColor: Color(0xFF25D366)),
          );
        },
      ),
    );
  }

  void _showAIDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => _AIChatSheet(),
    );
  }

  Widget _buildActionSheet({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: EdgeInsets.all(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: iconColor.withOpacity(0.1),
            child: Icon(icon, color: iconColor, size: 35),
          ),
          SizedBox(height: 15),
          Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[700], height: 1.5)),
          SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(backgroundColor: iconColor),
              child: Text(buttonText, style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AIChatSheet extends StatefulWidget {
  @override
  __AIChatSheetState createState() => __AIChatSheetState();
}

class __AIChatSheetState extends State<_AIChatSheet> {
  final List<Map<String, String>> _messages = [
    {
      "role": "bot", 
      "text": kIsWeb 
        ? "Hello! I am your AutoParts AI Assistant powered by Puter. How can I help you today?"
        : "Hello! I am your AutoParts Smart Expert. I can assist you with repair advice and parts information. How can I help?"
    }
  ];
  final _controller = TextEditingController();
  bool _isLoading = false;

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;

    final userText = _controller.text;
    setState(() {
      _messages.add({"role": "user", "text": userText});
      _isLoading = true;
    });
    _controller.clear();

    final botResponse = await AIAssistantService.getResponse(userText);

    setState(() {
      _messages.add({"role": "bot", "text": botResponse});
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.purple),
                SizedBox(width: 10),
                Text("AI Parts Expert", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple)),
                Spacer(),
                IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                final isBot = m["role"] == "bot";
                return Align(
                  alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isBot ? Colors.grey[200] : AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(15).copyWith(
                        bottomLeft: isBot ? Radius.zero : Radius.circular(15),
                        bottomRight: isBot ? Radius.circular(15) : Radius.zero,
                      ),
                    ),
                    child: Text(
                      m["text"]!,
                      style: TextStyle(color: isBot ? Colors.black : Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Ask about car parts...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                SizedBox(width: 10),
                FloatingActionButton(
                  mini: true,
                  onPressed: _sendMessage,
                  backgroundColor: AppTheme.primaryColor,
                  child: Icon(Icons.send, size: 18, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
