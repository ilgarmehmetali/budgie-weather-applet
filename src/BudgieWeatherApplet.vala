
namespace Weather {

public class Plugin : Budgie.Plugin, Peas.ExtensionBase
{
    public Budgie.Applet get_panel_widget(string uuid)
    {
        return new Applet(uuid);
    }
}

public class Applet : Budgie.Applet
{
    Gtk.Label city_name;
    Gtk.Label temp;
    Gtk.Image weather_icon;

    public string uuid { public set; public get; }

    private uint source_id;

    private static string OPEN_WEATHER_MAP_URL = "http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&apikey=%s&units=%s";

    private Settings? settings;

    private Soup.Session session;

    public Applet(string uuid)
    {
        Object(uuid: uuid);

        settings_schema = "net.milgar.budgie-weather";
        settings_prefix = "/net/milgar/budgie-weather";

        this.settings = this.get_applet_settings(uuid);
        this.settings.changed.connect(on_settings_change);

        this.weather_icon = new Gtk.Image ();

        this.city_name = new Gtk.Label ("-");
        this.city_name.set_ellipsize (Pango.EllipsizeMode.END);
        this.city_name.set_alignment(0, 0.5f);
        this.city_name.margin_left = this.city_name.margin_right = 6;
        this.temp = new Gtk.Label ("-");
        this.temp.set_ellipsize (Pango.EllipsizeMode.END);
        this.temp.set_alignment(0, 0.5f);
        this.temp.margin_left = this.city_name.margin_right = 3;

        Gtk.Box box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        box.pack_start (this.weather_icon, false, false, 0);
        box.pack_start (this.temp, false, false, 0);
        box.pack_start (this.city_name, false, false, 0);
        this.add (box);

    	// Create a session:
    	session = new Soup.Session ();
    	session.use_thread_context = true;

        this.reset_update_timer(true);

        this.on_settings_change("show-icon");
        this.on_settings_change("show-city-name");
        this.on_settings_change("show-temp");

        show_all();

        // to solve template giving "Invalid object type 'GWeatherLocationEntry'" error"
        new GWeather.LocationEntry(null);
    }

    bool update(){
        DateTime last_update = new DateTime.from_unix_utc(this.settings.get_int64("last-update"));
        DateTime now = new DateTime.now_utc();
        last_update = last_update.add_minutes(this.settings.get_int("update-interval"));

        if(last_update.compare(now) <= 0) {
            this.settings.set_int64("last-update", now.to_unix());

            double latitude = this.settings.get_double("latitude");
            double longitude = this.settings.get_double("longitude");
            string apikey = this.settings.get_string("openweathermap-api-key");
            string unit = this.settings.get_string("units-format");

            try {
                string request_url = OPEN_WEATHER_MAP_URL.printf(latitude, longitude, apikey, unit);
                Soup.Request request = session.request (request_url);
                request.send_async.begin (null, (obj, res) => {
                    try {
                        InputStream stream = request.send_async.end (res);
                        Providers.OpenWeatherMap openWeatherMap = new Providers.OpenWeatherMap.from_json_stream(stream);
                        WeatherInfo info = openWeatherMap.get_weather_info();

                        if(openWeatherMap.cod == "200") {
                            this.city_name.label = info.city_name;

                            string symbol = "";
                            if (unit == "metric") symbol = "C";
                            else if (unit == "imperial") symbol = "F";
                            else if (unit == "standard") symbol = "K";
                            this.temp.label = "%s°%s".printf(info.temp.to_string(), symbol);

                            this.weather_icon.set_from_icon_name(info.symbolic_icon_name, Gtk.IconSize.LARGE_TOOLBAR);
                        } else {
                            openWeatherMap.printJson();
                        }
                    } catch (Error e) {
                        print ("Error at update func: %s".printf(e.message));
                    }
                });
            } catch (Error e) {
                print ("Error at update func: %s".printf(e.message));
            }
        }
        return true;
    }

    void on_settings_change(string key) {
        if (key == "update-interval") {
            this.reset_update_timer(false);
        } else if (key == "show-icon") {
            this.weather_icon.set_visible(this.settings.get_boolean("show-icon"));
        } else if (key == "show-city-name") {
            this.city_name.set_visible(this.settings.get_boolean("show-city-name"));
        } else if (key == "show-temp") {
            this.temp.set_visible(this.settings.get_boolean("show-temp"));
        } else if (key == "update-now") {
            if(this.settings.get_boolean("update-now")) {
                this.reset_update_timer(true);
            }
        }
        queue_resize();
    }

