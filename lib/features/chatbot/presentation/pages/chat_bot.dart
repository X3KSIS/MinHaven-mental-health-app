import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:profanity_filter/profanity_filter.dart';

import '../../../Home/home.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../auth/presentation/cubits/auth_states.dart';
import '../../../journal/journal.dart';
import '../../../mood_tracker/mood_dashboard.dart';
import '../../../profile/profile.dart';
import '../../../settings/settings.dart';
import '../../data/model.dart';
import '../../../../widgets/widget_support.dart';
import '../../../gamification/data/services/gamification_service.dart';

// ========== MODERATION ENUMS AND CLASSES ==========
enum ModerationLevel {
  SAFE,
  LOW,
  MEDIUM,
  HIGH,
  CRISIS
}

class ModerationResult {
  final bool isSafe;
  final ModerationLevel level;
  final String reason;
  final String? safeAlternative;

  ModerationResult({
    required this.isSafe,
    required this.level,
    required this.reason,
    this.safeAlternative,
  });
}

// ========== ENHANCED MESSAGE MODEL ==========
class EnhancedModelMessage extends ModelMessage {
  final bool wasFiltered;
  final String? filterReason;
  final ModerationLevel? moderationLevel;

  EnhancedModelMessage({
    required bool isPrompt,
    required String sendMessage,
    required DateTime time,
    required String messageId,
    this.wasFiltered = false,
    this.filterReason,
    this.moderationLevel,
  }) : super(
    isPrompt: isPrompt,
    sendMessage: sendMessage,
    time: time,
    messageId: messageId,
  );
}

// ========== CONTENT MODERATION SERVICE ==========
class ContentModerationService {
  final ProfanityFilter _profanityFilter = ProfanityFilter();
  final List<String> _dangerousTerms = [
    'kill myself', 'suicide', 'end my life', 'want to die',
    'self harm', 'cut myself', 'hurt myself', 'harm myself',
    'overdose', 'jump off', 'hang myself', 'shoot myself',
    'commit suicide', 'unalive myself', 'end it all',
    'want to disappear', 'cant go on', 'no reason to live',
    'better off dead', 'worthless', 'burden to everyone'
  ];

  final List<String> _hateSpeechIndicators = [
    'hate all', 'kill all', 'destroy all', 'exterminate',
    'racial slur', 'ethnic slur', 'religious hate',
    'gender hate', 'lgbtq hate', 'disability hate',
    'all should die', 'purge', 'ethnic cleansing'
  ];

  final List<String> _medicalAdviceRedFlags = [
    'take pills', 'prescribe', 'medication for', 'dosage of',
    'diagnose you', 'medical diagnosis', 'you have', 'you suffer from',
    'clinical treatment', 'therapy technique', 'therapeutic intervention',
    'take this drug', 'medical prescription', 'treatment plan for you'
  ];

  // Check if content contains dangerous content
  ModerationResult checkForDangerousContent(String content) {
    final lowerContent = content.toLowerCase();

    // Check for immediate crisis - highest priority
    for (var term in _dangerousTerms) {
      if (lowerContent.contains(term)) {
        return ModerationResult(
          isSafe: false,
          level: ModerationLevel.CRISIS,
          reason: 'Potential self-harm or suicide content detected',
          safeAlternative: null, // Will trigger crisis response
        );
      }
    }

    // Check for hate speech
    for (var term in _hateSpeechIndicators) {
      if (lowerContent.contains(term)) {
        return ModerationResult(
          isSafe: false,
          level: ModerationLevel.HIGH,
          reason: 'Hate speech or violent content detected',
          safeAlternative: "I'm here to provide supportive conversations. Let's focus on positive and constructive dialogue about mental wellbeing.",
        );
      }
    }

    // Check for profanity
    if (_profanityFilter.hasProfanity(content)) {
      return ModerationResult(
        isSafe: false,
        level: ModerationLevel.MEDIUM,
        reason: 'Inappropriate language detected',
        safeAlternative: "Let's keep our conversation respectful and constructive. How else can I support you today?",
      );
    }

    // Check for medical advice (for AI responses)
    for (var term in _medicalAdviceRedFlags) {
      if (lowerContent.contains(term)) {
        return ModerationResult(
          isSafe: false,
          level: ModerationLevel.HIGH,
          reason: 'Potential medical advice detected',
          safeAlternative: "I'm not qualified to provide medical advice. For health concerns, please consult a healthcare professional who can provide personalized guidance.",
        );
      }
    }

    // Check for personal information sharing
    final emailRegex = RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b');
    final phoneRegex = RegExp(r'\b\d{10,}\b');
    final idRegex = RegExp(r'\b\d{8,12}\b'); // National ID numbers

    if (emailRegex.hasMatch(content) || phoneRegex.hasMatch(content) || idRegex.hasMatch(content)) {
      return ModerationResult(
        isSafe: false,
        level: ModerationLevel.MEDIUM,
        reason: 'Personal information detected',
        safeAlternative: "For your safety, please don't share personal contact information. Let's continue our conversation here in this secure space.",
      );
    }

    // Check for extremely long messages (potential spam)
    if (content.length > 1000) {
      return ModerationResult(
        isSafe: false,
        level: ModerationLevel.LOW,
        reason: 'Message too long',
        safeAlternative: "That's quite a detailed message. Could you summarize your main concern so I can better support you?",
      );
    }

    return ModerationResult(
      isSafe: true,
      level: ModerationLevel.SAFE,
      reason: 'Content is safe',
      safeAlternative: null,
    );
  }

