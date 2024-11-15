// Incluyendo librerías para procesamiento y comunicación con Pure Data
import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress pureDataAddress;

// Variables para los datos
Table climateData;
float[] temperatures, co2Emissions, seaLevelRise, precipitation, humidity, windSpeed;
int currentDataIndex = 0;
float ringScale = 1.0;

// Variables de partículas
PVector[] particles;

void setup() {
  size(800, 600); // Cambiado a 2D, sin P3D
  oscP5 = new OscP5(this, 12000);
  pureDataAddress = new NetAddress("127.0.0.1", 8000);

  climateData = loadTable("climate_change_data.csv", "header");

  int rowCount = climateData.getRowCount();
  temperatures = new float[rowCount];
  co2Emissions = new float[rowCount];
  seaLevelRise = new float[rowCount];
  precipitation = new float[rowCount];
  humidity = new float[rowCount];
  windSpeed = new float[rowCount];

  for (int i = 0; i < rowCount; i++) {
    TableRow row = climateData.getRow(i);
    temperatures[i] = row.getFloat("Temperature");
    co2Emissions[i] = row.getFloat("CO2 Emissions");
    seaLevelRise[i] = row.getFloat("Sea Level Rise");
    precipitation[i] = row.getFloat("Precipitation");
    humidity[i] = row.getFloat("Humidity");
    windSpeed[i] = row.getFloat("Wind Speed");
  }

  particles = new PVector[500];
  for (int i = 0; i < particles.length; i++) {
    particles[i] = new PVector(random(width), random(height));
  }
}
void keyPressed() {
  if (key == '+') {
    ringScale += 0.1;
  } else if (key == '-') {
    ringScale = max(0.1, ringScale - 0.1); // Evita que el tamaño sea menor a 0.1
  }
}
void draw() {
  background(255);
  
  // Llama a la visualización principal que muestra todas las visualizaciones juntas
  drawMainVisualization();
  
  currentDataIndex = (currentDataIndex + 1) % temperatures.length;
}

// Visualización principal que combina todas las ideas en una sola pantalla
void drawMainVisualization() {
  
  
    // Enviar los valores puros de cada parámetro en forma de onda
  sendTemperatureWave(temperatures);
  sendCO2Wave(co2Emissions);
  sendSeaLevelWave(seaLevelRise);
  sendPrecipitationWave(precipitation);
  sendHumidityWave(humidity);
  sendWindSpeedWave(windSpeed);

  // Enviar solo los valores altos (puedes ajustar el umbral)
  float temperatureThreshold = 30;
  sendHighTemperatures(temperatures, temperatureThreshold);

  // Enviar la media de cada parámetro
  sendTemperatureMean(temperatures);
  sendCO2Mean(co2Emissions);
  sendSeaLevelMean(seaLevelRise);
  sendPrecipitationMean(precipitation);
  sendHumidityMean(humidity);
  sendWindSpeedMean(windSpeed);
  
  
  
  // Visualización de campo de partículas
  drawParticleField(precipitation, humidity);
  
  // Visualización de gráfico de líneas
  drawLineGraph(temperatures);
  
  // Visualización de onda de datos
  drawDataWaves(co2Emissions);
  
  // Visualización de gráfico de barras
  drawBarGraph(temperatures, "Temperature", color(0, 0, 255), color(255, 0, 0));
  
  // Visualización de anillos concéntricos
  pushMatrix();
  drawConcentricRings(precipitation, humidity);
  popMatrix();
  
  
}

// Gráfico de barras
void drawBarGraph(float[] data, String label, color lowColor, color highColor) {
  int barCount = 50;
  float barWidth = width / (float) barCount;
  float maxBarHeight = height / 2;  // Ajusta la altura máxima de las barras (en este caso, la mitad de la altura de la ventana)

  for (int i = 0; i < barCount; i++) {
    int dataIdx = (currentDataIndex + i) % data.length;
    float value = data[dataIdx];
    float barHeight = map(value, -5, 35, 0, maxBarHeight);  // Mapea a una altura máxima más baja

    fill(lerpColor(lowColor, highColor, map(value, -5, 35, 0, 1)));
    rect(i * barWidth, height - barHeight, barWidth - 2, barHeight);
  }
  fill(0);
  text(label, 10, 20);
}