    void reset_update_timer(bool force_update){
        if(force_update){
            this.settings.set_int64("last-update", 0);
        }
        if (this.source_id > 0) {
            Source.remove(this.source_id);
        }
        uint interval = this.settings.get_int("update-interval");
        if(interval > 0){
            this.source_id = GLib.Timeout.add_full(GLib.Priority.DEFAULT, interval, update);
        }
    }

    public override bool supports_settings() {
        return true;
    }

    public override Gtk.Widget? get_settings_ui()
    {
        return new AppletSettings(this.get_applet_settings(uuid));
    }
}

[GtkTemplate (ui = "/net/milgar/budgie-weather/settings.ui")]
public class AppletSettings : Gtk.Grid
{
    Settings? settings = null;

    [GtkChild]
    private Gtk.SpinButton? spinbutton_longitude;

    [GtkChild]
    private Gtk.SpinButton? spinbutton_latitude;

    [GtkChild]
    private Gtk.SpinButton? spinbutton_update_interval;

    [GtkChild]
    private Gtk.Switch? switch_icon;

    [GtkChild]
    private Gtk.Switch? switch_city_name;

    [GtkChild]
    private Gtk.Switch? switch_temp;

    [GtkChild]
    private Gtk.Button? button_update_now;

    [GtkChild]
    private Gtk.ComboBox? combobox_units_format;

    [GtkChild]
    private Gtk.ComboBox? combobox_provider;

    [GtkChild]
    private Gtk.Notebook? notebook_providers;

    [GtkChild]
    private Gtk.Entry? textentry_openweathermap_api_key;

    [GtkChild]
    private GWeather.LocationEntry? gweather_location_entry;

    public AppletSettings(Settings? settings)
    {
        this.settings = settings;

        this.settings.bind("longitude", spinbutton_longitude, "value", SettingsBindFlags.DEFAULT);
        this.settings.bind("latitude", spinbutton_latitude, "value", SettingsBindFlags.DEFAULT);
        this.settings.bind("update-interval", spinbutton_update_interval, "value", SettingsBindFlags.DEFAULT);
        this.settings.bind("openweathermap-api-key", textentry_openweathermap_api_key, "text", SettingsBindFlags.DEFAULT);
        this.settings.bind("show-icon", switch_icon, "active", SettingsBindFlags.DEFAULT);
        this.settings.bind("show-city-name", switch_city_name, "active", SettingsBindFlags.DEFAULT);
        this.settings.bind("show-temp", switch_temp, "active", SettingsBindFlags.DEFAULT);
        this.settings.bind("units-format", combobox_units_format, "active_id", SettingsBindFlags.DEFAULT);
        this.settings.bind("provider-id", combobox_provider, "active", SettingsBindFlags.DEFAULT);

        this.button_update_now.clicked.connect (() => {
            this.settings.set_boolean("update-now", true);
            this.settings.set_boolean("update-now", false);
        });

        this.combobox_provider.changed.connect (() => {
            resize_notebook_providers();
        });
        this.hide_all_notebook_providers_pages();
        this.resize_notebook_providers();
    }

    void resize_notebook_providers(){
        hide_all_notebook_providers_pages();
        this.notebook_providers.set_current_page(this.combobox_provider.active);
        this.notebook_providers.get_nth_page(this.combobox_provider.active).show();
    }

    void hide_all_notebook_providers_pages(){
        for (int page_id = 0; page_id < this.notebook_providers.get_n_pages(); page_id++) {
            this.notebook_providers.get_nth_page(page_id).hide();
        }
    }

void print(string? message){
	if (message == null) message = "";
	stdout.printf ("Budgie-Weather: %s\n", message);
}

}

[ModuleInit]
public void peas_register_types(TypeModule module)
{
    // boilerplate - all modules need this
    var objmodule = module as Peas.ObjectModule;
    objmodule.register_extension_type(typeof(Budgie.Plugin), typeof(Weather.Plugin));
}
