
namespace WeatherApplet.Providers {

public delegate void WeatherUpdated(WeatherInfo? info);

public enum ProvidersEnum {
    GWEATHER = 0,
    OPEN_WEATHER_MAP = 1,
}

}