// Anillos concéntricos
void drawConcentricRings(float[] data1, float[] data2) {
  translate(width / 2, height / 2);
  noFill();
  for (int i = 0; i < data1.length; i += 10) {
    float radius = map(data1[(currentDataIndex + i) % data1.length], 0, 100, 50, 150) * ringScale;
    stroke(map(data2[(currentDataIndex + i) % data2.length], 0, 100, 0, 255), 100, 255);
    ellipse(0, 0, radius, radius);
  }
}

// Visualización de la onda de datos
void drawDataWaves(float[] data) {
  noFill();
  stroke(200, 0, 0);
  beginShape();
  
  for (int i = 0; i < data.length; i++) {
    float x = map(i, 0, data.length, 0, width);
    float y = height / 2 + sin(frameCount * 0.05 + i * 0.1) * map(data[i], 180, 580, 10, 100);
    vertex(x, y);

    if (i == currentDataIndex % data.length) {
      OscMessage msg = new OscMessage("/waveData");
      msg.add(y); 
      oscP5.send(msg, pureDataAddress);
    }
  }
  endShape();
}

// Gráfico de líneas
void drawLineGraph(float[] data) {
  float xStep = width / (float) data.length;
  stroke(100, 0, 100);
  noFill();
  beginShape();
  for (int i = 0; i < data.length; i++) {
    float x = i * xStep;
    float y = map(data[(currentDataIndex + i) % data.length], -5, 35, height, 0);
    vertex(x, y);
  }
  endShape();
}

// Visualización de campo de partículas
void drawParticleField(float[] data1, float[] data2) {
  for (int i = 0; i < data1.length; i++) {
    float x = random(width);
    float y = random(height);
    float size = map(mouseY, 0, height, 2, 10);
    float alpha = map(data2[(currentDataIndex + i) % data2.length], 0, 100, 50, 255);
    fill(0, 0, 255, alpha);
    noStroke();
    ellipse(x, y, size, size);
  }
}

// Función para enviar los valores puros de temperatura en forma de onda
void sendTemperatureWave(float[] data) {
  for (int i = 0; i < data.length; i++) {
    if (i == currentDataIndex % data.length) {  // Enviar un solo valor en cada fotograma
      OscMessage msg = new OscMessage("/temperatureWave");
      msg.add(data[i]);  // Enviar el valor puro de temperatura
      oscP5.send(msg, pureDataAddress);
    }
  }
}

// Función para enviar solo los valores altos de temperatura (por encima del umbral)
void sendHighTemperatures(float[] temperatures, float threshold) {
  for (int i = 0; i < temperatures.length; i++) {
    if (temperatures[i] > threshold) {
      OscMessage highTempMsg = new OscMessage("/highTemperature");
      highTempMsg.add(temperatures[i]);
      oscP5.send(highTempMsg, pureDataAddress);
    }
  }
}

// Función para enviar la media de la temperatura
void sendTemperatureMean(float[] temperatures) {
  float sum = 0;
  for (float temp : temperatures) {
    sum += temp;
  }
  float mean = sum / temperatures.length;

  OscMessage meanTempMsg = new OscMessage("/temperatureMean");
  meanTempMsg.add(mean);
  oscP5.send(meanTempMsg, pureDataAddress);
}

// Función para enviar los valores puros de emisiones de CO₂ en forma de onda
void sendCO2Wave(float[] data) {
  for (int i = 0; i < data.length; i++) {
    if (i == currentDataIndex % data.length) {
      OscMessage msg = new OscMessage("/co2Wave");
      msg.add(data[i]);  // Enviar el valor puro de emisiones de CO₂
      oscP5.send(msg, pureDataAddress);
    }
  }
}

