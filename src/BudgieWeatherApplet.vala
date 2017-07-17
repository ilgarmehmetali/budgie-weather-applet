
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

    string openweaethermap_test_data = """
        {"coord": {"lon":145.77,"lat":-16.92},
        "weather":[{"id":803,"main":"Clouds","description":"broken clouds","icon":"04n"}],
        "base":"cmc stations",
        "main":{"temp":293.25,"pressure":1019,"humidity":83,"temp_min":289.82,"temp_max":295.37},
        "wind":{"speed":5.1,"deg":150},
        "clouds":{"all":75},
        "rain":{"3h":3},
        "dt":1435658272,
        "sys":{"type":1,"id":8166,"message":0.0166,"country":"AU","sunrise":1435610796,"sunset":1435650870},
        "id":2172797,
        "name":"Cairns",
        "cod":200}
    """;

    public string uuid { public set; public get; }

    private uint source_id;

    private Settings? settings;

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

        this.reset_update_timer(true);

        this.on_settings_change("show-icon");
        this.on_settings_change("show-city-name");
        this.on_settings_change("show-temp");

        show_all();
    }

    bool update(){
        DateTime last_update = new DateTime.from_unix_utc(this.settings.get_int64("last-update"));
        DateTime now = new DateTime.now_utc();
        last_update = last_update.add_minutes(this.settings.get_int("update-interval"));

        if(last_update.compare(now) <= 0) {
            this.settings.set_int64("last-update", now.to_unix());
            GLib.InputStream input_stream = new GLib.MemoryInputStream.from_data (openweaethermap_test_data.data, GLib.g_free);
            //OpenWeatherMapDTO obj = new OpenWeatherMapDTO.from_json_string(openweaethermap_test_data);
            OpenWeatherMapDTO obj = new OpenWeatherMapDTO.from_json_stream(input_stream);

            this.city_name.label = obj.name;

            string symbol = "";
            string unit = this.settings.get_string("units-format");
            if (unit == "metric") symbol = "C";
            else if (unit == "imperial") symbol = "F";
            else if (unit == "standard") symbol = "K";
            this.temp.label = "%s°%s".printf(obj.main.temp.to_string(), symbol);

            this.weather_icon.set_from_icon_name(obj.linuxIcon(), Gtk.IconSize.LARGE_TOOLBAR);
        }
        return true;
    }

    void on_settings_change(string key) {
        if (key == "update-interval") {
            this.reset_update_timer(false);
        } else if (key == "show-icon") {
            if(this.settings.get_boolean("show-icon")) {
                this.weather_icon.show();
            } else {
                this.weather_icon.hide();
            }
        } else if (key == "show-city-name") {
            if(this.settings.get_boolean("show-city-name")) {
                this.city_name.show();
            } else {
                this.city_name.hide();
            }
        } else if (key == "show-temp") {
            if(this.settings.get_boolean("show-temp")) {
                this.temp.show();
            } else {
                this.temp.hide();
            }
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
    private Gtk.Entry? textentry_openweathermap_api_key;

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

        this.button_update_now.clicked.connect (() => {
            this.settings.set_boolean("update-now", true);
            this.settings.set_boolean("update-now", false);
        });

    }
}

}

[ModuleInit]
public void peas_register_types(TypeModule module)
{
    // boilerplate - all modules need this
    var objmodule = module as Peas.ObjectModule;
    objmodule.register_extension_type(typeof(Budgie.Plugin), typeof(Weather.Plugin));
}
