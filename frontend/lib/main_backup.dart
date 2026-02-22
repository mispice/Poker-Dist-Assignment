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
  final _evalCommunityController = TextEditingController();
  String _evalResult = '';

  // Controllers for Compare Hands
  final _p1Hole1Controller = TextEditingController();
  final _p1Hole2Controller = TextEditingController();
  final _p2Hole1Controller = TextEditingController();
  final _p2Hole2Controller = TextEditingController();
  final _compareCommunityController = TextEditingController();
  String _compareResult = '';

  // Controllers for Calculate Probability
  final _probHole1Controller = TextEditingController();
  final _probHole2Controller = TextEditingController();
  final _probCommunityController = TextEditingController();
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
    _evalCommunityController.dispose();
    _p1Hole1Controller.dispose();
    _p1Hole2Controller.dispose();
    _p2Hole1Controller.dispose();
    _p2Hole2Controller.dispose();
    _compareCommunityController.dispose();
    _probHole1Controller.dispose();
    _probHole2Controller.dispose();
    _probCommunityController.dispose();
    _probSimsController.dispose();
    super.dispose();
  }

  void _evaluateHand() async {
    try {
      final request = HandRequest()
        ..holeCards.addAll([_evalHole1Controller.text, _evalHole2Controller.text])
        ..communityCards.addAll(_evalCommunityController.text.split(' ').where((c) => c.isNotEmpty));

      final response = await _client.evaluateHand(request);

      setState(() {
        _evalResult = '${response.bestHandName} (Rank: ${response.handRankValue})';
      });
    } catch (e) {
      setState(() {
        _evalResult = 'Error: ${e.toString()}';
      });
    }
  }

  void _compareHands() async {
    try {
      final hand1 = HandRequest()
        ..holeCards.addAll([_p1Hole1Controller.text, _p1Hole2Controller.text])
        ..communityCards.addAll(_compareCommunityController.text.split(' ').where((c) => c.isNotEmpty));
      
      final hand2 = HandRequest()
        ..holeCards.addAll([_p2Hole1Controller.text, _p2Hole2Controller.text])
        ..communityCards.addAll(_compareCommunityController.text.split(' ').where((c) => c.isNotEmpty));
      
      final request = CompareRequest()
        ..hand1 = hand1
        ..hand2 = hand2;

      final response = await _client.compareHands(request);

      setState(() {
        if (response.winner == 0) {
          _compareResult = 'Tie!\nP1: ${response.hand1Result.bestHandName} (${response.hand1Result.handRankValue})\nP2: ${response.hand2Result.bestHandName} (${response.hand2Result.handRankValue})';
        } else if (response.winner == 1) {
          _compareResult = 'Player 1 Wins!\nP1: ${response.hand1Result.bestHandName} (${response.hand1Result.handRankValue})\nP2: ${response.hand2Result.bestHandName} (${response.hand2Result.handRankValue})';
        } else {
          _compareResult = 'Player 2 Wins!\nP1: ${response.hand1Result.bestHandName} (${response.hand1Result.handRankValue})\nP2: ${response.hand2Result.bestHandName} (${response.hand2Result.handRankValue})';
        }
      });
    } catch (e) {
      setState(() {
        _compareResult = 'Error: ${e.toString()}';
      });
    }
  }

  void _calculateProbability() async {
    try {
      final request = SimRequest()
        ..holeCards.addAll([_probHole1Controller.text, _probHole2Controller.text])
        ..communityCards.addAll(_probCommunityController.text.split(' ').where((c) => c.isNotEmpty))
        ..numSimulations = int.parse(_probSimsController.text);

      final response = await _client.calculateProbability(request);

      setState(() {
        _probResult = 'Win: ${(response.winProbability * 100).toStringAsFixed(2)}%\n'
            'Tie: ${(response.tieProbability * 100).toStringAsFixed(2)}%\n'
            'Lose: ${(response.loseProbability * 100).toStringAsFixed(2)}%';
      });
    } catch (e) {
      setState(() {
        _probResult = 'Error: ${e.toString()}';
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
                        const SizedBox(height: 8),
                        Text(
                          '• Separate multiple cards with spaces',
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
                    _buildCardInput(
                      context,
                      controller: _evalHole1Controller,
                      label: 'Hole Card 1',
                      hint: 'e.g., HA',
                    ),
                    const SizedBox(height: 12),
                    _buildCardInput(
                      context,
                      controller: _evalHole2Controller,
                      label: 'Hole Card 2',
                      hint: 'e.g., HK',
                    ),
                    const SizedBox(height: 12),
                    _buildCardInput(
                      context,
                      controller: _evalCommunityController,
                      label: 'Community Cards',
                      hint: 'e.g., HQ HJ H10 D9 S8',
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
                    const SizedBox(height: 12),
                    _buildCardInput(
                      context,
                      controller: _compareCommunityController,
                      label: 'Community Cards',
                      hint: 'e.g., HQ HJ H10 D9 S8',
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
                    _buildCardInput(
                      context,
                      controller: _probHole1Controller,
                      label: 'Hole Card 1',
                      hint: 'e.g., HA',
                    ),
                    const SizedBox(height: 12),
                    _buildCardInput(
                      context,
                      controller: _probHole2Controller,
                      label: 'Hole Card 2',
                      hint: 'e.g., HK',
                    ),
                    const SizedBox(height: 12),
                    _buildCardInput(
                      context,
                      controller: _probCommunityController,
                      label: 'Community Cards (optional)',
                      hint: 'e.g., HQ HJ H10',
                    ),
                    const SizedBox(height: 12),
                    _buildCardInput(
                      context,
                      controller: _probSimsController,
                      label: 'Number of Simulations',
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
}
