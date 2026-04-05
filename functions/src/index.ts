import {onSchedule} from "firebase-functions/v2/scheduler";
import {logger} from "firebase-functions/v2";
import * as admin from "firebase-admin";
import axios from "axios";

const apiKey = process.env.WEATHER_API_KEY ?? "";
admin.initializeApp();

/**
 * Fetches current weather data for a given city from WeatherAPI.
 *
 * @param {string}city - The city name to fetch weather for (e.g. "Venice, IT")
 * @return {Promise<any>} The full weather response object from WeatherAPI
 * @throws Will throw an error if the API call fails or city is not found
 *
 * @example
 * const weather = await fetchWeather("Venice, IT");
 * console.log(weather.current.condition.text); // "Partly cloudy"
 */
async function fetchWeather(city: string) {
  const response = await axios.get(
    `https://api.weatherapi.com/v1/current.json?key=${apiKey}&q=${city}`,
  );
  return response.data;
}

/**
 * Checks if the current weather condition matches the alert condition.
 *
 * @param {any} weather - The weather response object from WeatherAPI
 * @param {string} condition - The condition to check against (e.g. "Rain")
 * @return {boolean} True if the weather condition matches the alert condition
 *
 * @example
 * const matches = conditionMatches(weather, "Rain");
 * console.log(matches); // true
 */
function conditionMatches(weather: any, condition: string): boolean {
  const current = weather.current.condition.text.toLowerCase();
  return current.includes(condition.toLowerCase());
}

export const checkWeatherAlerts = onSchedule("every 1 hours", async (event) => {
  const alerts = await admin
    .firestore()
    .collection("alerts")
    .where("isActive", "==", true)
    .get();

  for (const doc of alerts.docs) {
    const alert = doc.data();
    try {
      const weather = await fetchWeather(alert.city);

      if (conditionMatches(weather, alert.condition)) {
        await admin
          .firestore()
          .collection("mail")
          .add({
            to: alert.email,
            message: {
              subject: `Weather alert for ${alert.city}`,
              text: `${alert.condition} detected in ${alert.city}! Stay safe.`,
            },
          });
        logger.info(`Alert sent for ${alert.city}`);
      }
    } catch (error) {
      logger.error(`Error for ${alert.city}`, error);
    }
  }
});