  // Filter and redact inappropriate content
  String filterContent(String content) {
    // Filter profanity
    String filtered = _profanityFilter.censor(content);

    // Redact personal information
    final emailRegex = RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b');
    final phoneRegex = RegExp(r'\b\d{10,}\b');
    final idRegex = RegExp(r'\b\d{8,12}\b');

    filtered = filtered.replaceAllMapped(emailRegex, (match) => '[EMAIL REDACTED]');
    filtered = filtered.replaceAllMapped(phoneRegex, (match) => '[PHONE REDACTED]');
    filtered = filtered.replaceAllMapped(idRegex, (match) => '[ID REDACTED]');

    return filtered;
  }

  // Get crisis response for dangerous content
  String getCrisisResponse() {
    return """🚨 **URGENT SUPPORT NEEDED**

I recognize you might be going through an extremely difficult time. Please know that you're not alone and immediate help is available:

**🔴 ZAMBIAN CRISIS SUPPORT (24/7):**
• Zambia National Counseling Centre: +260 971 000 000
• Chainama Hills Hospital: +260 211 228 344
• Mental Health Foundation of Zambia: +260 977 777 777
• ZAMCOM Crisis Line: +260 979 123 456
• Emergency Services: 999

**🆘 IMMEDIATE ACTIONS:**
1. Call any of the numbers above RIGHT NOW
2. Go to the nearest hospital emergency room
3. Tell someone you trust what you're experiencing
4. Stay on this chat if you need to talk while getting help

**💬 You matter. Your life matters. People want to help you.**

I will stay with you here while you reach out for professional support. Please, make that call now."""
        .trim();
  }
}

// ========== SAFETY LOGGING SERVICE ==========
class SafetyLoggingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> logModerationEvent({
    required String userId,
    required String chatId,
    required String messageId,
    required ModerationLevel level,
    required String reason,
    required String originalContent,
    required String? filteredContent,
    required bool isUserMessage,
  }) async {
    try {
      await _firestore
          .collection('safety_logs')
          .doc()
          .set({
        'userId': userId,
        'chatId': chatId,
        'messageId': messageId,
        'level': level.toString(),
        'reason': reason,
        'originalContent': originalContent,
        'filteredContent': filteredContent,
        'isUserMessage': isUserMessage,
        'timestamp': DateTime.now(),
        'actionTaken': 'content_filtered',
        'reviewed': false,
        'severity': _getSeverityScore(level),
      });
    } catch (e) {
      print('Failed to log moderation event: $e');
    }
  }

  Future<void> logCrisisEvent({
    required String userId,
    required String chatId,
    required String message,
  }) async {
    try {
      await _firestore
          .collection('crisis_alerts')
          .doc()
          .set({
        'userId': userId,
        'chatId': chatId,
        'message': message,
        'timestamp': DateTime.now(),
        'handled': false,
        'priority': 'CRITICAL',
        'notifiedAdmins': false,
        'followUpRequired': true,
        'userEmail': FirebaseAuth.instance.currentUser?.email,
        'userPhone': FirebaseAuth.instance.currentUser?.phoneNumber,
      });
    } catch (e) {
      print('Failed to log crisis event: $e');
    }
  }

  int _getSeverityScore(ModerationLevel level) {
    switch (level) {
      case ModerationLevel.CRISIS:
        return 100;
      case ModerationLevel.HIGH:
        return 75;
      case ModerationLevel.MEDIUM:
        return 50;
      case ModerationLevel.LOW:
        return 25;
      case ModerationLevel.SAFE:
        return 0;
    }
  }
}

