import 'package:flutter/material.dart';
import 'package:grpc/grpc_web.dart';
import 'proto/poker.pbgrpc.dart';

void main() {
  runApp(const PokerApp());
}

class PokerApp extends StatelessWidget {
  const PokerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Poker Hand Evaluator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1A237E),
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF1A237E),
          secondary: const Color(0xFF00E676),
          surface: const Color(0xFF161B22),
          background: const Color(0xFF0D1117),
        ),
      ),
      home: const PokerHomePage(),
    );
  }
}

class PokerHomePage extends StatefulWidget {
  const PokerHomePage({Key? key}) : super(key: key);

  @override
  State<PokerHomePage> createState() => _PokerHomePageState();
}

class _PokerHomePageState extends State<PokerHomePage> {
  late GrpcWebClientChannel _channel;
  late PokerServiceClient _client;

  final _holeCardsController = TextEditingController();
  final _communityCardsController = TextEditingController();
  String _result = '';
  String _explanation = '';
  List<String> _displayCards = [];

  @override
  void initState() {
    super.initState();
    _channel = GrpcWebClientChannel.xhr(Uri.parse('http://localhost:8081'));
    _client = PokerServiceClient(_channel);
  }

  @override
  void dispose() {
    _channel.shutdown();
    _holeCardsController.dispose();
    _communityCardsController.dispose();
    super.dispose();
  }

  String _getHandExplanation(String handName) {
    final explanations = {
      'Royal Flush': 'The BEST possible hand! You have A-K-Q-J-10 all of the same suit. This is extremely rare and unbeatable.',
      'Straight Flush': 'Five cards in sequence, all of the same suit. Only a higher straight flush or royal flush can beat this!',
      'Four of a Kind': 'You have four cards of the same rank (like four Kings). Very strong! Only straight flush or better can beat it.',
      'Full House': 'Three cards of one rank plus two cards of another rank (like three 8s and two Kings). This beats straights and flushes!',
      'Flush': 'Five cards all of the same suit, but not in sequence. Pretty strong - beats straights and lower hands.',
      'Straight': 'Five cards in sequence, but not all the same suit. Decent hand that beats three of a kind and pairs.',
      'Three of a Kind': 'Three cards of the same rank (like three Queens). Beats two pair and single pairs.',
      'Two Pair': 'Two different pairs (like two 7s and two Jacks). Beats one pair but loses to three of a kind.',
      'Pair': 'Two cards of the same rank. Better than nothing, but loses to most other hands.',
      'High Card': 'No matching cards or sequences. Your highest card determines your hand strength. Weakest hand type.',
    };
    
    return explanations[handName] ?? 'Hand evaluated successfully.';
  }

