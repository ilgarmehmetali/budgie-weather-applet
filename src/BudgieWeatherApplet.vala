
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

    private Settings? settings;

    public Applet(string uuid)
    {
        Object(uuid: uuid);

        this.weather_icon = new Gtk.Image.from_icon_name ("weather-overcast", Gtk.IconSize.MENU);

        this.city_name = new Gtk.Label ("-");
        this.city_name.set_ellipsize (Pango.EllipsizeMode.END);
        this.city_name.set_alignment(0, 0.5f);
        this.temp = new Gtk.Label ("-");
        this.temp.set_ellipsize (Pango.EllipsizeMode.END);
        this.temp.set_alignment(0, 0.5f);

        Gtk.Box box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        box.pack_start (this.weather_icon, false, false, 0);
        box.pack_start (this.temp, false, false, 0);
        box.pack_start (this.city_name, false, false, 0);
        this.add (box);

        settings_schema = "net.milgar.budgie-weather";
        settings_prefix = "/net/milgar/budgie-weather";

        this.settings = this.get_applet_settings(uuid);
        this.settings.changed.connect(on_settings_change);
        this.on_settings_change("longitude");
        this.on_settings_change("latitude");
        this.on_settings_change("show-icon");
        this.on_settings_change("show-city-name");
        this.on_settings_change("show-temp");
        show_all();
    }

    void on_settings_change(string key) {
        if (key == "longitude") {
            // update weather data
        } else if (key == "latitude") {
            // update weather data
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
                this.city_name.label += "-";
            }
        }
        queue_resize();
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
    private Gtk.Switch? switch_icon;

    [GtkChild]
    private Gtk.Switch? switch_city_name;

    [GtkChild]
    private Gtk.Switch? switch_temp;

    [GtkChild]
    private Gtk.Button? button_update_now;

    [GtkChild]
    private Gtk.Entry? textentry_openweathermap_api_key;

    public AppletSettings(Settings? settings)
    {
        this.settings = settings;

        this.settings.bind("longitude", spinbutton_longitude, "value", SettingsBindFlags.DEFAULT);
        this.settings.bind("latitude", spinbutton_latitude, "value", SettingsBindFlags.DEFAULT);
        this.settings.bind("openweathermap-api-key", textentry_openweathermap_api_key, "text", SettingsBindFlags.DEFAULT);
        this.settings.bind("show-icon", switch_icon, "active", SettingsBindFlags.DEFAULT);
        this.settings.bind("show-city-name", switch_city_name, "active", SettingsBindFlags.DEFAULT);
        this.settings.bind("show-temp", switch_temp, "active", SettingsBindFlags.DEFAULT);

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