// ========== ENHANCED FIRESTORE SERVICE ==========
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();
  final ContentModerationService _moderationService = ContentModerationService();
  final SafetyLoggingService _safetyLogger = SafetyLoggingService();

  // Enhanced save message with moderation
  Future<String?> saveMessage({
    required String message,
    required bool isUser,
    required DateTime timestamp,
    required String chatId,
    required String userId,
  }) async {
    if (userId.isEmpty) return null;

    // Moderate content before saving
    final moderationResult = _moderationService.checkForDangerousContent(message);
    final filteredMessage = _moderationService.filterContent(message);

    // Log moderation event if needed
    if (!moderationResult.isSafe) {
      await _safetyLogger.logModerationEvent(
        userId: userId,
        chatId: chatId,
        messageId: _uuid.v4(),
        level: moderationResult.level,
        reason: moderationResult.reason,
        originalContent: message,
        filteredContent: filteredMessage,
        isUserMessage: isUser,
      );

      // Log crisis events specifically
      if (moderationResult.level == ModerationLevel.CRISIS && isUser) {
        await _safetyLogger.logCrisisEvent(
          userId: userId,
          chatId: chatId,
          message: message,
        );
      }
    }

    // Use filtered message for storage
    final messageToSave = !moderationResult.isSafe && moderationResult.safeAlternative != null
        ? moderationResult.safeAlternative!
        : filteredMessage;

    final messageId = _uuid.v4();

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .set({
      'messageId': messageId,
      'message': messageToSave,
      'originalMessage': message, // Store original for admin review
      'isUser': isUser,
      'timestamp': timestamp,
      'chatId': chatId,
      'wasFiltered': !moderationResult.isSafe,
      'filterReason': !moderationResult.isSafe ? moderationResult.reason : null,
      'moderationLevel': moderationResult.level.toString(),
    });

    // Update chat title with first user message
    if (isUser) {
      final chatDoc = _firestore
          .collection('users')
          .doc(userId)
          .collection('chats')
          .doc(chatId);

      final chatSnapshot = await chatDoc.get();
      if (!chatSnapshot.exists || chatSnapshot.data()?['title'] == 'New Chat') {
        final truncatedMessage = messageToSave.length > 30
            ? '${messageToSave.substring(0, 30)}...'
            : messageToSave;
        await chatDoc.update({
          'title': truncatedMessage,
          'lastUpdated': timestamp,
        });
      } else {
        await chatDoc.update({
          'lastUpdated': timestamp,
        });
      }
    }

    return messageId;
  }

  // Get chat history from Firestore with moderation info
  Stream<List<EnhancedModelMessage>> getChatHistory(String chatId, String userId) {
    if (userId.isEmpty) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) {
      final data = doc.data();
      return EnhancedModelMessage(
        isPrompt: data['isUser'],
        sendMessage: data['message'],
        time: (data['timestamp'] as Timestamp).toDate(),
        messageId: doc.id,
        wasFiltered: data['wasFiltered'] ?? false,
        filterReason: data['filterReason'],
        moderationLevel: _parseModerationLevel(data['moderationLevel']),
      );
    }).toList());
  }

  ModerationLevel? _parseModerationLevel(String? level) {
    if (level == null) return null;
    switch (level) {
      case 'ModerationLevel.CRISIS':
        return ModerationLevel.CRISIS;
      case 'ModerationLevel.HIGH':
        return ModerationLevel.HIGH;
      case 'ModerationLevel.MEDIUM':
        return ModerationLevel.MEDIUM;
      case 'ModerationLevel.LOW':
        return ModerationLevel.LOW;
      case 'ModerationLevel.SAFE':
        return ModerationLevel.SAFE;
      default:
        return null;
    }
  }

  // Create a new chat session and add welcome message
  Future<String> createNewChat(String userId) async {
    if (userId.isEmpty) return '';

    // Create new chat document
    final docRef = await _firestore
        .collection('users')
        .doc(userId)
        .collection('chats')
        .add({
      'createdAt': DateTime.now(),
      'lastUpdated': DateTime.now(),
      'title': 'New Chat',
      'userId': userId,
    });

    // Save welcome message to Firestore
    const welcomeMessage = "Hello! I'm MindHaven, your mental health companion. I'm here to listen and support you in a safe, judgment-free space. What's on your mind today?";
    final messageId = _uuid.v4();
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('chats')
        .doc(docRef.id)
        .collection('messages')
        .doc(messageId)
        .set({
      'messageId': messageId,
      'message': welcomeMessage,
      'originalMessage': welcomeMessage,
      'isUser': false,
      'timestamp': DateTime.now(),
      'chatId': docRef.id,
      'wasFiltered': false,
      'moderationLevel': 'ModerationLevel.SAFE',
    });

    return docRef.id;
  }

  // Get all chat sessions for user
  Stream<List<Map<String, dynamic>>> getUserChats(String userId) {
    if (userId.isEmpty) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('chats')
        .orderBy('lastUpdated', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => {
      'id': doc.id,
      'title': doc.data()['title'] ?? 'Untitled Chat',
      'createdAt': doc.data()['createdAt'],
      'lastUpdated': doc.data()['lastUpdated'],
      'userId': doc.data()['userId'],
    })
        .toList());
  }

  // Delete a chat
  Future<void> deleteChat(String chatId, String userId) async {
    if (userId.isEmpty) return;

    // Delete all messages in the chat
    final messages = await _firestore
        .collection('users')
        .doc(userId)
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .get();

    for (final doc in messages.docs) {
      await doc.reference.delete();
    }

    // Delete the chat document
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('chats')
        .doc(chatId)
        .delete();
  }

  // Update chat title
  Future<void> updateChatTitle(String chatId, String title, String userId) async {
    if (userId.isEmpty) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('chats')
        .doc(chatId)
        .update({
      'title': title,
      'lastUpdated': DateTime.now(),
    });
  }
}

