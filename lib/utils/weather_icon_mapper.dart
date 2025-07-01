import 'package:flutter_weather_bg_null_safety/utils/weather_type.dart';

final Map<String, String> weatherCodeToLottie = {
  /*
    Remember that all condition.text taken from json are lowercased
  */
  // Miscellaneous
  "umbrella": "assets/animations/weather-icons/lottie/umbrella.json",

  // 🌤️ Clouds / Fog / Haze
  "overcast": "assets/animations/weather-icons/lottie/overcast-haze.json",

  "freezing fog":
      "assets/animations/weather-icons/lottie/overcast-day-smoke.json",

  // 🌧️ Rain
  "patchy light rain":
      "assets/animations/weather-icons/lottie/overcast-drizzle.json",

  "torrential rain shower":
      "assets/animations/weather-icons/lottie/thunderstorms-day-overcast-rain.json",

  // ❄️ Snow
  "patchy light snow":
      "assets/animations/weather-icons/lottie/overcast-day-snow.json",
  "light snow": "assets/animations/weather-icons/lottie/overcast-day-snow.json",
  "moderate snow":
      "assets/animations/weather-icons/lottie/overcast-night-snow.json",
  "heavy snow":
      "assets/animations/weather-icons/lottie/overcast-night-overcast-snow.json",
  "blowing snow":
      "assets/animations/weather-icons/lottie/thunderstorms-night-overcast-snow.json",

  // 🌨️ Sleet
  "patchy sleet possible":
      "assets/animations/weather-icons/lottie/overcast-sleet.json",
  "light sleet":
      "assets/animations/weather-icons/lottie/overcast-day-sleet.json",
  "moderate or heavy sleet":
      "assets/animations/weather-icons/lottie/overcast-night-sleet.json",

  // 🌩️ Thunderstorms
  "moderate or heavy rain with thunder":
      "assets/animations/weather-icons/lottie/thunderstorms-overcast-rain.json",
  "patchy light rain with thunder":
      "assets/animations/weather-icons/lottie/thunderstorms-day-overcast-rain.json",
  "patchy light snow with thunder":
      "assets/animations/weather-icons/lottie/thunderstorms-day-overcast-snow.json",
  "moderate or heavy snow with thunder":
      "assets/animations/weather-icons/lottie/thunderstorms-night-overcast-snow.json",

  // 🧊 Hail / Ice
  "ice pellets":
      "assets/animations/weather-icons/lottie/overcast-day-hail.json",
  "light showers of ice pellets":
      "assets/animations/weather-icons/lottie/overcast-night-hail.json",
  "moderate or heavy showers of ice pellets":
      "assets/animations/weather-icons/lottie/overcast-hail.json",

  // 🌫️ Smoke / Dust
  "sandstorm":
      "assets/animations/weather-icons/lottie/overcast-night-smoke.json",

  // 🌈 Special
  "rainbow": "assets/animations/weather-icons/lottie/rainbow.json",
  "rainbow with sun":
      "assets/animations/weather-icons/lottie/rainbow-clear.json",

  "sunny": "assets/animations/weather-icons/lottie/clear-day.json",
  "clear": "assets/animations/weather-icons/lottie/clear-night.json",
  "cloudy": "assets/animations/weather-icons/lottie/cloudy.json",

  "partly cloudy":
      "assets/animations/weather-icons/lottie/partly-cloudy-day.json",
  "partly cloudy night":
      "assets/animations/weather-icons/lottie/partly-cloudy-night.json",
  "partly cloudy day":
      "assets/animations/weather-icons/lottie/partly-cloudy-day.json",
  "light rain": "assets/animations/weather-icons/lottie/rain.json",
  "moderate rain": "assets/animations/weather-icons/lottie/rain.json",
  "heavy rain": "assets/animations/weather-icons/lottie/rain.json",
  "patchy rain possible":
      "assets/animations/weather-icons/lottie/partly-cloudy-day-rain.json",
  "patchy rain nearby":
      "assets/animations/weather-icons/lottie/partly-cloudy-day-rain.json",
  "light drizzle": "assets/animations/weather-icons/lottie/drizzle.json",
  "patchy drizzle possible":
      "assets/animations/weather-icons/lottie/partly-cloudy-day-drizzle.json",
  "hail": "assets/animations/weather-icons/lottie/hail.json",
  "sleet":
      "assets/animations/weather-icons/lottie/partly-cloudy-day-sleet.json",
  "snow": "assets/animations/weather-icons/lottie/snow.json",
  "patchy snow possible":
      "assets/animations/weather-icons/lottie/partly-cloudy-day-snow.json",
  "smoke": "assets/animations/weather-icons/lottie/smoke.json",
  "mist": "assets/animations/weather-icons/lottie/mist.json",
  "fog": "assets/animations/weather-icons/lottie/mist.json",
  "dust": "assets/animations/weather-icons/lottie/dust.json",
  "dusty": "assets/animations/weather-icons/lottie/dust.json",
  "dust day": "assets/animations/weather-icons/lottie/dust-day.json",
  "dust night": "assets/animations/weather-icons/lottie/dust-night.json",
  "dust wind": "assets/animations/weather-icons/lottie/dust-wind.json",
  "windy": "assets/animations/weather-icons/lottie/wind.json",
  "tornado": "assets/animations/weather-icons/lottie/tornado.json",
  "hurricane": "assets/animations/weather-icons/lottie/hurricane.json",
  "thundery outbreaks possible":
      "assets/animations/weather-icons/lottie/thunderstorms-overcast.json",
  "thunderstorms":
      "assets/animations/weather-icons/lottie/thunderstorms-overcast.json",
  "patchy light rain in area with thunder":
      "assets/animations/weather-icons/lottie/thunderstorms-day-overcast-rain.json",
};

WeatherType getWeatherBgType(String conditionText) {
  final text = conditionText.toLowerCase();

  if (text.contains("clear") || text == "sunny") {
    return WeatherType.sunny;
  } else if (text == "patchy light rain in area with thunder") {
    return WeatherType.thunder;
  } else if (text.contains("partly cloudy") || text.contains("cloudy")) {
    return WeatherType.cloudy;
  } else if (text.contains("overcast") ||
      text.contains("fog") ||
      text.contains("mist") ||
      text.contains("haze")) {
    return WeatherType.foggy;
  } else if (text.contains("patchy light rain") ||
      text.contains("light drizzle")) {
    return WeatherType.lightRainy;
  } else if (text.contains("light rain") || text.contains("patchy rain")) {
    return WeatherType.middleRainy;
  } else if (text.contains("moderate rain") ||
      text.contains("heavy rain") ||
      text.contains("torrential rain")) {
    return WeatherType.heavyRainy;
  } else if (text.contains("light snow") || text.contains("patchy snow")) {
    return WeatherType.lightSnow;
  } else if (text.contains("moderate snow")) {
    return WeatherType.middleSnow;
  } else if (text.contains("heavy snow") || text.contains("blowing snow")) {
    return WeatherType.heavySnow;
  } else if (text.contains("sleet") || text.contains("ice pellets")) {
    return WeatherType.middleSnow;
  } else if (text.contains("thunder") ||
      text.contains("thunderstorms") ||
      text.contains("thundery")) {
    return WeatherType.thunder;
  } else if (text.contains("dust") || text.contains("sand")) {
    return WeatherType.dusty;
  } else {
    // Fallback if no known type matches
    return WeatherType.sunny;
  }
}

String getWeatherIconForCode(String condition) {
  return weatherCodeToLottie[condition] ??
      "assets/animations/weather-icons/lottie/not-available.json"; // fallback icon
}
