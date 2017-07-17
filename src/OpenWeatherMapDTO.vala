
namespace Weather {

public class OpenWeatherMapDTO {

    public class Coord : Object {
		public float lon {get;set;}
		public float lat {get;set;}
	}

	public class Weather : Object {
		public int id {get;set;}
		public string main {get;set;}
		public string description {get;set;}
		public string icon {get;set;}
	}

	public class Main : Object {
		public float temp {get;set;}
        public float pressure {get;set;}
		public int humidity {get;set;}
		public float temp_min {get;set;}
		public float temp_max {get;set;}
		public float sea_level {get;set;}
		public float grnd_level {get;set;}
	}

	public class Wind : Object {
		public float speed {get;set;}
		public float deg {get;set;}
	}

	public class Clouds : Object {
		public int all {get;set;}
	}

	public class Rain : Object {
		public int 3h {get;set;}
	}

	public class Snow : Object {
		public int 3h {get;set;}
	}

	public class Sys : Object {
		public string country {get;set;}
		public DateTime sunrise {get;set;}
		public DateTime sunset {get;set;}
	}

	public Coord coord {get;set;}
	public Weather weather {get;set;}
	public Main main {get;set;}
	public Wind wind {get;set;}
	public Clouds clouds {get;set;}
	public Rain rain {get;set;}
	public Snow snow {get;set;}
	public DateTime dt {get;set;}
	public Sys sys {get;set;}
	public int64 id {get;set;}
	public string name {get;set;}
	public string cod {get;set;}
	public string message {get;set;}

    public OpenWeatherMapDTO.from_json_string (string json_string) {
		Json.Parser parser = new Json.Parser ();
		try {
			parser.load_from_data (json_string);
			parse_json(parser);
		} catch (Error e) {
			print ("Unable to parse the string: %s".printf(e.message));
		}
    }

    public OpenWeatherMapDTO.from_json_stream (InputStream json_stream) {
		Json.Parser parser = new Json.Parser ();
		try {
			parser.load_from_stream (json_stream);
			parse_json(parser);
		} catch (Error e) {
			print ("Unable to parse the string: %s".printf(e.message));
		}
    }

	void parse_json(Json.Parser parser){
		Json.Node node = parser.get_root ();
		Json.Object root_obj = node.get_object();

		if(root_obj.has_member("coord")){
			this.coord = Json.gobject_deserialize (typeof (Coord), root_obj.get_member("coord")) as Coord;
		}
		if(root_obj.has_member("weather")){
			Json.Array weather_array = root_obj.get_member("weather").get_array();
			if(weather_array.get_length() > 0)
			this.weather = Json.gobject_deserialize (typeof (Weather), weather_array.get_element(0)) as Weather;
		}
		if(root_obj.has_member("main")){
			this.main = Json.gobject_deserialize (typeof (Main), root_obj.get_member("main")) as Main;
		}
		if(root_obj.has_member("wind")){
			this.wind = Json.gobject_deserialize (typeof (Wind), root_obj.get_member("wind")) as Wind;
		}
		if(root_obj.has_member("clouds")){
			this.clouds = Json.gobject_deserialize (typeof (Clouds), root_obj.get_member("clouds")) as Clouds;
		}
		if(root_obj.has_member("rain")){
			this.rain = Json.gobject_deserialize (typeof (Rain), root_obj.get_member("rain")) as Rain;
		}
		if(root_obj.has_member("snow")){
			this.snow = Json.gobject_deserialize (typeof (Snow), root_obj.get_member("snow")) as Snow;
		}
		if(root_obj.has_member("dt")){
			this.dt = new DateTime.from_unix_utc(root_obj.get_int_member("dt"));
		}
		if(root_obj.has_member("sys")){
			Json.Object sys_object = root_obj.get_object_member("sys");
			this.sys = new Sys();
			if(sys_object.has_member("sunrise"))
			this.sys.sunrise = new DateTime.from_unix_utc(sys_object.get_int_member("sunrise"));
			if(sys_object.has_member("sunset"))
			this.sys.sunset = new DateTime.from_unix_utc(sys_object.get_int_member("sunset"));

		}
		if(root_obj.has_member("id")){
			this.id = root_obj.get_int_member("id");
		}
		if(root_obj.has_member("name")){
			this.name = root_obj.get_string_member("name");
		}
		if(root_obj.has_member("cod")){
			this.cod = root_obj.get_string_member("cod");
		}
		if(root_obj.has_member("message")){
			this.message = root_obj.get_string_member("message");
		}

		//todo make some debug flags and surrond this...
		Json.Generator generator = new Json.Generator ();
		generator.set_root (node);

		string str = generator.to_data (null);
		print(str);

	}

	public string linuxIcon(){
		return openweatermapIconToLinuxIcon(this.weather.icon);
	}

	string openweatermapIconToLinuxIcon(string openweatermapIcon){
		switch (openweatermapIcon) {
			case "01d":
				return "weather-clear-symbolic";
			case "01n":
				return "weather-clear-night-symbolic";
			case "02d":
				return "weather-few-clouds-symbolic";
			case "02n":
				return "weather-few-clouds-night-symbolic";
			case "03n":
			case "03d":
				return "weather-overcast-symbolic";
			case "04d":
			case "04n":
				return "weather-overcast-symbolic";
			case "09d":
			case "09n":
				return "weather-showers-symbolic";
			case "10d":
			case "10n":
				return "weather-showers-scattered-symbolic";
			case "11d":
			case "11n":
				return "weather-storm-symbolic";
			case "13d":
			case "13n":
				return "weather-snow-symbolic";
			case "50d":
			case "50n":
				return "weather-fog-symbolic";
		}
		return "weather-overcast-symbolic";
	}
}

void print(string message){
	stdout.printf ("Budgie-Weather: %s\n", message);
}

}
