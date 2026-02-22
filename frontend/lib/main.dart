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
        cardTheme: CardTheme(
          color: const Color(0xFF161B22),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A237E),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF0D1117),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[800]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[800]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2),
          ),
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

  // Controllers for Evaluate Hand
  final _evalHole1Controller = TextEditingController();
  final _evalHole2Controller = TextEditingController();
  final List<TextEditingController> _evalCommunityControllers = 
      List.generate(5, (_) => TextEditingController());
  String _evalResult = '';

  // Controllers for Compare Hands
  final _p1Hole1Controller = TextEditingController();
  final _p1Hole2Controller = TextEditingController();
  final _p2Hole1Controller = TextEditingController();
  final _p2Hole2Controller = TextEditingController();
  final List<TextEditingController> _compareCommunityControllers = 
      List.generate(5, (_) => TextEditingController());
  String _compareResult = '';

  // Controllers for Calculate Probability
  final _probHole1Controller = TextEditingController();
  final _probHole2Controller = TextEditingController();
  final List<TextEditingController> _probCommunityControllers = 
      List.generate(5, (_) => TextEditingController());
  final _probSimsController = TextEditingController(text: '10000');
  String _probResult = '';

  @override
  void initState() {
    super.initState();
    _channel = GrpcWebClientChannel.xhr(Uri.parse('http://localhost:8081'));
    _client = PokerServiceClient(_channel);
  }

  @override
  void dispose() {
    _channel.shutdown();
    _evalHole1Controller.dispose();
    _evalHole2Controller.dispose();
    for (var controller in _evalCommunityControllers) {
      controller.dispose();
    }
    _p1Hole1Controller.dispose();
    _p1Hole2Controller.dispose();
    _p2Hole1Controller.dispose();
    _p2Hole2Controller.dispose();
    for (var controller in _compareCommunityControllers) {
      controller.dispose();
    }
    _probHole1Controller.dispose();
    _probHole2Controller.dispose();
    for (var controller in _probCommunityControllers) {
      controller.dispose();
    }
    _probSimsController.dispose();
    super.dispose();
  }

  // Validate card format: must be 2-3 characters: Suit (H/D/C/S) + Rank (2-10/J/Q/K/A)
  String? _validateCard(String card) {
    if (card.isEmpty) return null; // Empty is okay for optional cards
    
    card = card.trim().toUpperCase();
    
    // Check length
    if (card.length < 2 || card.length > 3) {
      return 'Invalid format. Use format like HA, D10, SK';
    }
    
    // Check suit (first character)
    final suit = card[0];
    if (!['H', 'D', 'C', 'S'].contains(suit)) {
      return 'Invalid suit "$suit". Use H (Hearts), D (Diamonds), C (Clubs), or S (Spades)';
    }
    
    // Check rank (remaining characters)
    final rank = card.substring(1);
    final validRanks = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A', 'T'];
    if (!validRanks.contains(rank)) {
      return 'Invalid rank "$rank". Use 2-10, J, Q, K, or A';
    }
    
    return null; // Valid
  }

  // Validate all cards in a list and return error if any
  String? _validateCards(List<String> cards, {int? minCards, int? maxCards, String fieldName = 'Cards'}) {
    final nonEmptyCards = cards.where((c) => c.trim().isNotEmpty).toList();
    
    if (minCards != null && nonEmptyCards.length < minCards) {
      return '$fieldName: Need at least $minCards card(s), got ${nonEmptyCards.length}';
    }
    
    if (maxCards != null && nonEmptyCards.length > maxCards) {
      return '$fieldName: Maximum $maxCards card(s) allowed, got ${nonEmptyCards.length}';
    }
    
    for (var card in nonEmptyCards) {
      final error = _validateCard(card);
      if (error != null) {
        return '$fieldName: $error';
      }
    }
    
    // Check for duplicates
    final seen = <String>{};
    for (var card in nonEmptyCards) {
      final normalized = card.trim().toUpperCase();
      if (seen.contains(normalized)) {
        return '$fieldName: Duplicate card "$normalized"';
      }
      seen.add(normalized);
    }
    
    return null; // All valid
  }

  void _evaluateHand() async {
    try {
      final holeCards = [
        _evalHole1Controller.text.trim().toUpperCase(),
        _evalHole2Controller.text.trim().toUpperCase(),
      ];
      
      final communityCards = _evalCommunityControllers
          .map((c) => c.text.trim().toUpperCase())
          .where((c) => c.isNotEmpty)
          .toList();
      
      // Validate hole cards
      final holeError = _validateCards(holeCards, minCards: 2, maxCards: 2, fieldName: 'Hole cards');
      if (holeError != null) {
        setState(() {
          _evalResult = '❌ $holeError';
        });
        return;
      }
      
      // Validate community cards
      final communityError = _validateCards(communityCards, minCards: 0, maxCards: 5, fieldName: 'Community cards');
      if (communityError != null) {
        setState(() {
          _evalResult = '❌ $communityError';
        });
        return;
      }
      
      // Check total cards
      final totalCards = holeCards.length + communityCards.length;
      if (totalCards < 5) {
        setState(() {
          _evalResult = '❌ Need at least 5 cards total (2 hole + 3+ community)';
        });
        return;
      }
      
      // Check for duplicates across all cards
      final allCards = [...holeCards, ...communityCards];
      final duplicateError = _validateCards(allCards, fieldName: 'All cards');
      if (duplicateError != null && duplicateError.contains('Duplicate')) {
        setState(() {
          _evalResult = '❌ $duplicateError';
        });
        return;
      }
      
      final request = HandRequest()
        ..holeCards.addAll(holeCards)
        ..communityCards.addAll(communityCards);

      final response = await _client.evaluateHand(request);

      setState(() {
        _evalResult = '✅ ${response.bestHandName}\nRank: ${response.handRankValue}';
      });
    } catch (e) {
      setState(() {
        _evalResult = '❌ Error: ${e.toString()}';
      });
    }
  }

  void _compareHands() async {
    try {
      final p1HoleCards = [
        _p1Hole1Controller.text.trim().toUpperCase(),
        _p1Hole2Controller.text.trim().toUpperCase(),
      ];
      
      final p2HoleCards = [
        _p2Hole1Controller.text.trim().toUpperCase(),
        _p2Hole2Controller.text.trim().toUpperCase(),
      ];
      
      final communityCards = _compareCommunityControllers
          .map((c) => c.text.trim().toUpperCase())
          .where((c) => c.isNotEmpty)
          .toList();
      
      // Validate player 1 hole cards
      final p1Error = _validateCards(p1HoleCards, minCards: 2, maxCards: 2, fieldName: 'Player 1 hole cards');
      if (p1Error != null) {
        setState(() {
          _compareResult = '❌ $p1Error';
        });
        return;
      }
      
      // Validate player 2 hole cards
      final p2Error = _validateCards(p2HoleCards, minCards: 2, maxCards: 2, fieldName: 'Player 2 hole cards');
      if (p2Error != null) {
        setState(() {
          _compareResult = '❌ $p2Error';
        });
        return;
      }
      
      // Validate community cards
      final communityError = _validateCards(communityCards, minCards: 0, maxCards: 5, fieldName: 'Community cards');
      if (communityError != null) {
        setState(() {
          _compareResult = '❌ $communityError';
        });
        return;
      }
      
      // Check total cards
      final totalCards = p1HoleCards.length + communityCards.length;
      if (totalCards < 5) {
        setState(() {
          _compareResult = '❌ Need at least 5 cards total (2 hole + 3+ community)';
        });
        return;
      }
      
      // Check for duplicates across all cards
      final allCards = [...p1HoleCards, ...p2HoleCards, ...communityCards];
      final duplicateError = _validateCards(allCards, fieldName: 'All cards');
      if (duplicateError != null && duplicateError.contains('Duplicate')) {
        setState(() {
          _compareResult = '❌ $duplicateError';
        });
        return;
      }
      
      final hand1 = HandRequest()
        ..holeCards.addAll(p1HoleCards)
        ..communityCards.addAll(communityCards);
      
      final hand2 = HandRequest()
        ..holeCards.addAll(p2HoleCards)
        ..communityCards.addAll(communityCards);
      
      final request = CompareRequest()
        ..hand1 = hand1
        ..hand2 = hand2;

      final response = await _client.compareHands(request);

      setState(() {
        if (response.winner == 0) {
          _compareResult = '🤝 Tie!\n\nPlayer 1: ${response.hand1Result.bestHandName}\nRank: ${response.hand1Result.handRankValue}\n\nPlayer 2: ${response.hand2Result.bestHandName}\nRank: ${response.hand2Result.handRankValue}';
        } else if (response.winner == 1) {
          _compareResult = '🏆 Player 1 Wins!\n\nPlayer 1: ${response.hand1Result.bestHandName}\nRank: ${response.hand1Result.handRankValue}\n\nPlayer 2: ${response.hand2Result.bestHandName}\nRank: ${response.hand2Result.handRankValue}';
        } else {
          _compareResult = '🏆 Player 2 Wins!\n\nPlayer 1: ${response.hand1Result.bestHandName}\nRank: ${response.hand1Result.handRankValue}\n\nPlayer 2: ${response.hand2Result.bestHandName}\nRank: ${response.hand2Result.handRankValue}';
        }
      });
    } catch (e) {
      setState(() {
        _compareResult = '❌ Error: ${e.toString()}';
      });
    }
  }

  void _calculateProbability() async {
    try {
      final holeCards = [
        _probHole1Controller.text.trim().toUpperCase(),
        _probHole2Controller.text.trim().toUpperCase(),
      ];
      
      final communityCards = _probCommunityControllers
          .map((c) => c.text.trim().toUpperCase())
          .where((c) => c.isNotEmpty)
          .toList();
      
      // Validate hole cards
      final holeError = _validateCards(holeCards, minCards: 2, maxCards: 2, fieldName: 'Hole cards');
      if (holeError != null) {
        setState(() {
          _probResult = '❌ $holeError';
        });
        return;
      }
      
      // Validate community cards
      final communityError = _validateCards(communityCards, minCards: 0, maxCards: 5, fieldName: 'Community cards');
      if (communityError != null) {
        setState(() {
          _probResult = '❌ $communityError';
        });
        return;
      }
      
      // Check for duplicates across all cards
      final allCards = [...holeCards, ...communityCards];
      final duplicateError = _validateCards(allCards, fieldName: 'All cards');
      if (duplicateError != null && duplicateError.contains('Duplicate')) {
        setState(() {
          _probResult = '❌ $duplicateError';
        });
        return;
      }
      
      // Validate number of simulations
      final numSims = int.tryParse(_probSimsController.text);
      if (numSims == null || numSims < 100 || numSims > 100000) {
        setState(() {
          _probResult = '❌ Number of simulations must be between 100 and 100,000';
        });
        return;
      }
      
      final request = SimRequest()
        ..holeCards.addAll(holeCards)
        ..communityCards.addAll(communityCards)
        ..numSimulations = numSims;

      final response = await _client.calculateProbability(request);

      setState(() {
        _probResult = '📊 Probability Results:\n\n'
            '🏆 Win:  ${(response.winProbability * 100).toStringAsFixed(2)}%\n'
            '🤝 Tie:  ${(response.tieProbability * 100).toStringAsFixed(2)}%\n'
            '❌ Lose: ${(response.loseProbability * 100).toStringAsFixed(2)}%\n\n'
            'Based on $numSims simulations';
      });
    } catch (e) {
      setState(() {
        _probResult = '❌ Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0D1117),
              const Color(0xFF1A237E).withOpacity(0.2),
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
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A237E), Color(0xFF283593)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1A237E).withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        '🃏 Poker Hand Evaluator',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Professional Poker Analysis Tool',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Instructions Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info_outline, color: Color(0xFF00E676)),
                            const SizedBox(width: 8),
                            Text(
                              'Card Format Guide',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: const Color(0xFF00E676),
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Enter cards as: <Suit><Rank>',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Suits: H (Hearts), D (Diamonds), C (Clubs), S (Spades)',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white60),
                        ),
                        Text(
                          '• Ranks: A, 2-10, J, Q, K',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white60),
                        ),
                        Text(
                          '• Examples: HA (Ace of Hearts), D10 (10 of Diamonds), SK (King of Spades)',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white60),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Evaluate Hand Section
                _buildSection(
                  context,
                  title: '🎯 Evaluate Hand',
                  icon: Icons.casino,
                  children: [
                    Text(
                      'Your Hole Cards',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: const Color(0xFF00E676),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildCardInput(
                            context,
                            controller: _evalHole1Controller,
                            label: 'Card 1',
                            hint: 'e.g., HA',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildCardInput(
                            context,
                            controller: _evalHole2Controller,
                            label: 'Card 2',
                            hint: 'e.g., HK',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Community Cards (Optional)',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: const Color(0xFF00E676),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        for (int i = 0; i < 5; i++) ...[
                          if (i > 0) const SizedBox(width: 8),
                          Expanded(
                            child: _buildCardInput(
                              context,
                              controller: _evalCommunityControllers[i],
                              label: i < 3 ? 'Flop ${i + 1}' : (i == 3 ? 'Turn' : 'River'),
                              hint: '',
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _evaluateHand,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Evaluate'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                    if (_evalResult.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildResultCard(_evalResult),
                    ],
                  ],
                ),
                const SizedBox(height: 32),

                // Compare Hands Section
                _buildSection(
                  context,
                  title: '⚔️ Compare Hands',
                  icon: Icons.compare_arrows,
                  children: [
                    Text(
                      'Player 1',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: const Color(0xFF00E676),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildCardInput(
                            context,
                            controller: _p1Hole1Controller,
                            label: 'Card 1',
                            hint: 'HA',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildCardInput(
                            context,
                            controller: _p1Hole2Controller,
                            label: 'Card 2',
                            hint: 'HK',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Player 2',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: const Color(0xFF00E676),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildCardInput(
                            context,
                            controller: _p2Hole1Controller,
                            label: 'Card 1',
                            hint: 'DA',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildCardInput(
                            context,
                            controller: _p2Hole2Controller,
                            label: 'Card 2',
                            hint: 'DK',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Community Cards (Optional)',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: const Color(0xFF00E676),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        for (int i = 0; i < 5; i++) ...[
                          if (i > 0) const SizedBox(width: 8),
                          Expanded(
                            child: _buildCardInput(
                              context,
                              controller: _compareCommunityControllers[i],
                              label: i < 3 ? 'Flop ${i + 1}' : (i == 3 ? 'Turn' : 'River'),
                              hint: '',
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _compareHands,
                      icon: const Icon(Icons.compare),
                      label: const Text('Compare'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                    if (_compareResult.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildResultCard(_compareResult),
                    ],
                  ],
                ),
                const SizedBox(height: 32),

                // Calculate Probability Section
                _buildSection(
                  context,
                  title: '📊 Calculate Win Probability',
                  icon: Icons.analytics,
                  children: [
                    Text(
                      'Your Hole Cards',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: const Color(0xFF00E676),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildCardInput(
                            context,
                            controller: _probHole1Controller,
                            label: 'Card 1',
                            hint: 'e.g., HA',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildCardInput(
                            context,
                            controller: _probHole2Controller,
                            label: 'Card 2',
                            hint: 'e.g., HK',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Community Cards (Optional)',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: const Color(0xFF00E676),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        for (int i = 0; i < 5; i++) ...[
                          if (i > 0) const SizedBox(width: 8),
                          Expanded(
                            child: _buildCardInput(
                              context,
                              controller: _probCommunityControllers[i],
                              label: i < 3 ? 'Flop ${i + 1}' : (i == 3 ? 'Turn' : 'River'),
                              hint: '',
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildCardInput(
                      context,
                      controller: _probSimsController,
                      label: 'Number of Simulations (100-100,000)',
                      hint: '10000',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _calculateProbability,
                      icon: const Icon(Icons.calculate),
                      label: const Text('Calculate'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                    if (_probResult.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildResultCard(_probResult),
                    ],
                  ],
                ),
                const SizedBox(height: 24),

                // Footer
                Center(
                  child: Text(
                    'Powered by gRPC & Monte Carlo Simulation',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white38,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF1A237E), size: 28),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildCardInput(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: Colors.grey[400]),
        hintStyle: TextStyle(color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildResultCard(String result) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00E676), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF00E676)),
              const SizedBox(width: 8),
              Text(
                'Result',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF00E676),
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            result,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  // Visual Playing Card Widget
  Widget _buildPlayingCard(String cardStr) {
    if (cardStr.isEmpty) return const SizedBox.shrink();
    
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
      width: 70,
      height: 98,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Top left corner
          Positioned(
            top: 4,
            left: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  rank,
                  style: TextStyle(
                    color: suitColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  suitSymbol,
                  style: TextStyle(
                    color: suitColor,
                    fontSize: 14,
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
                fontSize: 36,
              ),
            ),
          ),
          // Bottom right corner (rotated)
          Positioned(
            bottom: 4,
            right: 4,
            child: Transform.rotate(
              angle: 3.14159,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    rank,
                    style: TextStyle(
                      color: suitColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    suitSymbol,
                    style: TextStyle(
                      color: suitColor,
                      fontSize: 14,
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
