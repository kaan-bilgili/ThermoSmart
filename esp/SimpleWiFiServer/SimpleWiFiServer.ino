 #include <WiFi.h>


#include <HTTPClient.h>

const char* ssid = "COORDINAT_A409";
const char* password = "banu_kaan_1";

void setup() {

  Serial.begin(115200);

  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("WiFi baglaniyor...");
  }

  Serial.println("WiFi baglandi");

  HTTPClient http;

  http.begin("http://10.10.120.40:5000");

  int httpCode = http.GET();

  Serial.print("HTTP Response: ");
  Serial.println(httpCode);

  http.end();
}

void loop() {

}