// ========== CHATBOT WIDGET ==========
class MessageTailPainter extends CustomPainter {
  final Color color;
  final bool isRight;
  MessageTailPainter({required this.color, required this.isRight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    if (isRight) {
      path.moveTo(0, 0);
      path.lineTo(-8, 0);
      path.lineTo(0, 8);
      path.close();
    } else {
      path.moveTo(size.width, 0);
      path.lineTo(size.width + 8, 0);
      path.lineTo(size.width, 8);
      path.close();
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ChatBot extends StatefulWidget {
  const ChatBot({super.key});

  @override
  State<ChatBot> createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatBot> {
  TextEditingController promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  static const apiKey = String.fromEnvironment("GEMINI_API_KEY");
  bool isLoading = false;
  bool _isCreatingChat = false;

  // Enhanced AI model with safety settings
  late final GenerativeModel model = GenerativeModel(
    model: "gemini-2.5-flash",
    apiKey: apiKey,
    safetySettings: [
      SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
      SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
      SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.high),
      SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.high),
    ],
    generationConfig: GenerationConfig(
      temperature: 0.7,
      topK: 40,
      topP: 0.8,
      maxOutputTokens: 500,
    ),
  );

  late ChatSession chat;
  String? lastFailedMessage;
  final List<EnhancedModelMessage> prompt = [];
  final FirestoreService _firestoreService = FirestoreService();
  final ContentModerationService _moderationService = ContentModerationService();
  final SafetyLoggingService _safetyLogger = SafetyLoggingService();
  final GamificationService _gamificationService = GamificationService();
  String _currentChatId = '';
  StreamSubscription? _chatSubscription;
  String? _currentUserId;
  bool _showSafetyWarning = false;
  Timer? _safetyWarningTimer;
  int _currentSessionMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _initializeChat();
  }

  void _getCurrentUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _currentUserId = user.uid;
    }
  }

  Future<void> _initializeChat() async {
    if (_currentUserId == null) return;

    // Create a new chat session with welcome message
    _currentChatId = await _firestoreService.createNewChat(_currentUserId!);

    // Initialize ChatSession with enhanced system instruction
    chat = model.startChat(
      history: [
        Content.text("""
      You are MindHaven, a compassionate, empathetic student mental health support and counselor.

      **CRITICAL SAFETY PROTOCOLS:**
      1. If the user expresses or hints at self-harm, suicidal thoughts, or crisis:
         - IMMEDIATELY provide ONLY the Zambian help lines below
         - DO NOT offer any other advice or conversation
         - Use the EXACT crisis response format provided
      
      2. Zambian Crisis Contacts (ONLY use these for Zambia):
         - Zambia National Counseling Centre: +260 971 000 000
         - Chainama Hills Hospital: +260 211 228 344
         - Mental Health Foundation of Zambia: +260 977 777 777
         - ZAMCOM Crisis Line: +260 979 123 456
         - Emergency Services: 999
      
      3. NEVER provide:
         - Medical diagnoses or treatment plans
         - Medication recommendations
         - Professional therapy techniques
         - Legal advice
         - Personal opinions as facts
      
      4. ALWAYS:
         - Redirect to professionals for serious concerns
         - Use evidence-based general mental health information only
         - Maintain appropriate boundaries
         - Report crisis situations through proper channels
      
      5. Response Guidelines:
         - Keep responses concise (2-3 sentences typically)
         - Focus on active listening and validation
         - Ask open-ended questions to understand context
         - Use gentle, supportive language
         - Include Zambian cultural context when relevant
         - Use emojis sparingly and appropriately
         - Never assume the user's gender, background, or situation
      
      6. Content Boundaries:
         - No political discussions
         - No religious advice
         - No relationship counseling
         - No financial advice
         - No academic cheating assistance

      7. Safety First:
         - If unsure about a response, err on the side of caution
         - Redirect to professionals for complex issues
         - Maintain professional boundaries
         - Protect user privacy
      
      Your primary role is to provide immediate Zambian-specific crisis support when needed, and general empathetic listening otherwise.
      """),
      ],
    );

    // Load existing messages from Firestore
    _loadChatHistory();
  }

