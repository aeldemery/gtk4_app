project ('github.aeldemery.gtk4_app', 'vala', 'c')

sources = []

resources = import('gnome').compile_resources(
    'gtk4_app-resources',
    'data/resources/github.aeldemery.gtk4_app.gresource.xml',
    source_dir: 'data/resources',
    c_name: 'appres',
)

schemas = import('gnome').compile_schemas(
    depend_files: 'data/' + meson.project_name() + '.gschema.xml',
)

sources += files(
    'src/Application.vala',
    'src/MainWindow.vala',
    'src/PreferencesDialog.vala',
)

dependencies = [
    dependency ('gobject-2.0'),
    dependency ('glib-2.0'),
    dependency ('gtk4'),
]

executable (
    meson.project_name(),
    resources,
    schemas,
    sources: sources,
    dependencies: dependencies,
    install: true,
)

subdir ('data')

meson.add_install_script('meson/post_install.py')