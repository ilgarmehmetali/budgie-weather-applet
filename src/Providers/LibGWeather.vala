
namespace WeatherApplet.Providers {

public class LibGWeather {

    public static void get_current_weather_info (float latitude, float longitute, string city_name, WeatherUpdated callback) {
        GWeather.Location loc = new GWeather.Location.detached(city_name, null, latitude, longitute);
        GWeather.Info gweather_info = new GWeather.Info(loc, GWeather.ForecastType.STATE);
        gweather_info.update();
        gweather_info.updated.connect(()=>{
            WeatherInfo info = new WeatherInfo();
            info.city_name = gweather_info.get_location_name();
            info.symbolic_icon_name = gweather_info.get_symbolic_icon_name();
            info.temp = (float)double.parse(gweather_info.get_temp());
            info.temp_min = (float)double.parse(gweather_info.get_temp_min());
            info.temp_max = (float)double.parse(gweather_info.get_temp_max());
            info.symbol = "";
            callback(info);
        });
    }
}

}
