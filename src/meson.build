
custom_target('plugin-file-workspaces',
    input : 'BudgieWeatherApplet.plugin.in',
    output : 'BudgieWeatherApplet.plugin',
    command : ['cp', '@INPUT@', '@OUTPUT@'],
    install : true,
    install_dir: LIB_INSTALL_DIR,
)

gresource = join_paths(meson.current_source_dir(), 'plugin.gresource.xml')

# Compile the assets into the binary
applet_budgie_weather_resources = gnome.compile_resources(
    'budgie-weather-applet-resources',
    gresource,
    source_dir: meson.current_source_dir(),
    c_name: 'budgie_weather',
)


applet_budgie_weather_sources = [
    'BudgieWeatherApplet.vala',
    'Providers/OpenWeatherMap.vala',
    'Providers/Common.vala',
    'WeatherInfo.vala',
    applet_budgie_weather_resources,
]

applet_budgie_weather_deps = [
    dep_gtk3,
    dep_glib,
    dep_peas,
    dep_budgie,
    dep_json_glib,
    dep_libsoup,
    dep_gweather,
]

shared_library(
    'budgieweatherapplet',
    applet_budgie_weather_sources,
    dependencies: applet_budgie_weather_deps,
    c_args: [
        '-DGWEATHER_I_KNOW_THIS_IS_UNSTABLE',
    ],
    install: true,
    install_dir: LIB_INSTALL_DIR,
)

install_data('net.milgar.budgie-weather.gschema.xml',
    install_dir: '/usr/share/glib-2.0/schemas'
)
