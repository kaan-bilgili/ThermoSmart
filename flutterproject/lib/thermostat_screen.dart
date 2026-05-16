import 'graphs_page.dart';
import 'package:flutter/material.dart';
import 'thermostat.dart';
import 'mqtt_service.dart';

class ThermostatScreen extends StatefulWidget {
  const ThermostatScreen({super.key});

  @override
  State<ThermostatScreen> createState() => _ThermostatScreenState();
}

class _ThermostatScreenState extends State<ThermostatScreen> {
  static const textColor = Color(0xFFFFFFFD);

  double currentTemp = 27;
  double setTemp = 26;
  String acStatus = "IDLE";
  late MQTTService mqttService;

  void updateLogic() {
    double diff = currentTemp - setTemp;

    if (diff.abs() <= 1) {
      acStatus = "IDLE";
    } else if (diff > 1) {
      acStatus = "Cooling";
    } else {
      acStatus = "Heating";
    }
  }

  @override
  void initState() {
    super.initState();

    mqttService = MQTTService();
    mqttService.connect();

    mqttService.onTemperatureChanged = (temp) {
      setState(() {
        currentTemp = temp;
        updateLogic();
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0F2027),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 52,
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.keyboard_backspace,
                        color: textColor,
                      ),
                    ),
                    Container(
                      width: 1,
                      color: textColor,
                      margin: const EdgeInsets.only(left: 10, right: 10),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'ThermoSmart',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Kontes Room',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 5),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InfoIcon(
                          icon: const Icon(
                            Icons.thermostat,
                            color: Color(0xFFA9A6AF),
                            size: 45,
                          ),
                          text:
                              '${currentTemp.toStringAsFixed(1)}°C is the current temperature.',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Center(
                  child: Thermostat(
                    radius: 150,
                    turnOn: true,
                    modeIcon: const Icon(
                      Icons.loop,
                      color: Colors.white,
                    ),
                    textStyle: const TextStyle(
                      color: textColor,
                      fontSize: 34,
                    ),
                    minValue: 18,
                    maxValue: 38,
                    initialValue: 26,
                    onValueChanged: (value) {
                      setState(() {
                        setTemp = value.toDouble();
                        updateLogic();
                      });

                      mqttService.publishSetpoint(value.toDouble());
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                acStatus == "IDLE"
                    ? "IDLE"
                    : acStatus == "Cooling"
                        ? "Cooling ❄️"
                        : "Heating 🔥",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: acStatus == "IDLE"
                      ? const Color(0xFFA9A6AF)
                      : acStatus == "Cooling"
                          ? const Color(0xFF4EC4EC)
                          : Colors.orange,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 20),

              Container(
                height: 1,
                color: Colors.white.withOpacity(0.2),
              ),

              Container(
                margin: const EdgeInsets.symmetric(vertical: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    BottomIndicator(
                      icon: Icon(
                        Icons.ac_unit,
                        color: acStatus == "Cooling"
                            ? const Color(0xFF4EC4EC)
                            : Colors.white,
                      ),
                      text: "Cooling",
                    ),

                    BottomIndicator(
                      icon: Icon(
                        Icons.local_fire_department,
                        color: acStatus == "Heating"
                            ? Colors.orange
                            : Colors.white,
                      ),
                      text: "Heating",
                    ),

                    BottomButton(
                      icon: const Icon(
                        Icons.bar_chart,
                        color: Colors.white,
                      ),
                      text: "Graphs",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GraphsPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoIcon extends StatelessWidget {
  final Widget icon;
  final String text;

  const InfoIcon({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        icon,
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFFA9A6AF),
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 12),
      ],
    );
  }
}

class BottomIndicator extends StatelessWidget {
  final Widget icon;
  final String text;

  const BottomIndicator({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 52,
          height: 52,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF3F5BFA)),
          ),
          child: Center(child: icon),
        ),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class BottomButton extends StatelessWidget {
  final Widget icon;
  final String text;
  final VoidCallback onTap;

  const BottomButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF3F5BFA)),
            ),
            child: Center(child: icon),
          ),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}