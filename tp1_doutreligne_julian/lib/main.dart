import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(textTheme: GoogleFonts.barlowTextTheme()),
      title: 'Flutter Demo',
      home: const PortfolioPage(),
    );
  }
}

class PortfolioPage extends StatelessWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          spacing: 40,
          children: [
            // On va ajouter nos widgets ici étape par étape
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.all(10),
                  height: 300,
                  width: double.infinity,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage('assets/images/background.jpg'),
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  )
                ),
                Positioned(
                  top: 20,
                  right: 20,
                  child: IconButton(
                    icon: const Icon(Icons.share, color: Colors.white, size: 30),
                    onPressed: () {
                      // Action de partage
                    },
                  )
                ),
                Positioned(
                  bottom: 0,
                  child: Transform.translate(
                    offset: const Offset(0, 50),
                    child: Container(
                      height: 250,
                      width: 250,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(50),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(125),
                        image: DecorationImage(
                          image: AssetImage('assets/images/profil.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ]
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                Transform.translate(
                  offset: const Offset(-90, 0),
                  child: SizedBox(
                    height: 200,
                    width: 150,
                    child: Transform.rotate(
                      angle: -0.1,
                      child: Container (
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.shade400,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(50),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Julian",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Date de naissance",
                                    style: TextStyle(
                                      color: Colors.grey.shade100,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '05/01/2006',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Ville",
                                    style: TextStyle(
                                      color: Colors.grey.shade100,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Limoges',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Profession",
                                    style: TextStyle(
                                      color: Colors.grey.shade100,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Développeur',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        )
                      )
                    ),
                  )
                ),
                Transform.translate(
                  offset: const Offset(90, 0),
                  child: SizedBox(
                    height: 200,
                    width: 150,
                    child: Transform.rotate(
                      angle: 0.1,
                      child: Container (
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.shade400,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(50),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 10,
                          children: [
                            Image(
                              image: AssetImage("assets/images/qrcode.png"),
                              width: 100,
                              height: 100,
                            ),
                            Text("Scan me",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      )
                    ),
                  )
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TechIcon(
                  icon: FontAwesomeIcons.flutter,
                  gradientColors: [Color(0xFFEA842B), Color.fromARGB(255, 237, 171, 114)],
                  url: 'https://flutter.dev',
                ),
                TechIcon(
                  icon: FontAwesomeIcons.angular,
                  gradientColors: [Color(0xffdd0031), Color.fromARGB(255, 239, 100, 79)],
                  url: 'https://angular.dev',
                ),
                TechIcon(
                  icon: FontAwesomeIcons.react,
                  gradientColors: [Color(0xFF43D6FF), Color.fromARGB(255, 130, 223, 250)],
                  url: 'https://react.dev',
                ),
                TechIcon(
                  icon: FontAwesomeIcons.wordpress,
                  gradientColors: [Color(0xfff05032), Color.fromARGB(255, 248, 130, 100)],
                  url: 'https://wordpress.org',
                ),
                TechIcon(
                  icon: FontAwesomeIcons.vuejs,
                  gradientColors: [Color(0xff764abc), Color.fromARGB(255, 130, 100, 223)],
                  url: 'https://vuejs.org',
                ),
              ]
            )
          ],
        ),
      ),
    );
  }
}

class TechIcon extends StatelessWidget {
  final IconData icon;
  final List<Color> gradientColors;
  final String url;

  const TechIcon({
    super.key,
    required this.icon,
    required this.gradientColors,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        width: 60,
        height: 60,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(30),
              blurRadius: 4,
              offset: const Offset(0, 4),
            ),
          ],
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: FaIcon(icon, color: Colors.white),
      ),
    );
  }
}
