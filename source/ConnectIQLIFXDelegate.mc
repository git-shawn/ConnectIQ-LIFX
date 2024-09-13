import Toybox.Lang;
import Toybox.Graphics;
using Toybox.Communications;
using Toybox.WatchUi;
using Toybox.System;


class ConnectIQLIFXDelegate extends WatchUi.BehaviorDelegate {
    // Base delegate, doesn't do much as the main menu is called once it's ready to be loaded
    var notify;
    // Set up the callback to the view
    function initialize() {
        WatchUi.BehaviorDelegate.initialize();
    }

    // Handle back button press to exit safely
    function onBack() {
        System.println("ConnectIQLIFXDelegate: back pressed");
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }
}

class LifxMainInputDelegate extends WatchUi.Menu2InputDelegate {
    // Handles the main menu selection
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onBack() {
        System.print("Exit app");
        System.exit();
    }

    function onSelect(item) {
        // Builds the sub menus for each option
        System.println(item.getId());
        var id = item.getId() as String;

        if (id.equals("toggle_all_lights")) {
            var loading_view = new SendingSignalView(true);
            var loading_delegate = new ConnectIQLIFXDelegate();
            WatchUi.switchToView(loading_view, loading_delegate, WatchUi.SLIDE_LEFT);
            $.LIFX_API_OBJ.applying_selection = true;
            WatchUi.requestUpdate();
            $.LIFX_API_OBJ.toggle_power("all");

        } else if (id.equals("apply_scene")) {
            var num_scenes = $.LIFX_API_OBJ.scenes.size();
            System.println("Number of scenes to display: "+ num_scenes);

            if (num_scenes == 0) {
                WatchUi.switchToView(new LifxNoScenesView(), new ConnectIQLIFXDelegate(), WatchUi.SLIDE_LEFT);
            } else {
                var menu = new WatchUi.Menu2({:title=>"Select Scene"});
                if (menu has :setTheme) {
                    menu.setTheme(WatchUi.MENU_THEME_PURPLE);
                }
                var delegate;
                for( var i = 0; i < num_scenes; i++ ) {
                    menu.addItem(
                        new MenuItem(
                            $.LIFX_API_OBJ.scenes[i]["name"],
                            null,
                            $.LIFX_API_OBJ.scenes[i]["scene_num"],
                            {}
                        )
                    );
                }

                delegate = new LifxSceneInputDelegate();
                WatchUi.pushView(menu, delegate, WatchUi.SLIDE_LEFT);
            }
        } else if (id.equals("toggle_light")) {
            var num_lights = $.LIFX_API_OBJ.lights.size();
            System.println("Number of lights to display: "+ num_lights);

            if (num_lights == 0) {
                WatchUi.switchToView(new LifxNoLightsView(), new ConnectIQLIFXDelegate(), WatchUi.SLIDE_LEFT);
            } else {
                var menu = new WatchUi.Menu2({:title=>"Select Light"});
                if (menu has :setTheme) {
                    menu.setTheme(WatchUi.MENU_THEME_PURPLE);
                }
                var delegate;
                for( var i = 0; i < num_lights; i++ ) {
                    menu.addItem(
                        new MenuItem(
                            $.LIFX_API_OBJ.lights[i]["label"],
                            $.LIFX_API_OBJ.lights[i]["group"]["name"],
                            $.LIFX_API_OBJ.lights[i]["light_num"],
                            {}
                        )
                    );
                }

                delegate = new LifxLightInputDelegate();
                WatchUi.pushView(menu, delegate, WatchUi.SLIDE_LEFT);
            }
        } else {
            System.println("Item not recognised: " + item.getId());
        }
    }
}


class LifxSceneInputDelegate extends WatchUi.Menu2InputDelegate {
    // Handles selection of a scene to apply
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        var id = item.getId() as String;
        var loading_view = new SendingSignalView(false);
        var loading_delegate = new ConnectIQLIFXDelegate();
        WatchUi.pushView(loading_view, loading_delegate, WatchUi.SLIDE_LEFT);
        $.LIFX_API_OBJ.applying_selection = true;
        System.println("Recieved item: " + item);
        var selected_scene = $.LIFX_API_OBJ.scenes[id];
        $.LIFX_API_OBJ.set_scene(selected_scene["uuid"]);
    }
}

class LifxNoScenesView extends WatchUi.View {

    public function initialize() {
        View.initialize();
    }

    public function onLayout(dc as Dc) {
        setLayout($.Rez.Layouts.NoScenesLayout(dc));
    }

    public function onShow() as Void {
    }

    public function onUpdate(dc as Dc) as Void {
        View.onUpdate(dc);
    }

    public function onHide() as Void {
    }
}

class LifxLightInputDelegate extends WatchUi.Menu2InputDelegate {
    // Handles selection of a light to apply

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        var id = item.getId() as String;
        var loading_view = new SendingSignalView(false);
        var loading_delegate = new ConnectIQLIFXDelegate();
        WatchUi.pushView(loading_view, loading_delegate, WatchUi.SLIDE_LEFT);
        $.LIFX_API_OBJ.applying_selection = true;
        System.println("Recieved item: " + item);
        var selected_light = $.LIFX_API_OBJ.lights[id];
        $.LIFX_API_OBJ.toggle_power("id:" + selected_light["id"]);
    }
}

class LifxNoLightsView extends WatchUi.View {

    public function initialize() {
        View.initialize();
    }

    public function onLayout(dc as Dc) {
        setLayout($.Rez.Layouts.NoLightsLayout(dc));
    }

    public function onShow() as Void {
    }

    public function onUpdate(dc as Dc) as Void {
        View.onUpdate(dc);
    }

    public function onHide() as Void {
    }
}