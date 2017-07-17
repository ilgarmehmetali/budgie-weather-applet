
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
		public int deg {get;set;}
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

    public OpenWeatherMapDTO.from_json_string (string json_string) {


		Json.Parser parser = new Json.Parser ();
		try {
			parser.load_from_data (json_string);
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
		} catch (Error e) {
			print ("Unable to parse the string: %s".printf(e.message));
		}
    }
}

void print(string message){
	stdout.printf ("Budgie-Weather: %s\n", message);
}

}