  void _evaluateHand() async {
    try {
      final holeCards = _holeCardsController.text.trim().split(RegExp(r'\s+'));
      final communityCards = _communityCardsController.text.trim().split(RegExp(r'\s+')).where((c) => c.isNotEmpty).toList();
      
      if (holeCards.length != 2) {
        setState(() {
          _result = 'Error: Please enter exactly 2 hole cards';
          _explanation = '';
          _displayCards = [];
        });
        return;
      }

      final request = HandRequest()
        ..holeCards.addAll(holeCards)
        ..communityCards.addAll(communityCards);

      final response = await _client.evaluateHand(request);

      setState(() {
        _result = response.bestHandName;
        _explanation = _getHandExplanation(response.bestHandName);
        _displayCards = [...holeCards, ...communityCards];
      });
    } catch (e) {
      setState(() {
        _result = 'Error evaluating hand';
        _explanation = e.toString();
        _displayCards = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0D1117),
              const Color(0xFF1A237E).withOpacity(0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A237E), Color(0xFF283593)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1A237E).withOpacity(0.5),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('♠', style: TextStyle(fontSize: 40, color: Colors.white)),
                          SizedBox(width: 8),
                          Text('♥', style: TextStyle(fontSize: 40, color: Colors.red)),
                          SizedBox(width: 16),
                          Text(
                            'Poker Hand Evaluator',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 16),
                          Text('♦', style: TextStyle(fontSize: 40, color: Colors.red)),
                          SizedBox(width: 8),
                          Text('♣', style: TextStyle(fontSize: 40, color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Analyze Your Texas Hold\'em Hands',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Instructions
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF00E676).withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline, color: Color(0xFF00E676), size: 28),
                          SizedBox(width: 12),
                          Text(
                            'How to Use',
                            style: TextStyle(
                              color: Color(0xFF00E676),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      _buildInstructionRow('Format:', 'Use suit letter + rank (e.g., HA = Ace of Hearts)'),
                      _buildInstructionRow('Suits:', 'H=Hearts ♥  D=Diamonds ♦  C=Clubs ♣  S=Spades ♠'),
                      _buildInstructionRow('Ranks:', 'A, 2, 3, 4, 5, 6, 7, 8, 9, 10, J, Q, K'),
                      _buildInstructionRow('Examples:', 'HA D10 CK S2 H7'),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(0xFF00E676).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '💡 Separate multiple cards with spaces',
                          style: TextStyle(color: Color(0xFF00E676), fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Input Section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Hole Cards (2 cards)',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 12),
                      TextField(
                        controller: _holeCardsController,
                        style: TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 2),
                        decoration: InputDecoration(
                          hintText: 'e.g., HA DK',
                          hintStyle: TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: Color(0xFF0D1117),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.casino, color: Color(0xFF00E676)),
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Community Cards (up to 5 cards)',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 12),
                      TextField(
                        controller: _communityCardsController,
                        style: TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 2),
                        decoration: InputDecoration(
                          hintText: 'e.g., H10 HJ HQ',
                          hintStyle: TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: Color(0xFF0D1117),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.view_week, color: Color(0xFF00E676)),
                        ),
                      ),
                      SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _evaluateHand,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF1A237E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.analytics, size: 24),
                              SizedBox(width: 12),
                              Text(
                                'Evaluate Hand',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Card Display
                if (_displayCards.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161B22),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Cards',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _displayCards.map((card) => _buildPlayingCard(card)).toList(),
                        ),
                      ],
                    ),
                  ),
                ],

                // Result Section
                if (_result.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF00E676).withOpacity(0.2),
                          Color(0xFF00E676).withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Color(0xFF00E676), width: 2),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.emoji_events, color: Color(0xFF00E676), size: 48),
                        SizedBox(height: 16),
                        Text(
                          'Your Hand:',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          _result,
                          style: TextStyle(
                            color: Color(0xFF00E676),
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24),
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Color(0xFF0D1117),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.info, color: Colors.blue, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'What does this mean?',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Text(
                                _explanation,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayingCard(String cardStr) {
    if (cardStr.isEmpty) return SizedBox.shrink();
    
    final suit = cardStr[0].toUpperCase();
    final rank = cardStr.substring(1).toUpperCase();
    
    final suitColor = (suit == 'H' || suit == 'D') ? Colors.red : Colors.black;
    final suitSymbol = {
      'H': '♥',
      'D': '♦',
      'C': '♣',
      'S': '♠',
    }[suit] ?? '';

    return Container(
      width: 80,
      height: 112,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Top left corner
          Positioned(
            top: 6,
            left: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  rank,
                  style: TextStyle(
                    color: suitColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  suitSymbol,
                  style: TextStyle(
                    color: suitColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          // Center
          Center(
            child: Text(
              suitSymbol,
              style: TextStyle(
                color: suitColor,
                fontSize: 40,
              ),
            ),
          ),
          // Bottom right corner (rotated)
          Positioned(
            bottom: 6,
            right: 6,
            child: Transform.rotate(
              angle: 3.14159,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    rank,
                    style: TextStyle(
                      color: suitColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    suitSymbol,
                    style: TextStyle(
                      color: suitColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