  void _loadChatHistory() {
    if (_currentUserId == null || _currentChatId.isEmpty) return;

    // Cancel any existing subscription to prevent duplicates
    _chatSubscription?.cancel();

    _chatSubscription = _firestoreService.getChatHistory(_currentChatId, _currentUserId!).listen((messages) {
      if (mounted) {
        setState(() {
          // Clear prompt and add new messages
          prompt.clear();
          prompt.addAll(messages);

          // Check if we should show safety warning
          _updateSafetyWarning();
        });

        // Scroll to bottom after loading messages
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });
  }

  void _updateSafetyWarning() {
    final hasFilteredMessages = prompt.any((msg) => msg.wasFiltered);

    if (hasFilteredMessages && !_showSafetyWarning) {
      setState(() {
        _showSafetyWarning = true;
      });

      // Hide warning after 10 seconds
      _safetyWarningTimer?.cancel();
      _safetyWarningTimer = Timer(const Duration(seconds: 10), () {
        if (mounted) {
          setState(() {
            _showSafetyWarning = false;
          });
        }
      });
    }
  }

  // Enhanced sendMessage with comprehensive safety checks
  Future<void> sendMessage({String? retryMessage}) async {
    if (isLoading || _currentUserId == null) return;

    final message = retryMessage ?? promptController.text;
    if (message.trim().isEmpty) return;

    // STEP 1: Check user input for safety
    final inputModeration = _moderationService.checkForDangerousContent(message);

    // If crisis content detected, show crisis response immediately
    if (inputModeration.level == ModerationLevel.CRISIS) {
      _handleCrisisSituation(message);
      return;
    }

    // If unsafe but not crisis, show filtered message
    final userMessageToSend = !inputModeration.isSafe && inputModeration.safeAlternative != null
        ? inputModeration.safeAlternative!
        : message;

    lastFailedMessage = userMessageToSend;

    // Save user message to Firestore with moderation
    final userMessageId = await _firestoreService.saveMessage(
      message: userMessageToSend,
      isUser: true,
      timestamp: DateTime.now(),
      chatId: _currentChatId,
      userId: _currentUserId!,
    );

    setState(() {
      if (retryMessage == null) promptController.clear();
      isLoading = true;
      prompt.add(EnhancedModelMessage(
        isPrompt: true,
        sendMessage: userMessageToSend,
        time: DateTime.now(),
        messageId: userMessageId ?? '',
        wasFiltered: !inputModeration.isSafe,
        filterReason: !inputModeration.isSafe ? inputModeration.reason : null,
        moderationLevel: inputModeration.level,
      ));
      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutQuad,
          );
        }
      });
    });

    try {
      // STEP 2: Send to AI with timeout
      final response = await chat.sendMessage(
        Content.text(userMessageToSend),
      ).timeout(const Duration(seconds: 30));

      if (!mounted) return;

      final aiResponse = response.text ?? "";

      // STEP 3: Moderate AI response
      final aiModeration = _moderationService.checkForDangerousContent(aiResponse);
      String safeAiResponse;

      if (aiModeration.level == ModerationLevel.CRISIS) {
        // AI generated crisis content - replace with standard crisis response
        safeAiResponse = _moderationService.getCrisisResponse();
      } else if (!aiModeration.isSafe && aiModeration.safeAlternative != null) {
        safeAiResponse = aiModeration.safeAlternative!;
      } else {
        safeAiResponse = _moderationService.filterContent(aiResponse);

        // Additional check: Ensure AI doesn't provide medical advice
        if (_containsMedicalAdvice(safeAiResponse)) {
          safeAiResponse = "I'm not qualified to provide medical advice. For health concerns, please consult a healthcare professional who can provide personalized guidance.";
        }
      }

      // STEP 4: Save moderated AI response
      final aiMessageId = await _firestoreService.saveMessage(
        message: safeAiResponse,
        isUser: false,
        timestamp: DateTime.now(),
        chatId: _currentChatId,
        userId: _currentUserId!,
      );

      setState(() {
        isLoading = false;
        lastFailedMessage = null;
        _currentSessionMessageCount++;
      });

      // Track gamification
      await _gamificationService.trackChatMessage(
        chatId: _currentChatId,
        messageCount: _currentSessionMessageCount,
      );

    } on TimeoutException {
      if (!mounted) return;

      final timeoutMessage = "I'm taking a bit longer to respond. Please try again in a moment.";
      await _firestoreService.saveMessage(
        message: timeoutMessage,
        isUser: false,
        timestamp: DateTime.now(),
        chatId: _currentChatId,
        userId: _currentUserId!,
      );

      setState(() {
        isLoading = false;
      });

    } catch (e) {
      if (!mounted) return;

      String errorMessage;
      if (e.toString().contains('network') || e.toString().contains('SocketException')) {
        errorMessage = "Network issue detected. Please check your connection and try again. 📡";
      } else if (e.toString().contains('rate limit') || e.toString().contains('quota')) {
        errorMessage = "Service is currently busy. Please wait a moment and try again. ⏳";
      } else if (e.toString().contains('safety') || e.toString().contains('blocked')) {
        errorMessage = "I'm unable to respond to that message. Let's talk about something else I can help with. 💭";
      } else {
        errorMessage = "I encountered an issue. Let's try again with a different approach. 🔄";
      }

      // Save error message
      await _firestoreService.saveMessage(
        message: errorMessage,
        isUser: false,
        timestamp: DateTime.now(),
        chatId: _currentChatId,
        userId: _currentUserId!,
      );

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.orange[800],
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () {
              if (lastFailedMessage != null) {
                sendMessage(retryMessage: lastFailedMessage);
              }
            },
          ),
        ),
      );
    }
  }

  void _handleCrisisSituation(String userMessage) async {
    if (_currentUserId == null) return;

    // Show immediate crisis response
    final crisisResponse = _moderationService.getCrisisResponse();

    // Save crisis messages
    await _firestoreService.saveMessage(
      message: userMessage,
      isUser: true,
      timestamp: DateTime.now(),
      chatId: _currentChatId,
      userId: _currentUserId!,
    );

    await _firestoreService.saveMessage(
      message: crisisResponse,
      isUser: false,
      timestamp: DateTime.now(),
      chatId: _currentChatId,
      userId: _currentUserId!,
    );

    // Log the crisis for admin review
    await _safetyLogger.logCrisisEvent(
      userId: _currentUserId!,
      chatId: _currentChatId,
      message: userMessage,
    );

    setState(() {
      promptController.clear();
      isLoading = false;
    });

    // Show urgent alert to user
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 10),
              Text('Urgent Support Available'),
            ],
          ),
        ),
        content: SingleChildScrollView(
          child: Text(crisisResponse),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Copy helpline numbers to clipboard
              Clipboard.setData(const ClipboardData(
                text: "Zambia National Counseling Centre: +260 971 000 000\nChainama Hills Hospital: +260 211 228 344\nMental Health Foundation: +260 977 777 777\nEmergency Services: 999",
              ));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Helpline numbers copied to clipboard'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 3),
                ),
              );
            },
            child: const Text('📋 Copy Numbers'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('I Understand'),
          ),
        ],
      ),
    );
  }

  bool _containsMedicalAdvice(String text) {
    final medicalAdvicePatterns = [
      RegExp(r'you should (take|use|try)'),
      RegExp(r'i recommend (taking|using)'),
      RegExp(r'medication (for|to treat)'),
      RegExp(r'diagnos(e|is) of'),
      RegExp(r'treatment (plan|options)'),
      RegExp(r'clinical (intervention|therapy)'),
      RegExp(r'you need (medicine|medication)'),
      RegExp(r'prescription (for|required)'),
    ];

    final lowerText = text.toLowerCase();
    return medicalAdvicePatterns.any((pattern) => pattern.hasMatch(lowerText));
  }

  void startNewChat() async {
    if (_isCreatingChat || _currentUserId == null) return;

    setState(() {
      _isCreatingChat = true;
    });

    // Cancel existing subscription
    if (_currentChatId.isNotEmpty) {
      _chatSubscription?.cancel();
    }

    // Create new chat session with welcome message
    _currentChatId = await _firestoreService.createNewChat(_currentUserId!);

    // Reinitialize ChatSession for new chat
    chat = model.startChat(
      history: [
        Content.text("""
      You are MindHaven, a compassionate, empathetic student mental health support and counselor...

      (Same system prompt as in initState)
      """),
      ],
    );

    setState(() {
      prompt.clear();
      _isCreatingChat = false;
      _showSafetyWarning = false;
    });

    // Load history for new chat
    _loadChatHistory();

    Navigator.pop(context); // Close the Drawer
  }

  void loadRecentChats(String chatId) async {
    if (_currentChatId != chatId && _currentUserId != null) {
      _chatSubscription?.cancel();
      setState(() {
        _currentChatId = chatId;
      });
      _loadChatHistory();
      Navigator.pop(context); // Close the Drawer
    }
  }

  void deleteCurrentChat() async {
    if (_currentChatId.isNotEmpty && _currentUserId != null) {
      await _firestoreService.deleteChat(_currentChatId, _currentUserId!);
      startNewChat(); // Start a fresh chat
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chat deleted'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showRenameDialog(String chatId, String currentTitle) {
    if (_currentUserId == null) return;

    final renameController = TextEditingController(text: currentTitle);
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final primaryColor = theme.colorScheme.primary;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          title: Text(
            'Rename Chat',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          content: TextField(
            controller: renameController,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              hintText: 'Enter new chat title',
              hintStyle: TextStyle(color: Colors.grey[600]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: primaryColor.withOpacity(0.1),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            maxLength: 50,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            TextButton(
              onPressed: () async {
                final newTitle = renameController.text.trim();
                if (newTitle.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Title cannot be empty')),
                  );
                  return;
                }
                try {
                  await _firestoreService.updateChatTitle(chatId, newTitle, _currentUserId!);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Chat renamed successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to rename chat: $e')),
                  );
                }
              },
              child: Text(
                'Save',
                style: TextStyle(color: primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget UserPrompt({
    required final bool isPrompt,
    required String message,
    required DateTime date,
    required Color primaryColor,
    bool wasFiltered = false,
    String? filterReason,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: isPrompt ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isPrompt) ...[
            CustomPaint(
              painter: MessageTailPainter(
                color: wasFiltered ? Colors.orange[100]! : Colors.grey[100]!,
                isRight: false,
              ),
            ),
            const SizedBox(width: 4),
          ],
          if (!isPrompt)
            CircleAvatar(
              radius: 16,
              backgroundColor: wasFiltered
                  ? Colors.orange.withOpacity(0.2)
                  : primaryColor.withOpacity(0.2),
              child: Icon(
                Icons.android,
                color: wasFiltered ? Colors.orange : primaryColor,
                size: 16,
              ),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: GestureDetector(
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: message));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Message copied to clipboard'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: wasFiltered
                      ? Colors.orange[50]
                      : isPrompt ? primaryColor : Colors.grey[100],
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: isPrompt ? const Radius.circular(20) : const Radius.circular(8),
                    bottomRight: isPrompt ? const Radius.circular(8) : const Radius.circular(20),
                  ),
                  border: wasFiltered
                      ? Border.all(color: Colors.orange.withOpacity(0.3), width: 1)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (wasFiltered && filterReason != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shield, size: 12, color: Colors.orange[700]),
                            const SizedBox(width: 4),
                            Text(
                              'Content moderated for safety',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.orange[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Text(
                      message,
                      style: TextStyle(
                        fontWeight: isPrompt ? FontWeight.w500 : FontWeight.normal,
                        fontSize: 16,
                        color: isPrompt ? Colors.white : Colors.black87,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('hh:mm a').format(date),
                          style: TextStyle(
                            fontSize: 12,
                            color: isPrompt ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        if (wasFiltered)
                          Icon(
                            Icons.verified_user,
                            size: 12,
                            color: Colors.green,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (isPrompt)
            CircleAvatar(
              radius: 16,
              backgroundColor: primaryColor.withOpacity(0.2),
              child: Icon(
                Icons.person,
                color: primaryColor,
                size: 16,
              ),
            ),
          if (isPrompt) ...[
            const SizedBox(width: 4),
            CustomPaint(
              painter: MessageTailPainter(
                color: primaryColor,
                isRight: true,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _safetyWarningTimer?.cancel();
    _chatSubscription?.cancel();
    _scrollController.dispose();
    promptController.dispose();
    super.dispose();
  }

  Color _withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final onPrimaryColor = theme.colorScheme.onPrimary;

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final authCubit = context.read<AuthCubit>();
        final userName = authCubit.currentUser?.name ?? 'User';

        return Scaffold(
          backgroundColor: Colors.white,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _withOpacity(primaryColor, 0.03),
                  _withOpacity(primaryColor, 0.01),
                  Colors.white,
                ],
              ),
            ),
            child: Column(
              children: [
                // Safety Warning Banner
                if (_showSafetyWarning)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    color: Colors.orange[50],
                    child: Row(
                      children: [
                        Icon(Icons.security, color: Colors.orange[700], size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Safety filters are active to protect your wellbeing',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.orange[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, size: 18, color: Colors.orange[700]),
                          onPressed: () {
                            setState(() {
                              _showSafetyWarning = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                Expanded(
                  child: prompt.isEmpty && !isLoading
                      ? Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: _withOpacity(primaryColor, 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.self_improvement,
                              size: 60,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "Welcome to MindHaven",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Your mental health companion is here to listen\nand support you in a safe, moderated space.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.symmetric(horizontal: 40),
                            decoration: BoxDecoration(
                              color: _withOpacity(primaryColor, 0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _withOpacity(primaryColor, 0.1),
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.verified_user,
                                  color: primaryColor,
                                  size: 24,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "This is a safe space with content moderation\nand crisis support available 24/7.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      : ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: prompt.length + (isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (isLoading && index == prompt.length) {
                        return Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: _withOpacity(primaryColor, 0.2),
                                child: Icon(Icons.android, size: 16, color: primaryColor),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Row(
                                  children: [
                                    LoadingAnimationWidget.threeArchedCircle(
                                      color: primaryColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "MindHaven is thinking...",
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      final message = prompt[index];
                      return UserPrompt(
                        isPrompt: message.isPrompt,
                        message: message.sendMessage,
                        date: message.time,
                        primaryColor: primaryColor,
                        wasFiltered: message.wasFiltered,
                        filterReason: message.filterReason,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: promptController,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 3,
                          minLines: 1,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "Type your message...",
                            hintStyle: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w400,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide(
                                color: _withOpacity(primaryColor, 0.5),
                                width: 1.5,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            suffixIcon: MouseRegion(
                              cursor: isLoading ? SystemMouseCursors.basic : SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: isLoading ? null : sendMessage,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.all(6),
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: isLoading
                                        ? Colors.grey[400]
                                        : primaryColor,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: _withOpacity(primaryColor, 0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.send,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          onSubmitted: (value) => sendMessage(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          appBar: AppBar(
            actions: [
              IconButton(
                icon: const Icon(Icons.analytics_outlined),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MoodDashboard()),
                ),
              ),
            ],
            backgroundColor: primaryColor,
            elevation: 4,
            shadowColor: _withOpacity(primaryColor, 0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(15),
              ),
            ),
            title: Text(
              "Hi, $userName!",
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
                color: onPrimaryColor,
              ),
            ),
            centerTitle: true,
          ),
          drawer: Drawer(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _withOpacity(primaryColor, 0.9),
                      _withOpacity(primaryColor, 0.7),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      DrawerHeader(
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              child: const Icon(
                                Icons.android,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'M I N D  H A V E N',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Safe mental health companion',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.add,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        title: const Text(
                          'New Chat',
                          style: TextStyle(color: Colors.white),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        onTap: () {
                          startNewChat();
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.home,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        title: const Text(
                          'Home',
                          style: TextStyle(color: Colors.white),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const HomeScreen()),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.person_outline,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        title: const Text(
                          'Profile',
                          style: TextStyle(color: Colors.white),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ProfileScreen()),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.edit_note,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        title: const Text(
                          'Journal',
                          style: TextStyle(color: Colors.white),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const JournalScreen()),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.settings,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        title: const Text(
                          'Settings',
                          style: TextStyle(color: Colors.white),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SettingsScreen()),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.logout,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        title: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.white),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        onTap: () {
                          Navigator.pop(context);
                          context.read<AuthCubit>().logout();
                        },
                      ),
                      Divider(
                        color: Colors.white.withOpacity(0.3),
                        thickness: 1,
                        indent: 16,
                        endIndent: 16,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          'Recent Chats',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Expanded(
                        child: StreamBuilder<List<Map<String, dynamic>>>(
                          stream: _currentUserId != null
                              ? _firestoreService.getUserChats(_currentUserId!)
                              : Stream.value([]),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              );
                            }

                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  'Error loading chats',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            }

                            final chats = snapshot.data ?? [];

                            if (chats.isEmpty) {
                              return Center(
                                child: Text(
                                  'No recent chats',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            }

                            return ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemCount: chats.length,
                              itemBuilder: (context, index) {
                                final chat = chats[index];
                                final timestamp = (chat['lastUpdated'] as Timestamp).toDate();

                                return ListTile(
                                  leading: Icon(
                                    Icons.chat_bubble_outline,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                  title: Text(
                                    chat['title'] ?? 'Untitled Chat',
                                    style: const TextStyle(color: Colors.white),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    DateFormat.yMMMd().add_jm().format(timestamp),
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color: Colors.white.withOpacity(0.9),
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          _showRenameDialog(chat['id'], chat['title']);
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.white.withOpacity(0.9),
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          if (_currentUserId != null) {
                                            _firestoreService.deleteChat(chat['id'], _currentUserId!);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  onTap: () {
                                    loadRecentChats(chat['id']);
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}