// Función para enviar la media de emisiones de CO₂
void sendCO2Mean(float[] co2Emissions) {
  float sum = 0;
  for (float co2 : co2Emissions) {
    sum += co2;
  }
  float mean = sum / co2Emissions.length;

  OscMessage meanCO2Msg = new OscMessage("/co2Mean");
  meanCO2Msg.add(mean);
  oscP5.send(meanCO2Msg, pureDataAddress);
}

// Función para enviar los valores puros de nivel del mar en forma de onda
void sendSeaLevelWave(float[] data) {
  for (int i = 0; i < data.length; i++) {
    if (i == currentDataIndex % data.length) {
      OscMessage msg = new OscMessage("/seaLevelWave");
      msg.add(data[i]);  // Enviar el valor puro de nivel del mar
      oscP5.send(msg, pureDataAddress);
    }
  }
}

// Función para enviar la media del nivel del mar
void sendSeaLevelMean(float[] seaLevelRise) {
  float sum = 0;
  for (float level : seaLevelRise) {
    sum += level;
  }
  float mean = sum / seaLevelRise.length;

  OscMessage meanSeaLevelMsg = new OscMessage("/seaLevelMean");
  meanSeaLevelMsg.add(mean);
  oscP5.send(meanSeaLevelMsg, pureDataAddress);
}

// Función para enviar los valores puros de precipitación en forma de onda
void sendPrecipitationWave(float[] data) {
  for (int i = 0; i < data.length; i++) {
    if (i == currentDataIndex % data.length) {
      OscMessage msg = new OscMessage("/precipitationWave");
      msg.add(data[i]);  // Enviar el valor puro de precipitación
      oscP5.send(msg, pureDataAddress);
    }
  }
}

// Función para enviar la media de precipitación
void sendPrecipitationMean(float[] precipitation) {
  float sum = 0;
  for (float precip : precipitation) {
    sum += precip;
  }
  float mean = sum / precipitation.length;

  OscMessage meanPrecipMsg = new OscMessage("/precipitationMean");
  meanPrecipMsg.add(mean);
  oscP5.send(meanPrecipMsg, pureDataAddress);
}

// Función para enviar los valores puros de humedad en forma de onda
void sendHumidityWave(float[] data) {
  for (int i = 0; i < data.length; i++) {
    if (i == currentDataIndex % data.length) {
      OscMessage msg = new OscMessage("/humidityWave");
      msg.add(data[i]);  // Enviar el valor puro de humedad
      oscP5.send(msg, pureDataAddress);
    }
  }
}

// Función para enviar la media de la humedad
void sendHumidityMean(float[] humidity) {
  float sum = 0;
  for (float hum : humidity) {
    sum += hum;
  }
  float mean = sum / humidity.length;

  OscMessage meanHumidityMsg = new OscMessage("/humidityMean");
  meanHumidityMsg.add(mean);
  oscP5.send(meanHumidityMsg, pureDataAddress);
}

// Función para enviar los valores puros de velocidad del viento en forma de onda
void sendWindSpeedWave(float[] data) {
  for (int i = 0; i < data.length; i++) {
    if (i == currentDataIndex % data.length) {
      OscMessage msg = new OscMessage("/windSpeedWave");
      msg.add(data[i]);  // Enviar el valor puro de velocidad del viento
      oscP5.send(msg, pureDataAddress);
    }
  }
}

// Función para enviar la media de la velocidad del viento
void sendWindSpeedMean(float[] windSpeed) {
  float sum = 0;
  for (float speed : windSpeed) {
    sum += speed;
  }
  float mean = sum / windSpeed.length;

  OscMessage meanWindSpeedMsg = new OscMessage("/windSpeedMean");
  meanWindSpeedMsg.add(mean);
  oscP5.send(meanWindSpeedMsg, pureDataAddress);
}
