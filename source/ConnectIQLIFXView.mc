using Toybox.WatchUi;


class SendingSignalView extends WatchUi.View {
    // A basic view that just shows some text when a request is being made
    hidden var mMessage = "Sending signal to LIFX...";
    var create_menu = false;
    function initialize(create_new_menu) {
        WatchUi.View.initialize();
        create_menu = create_new_menu;
    }
    function onShow() {
        // Start initial view
    }
    function onUpdate(dc) {
        System.println("SendingSignalView: onUpdate() called with $.LIFX_API_OBJ.applying_selection : " + $.LIFX_API_OBJ.applying_selection);
        if ($.LIFX_API_OBJ.applying_selection == true) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.clear();
            dc.drawText(dc.getWidth()/2, dc.getHeight()/2, Graphics.FONT_SYSTEM_TINY, mMessage, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        } else {
            if (create_menu == false) {
                WatchUi.popView(WatchUi.SLIDE_DOWN);  // Return to menu's screen
            } else {
                // This is neccesary for toggle_all_lights(), not quite sure why, but otherwise it wont return to the main menu properly
                var main_delegate = new ConnectIQLIFXDelegate();
                var mView = new ConnectIQLIFXView();
                WatchUi.switchToView(mView, main_delegate, WatchUi.SLIDE_DOWN);
            }
        }
    }
}

class ConnectIQLIFXView extends WatchUi.View {
    // Initial view when app is first loaded
    hidden var mMessage = "Loading data from LIFX...";
    hidden var mModel;

    function initialize() {
        WatchUi.View.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        mMessage = "Loading data from LIFX...";
        //create_main_menu();
    }

    // Restore the state of the app and prepare the view to be shown
    function onShow() {
        // Start initial view
        System.println("ConnectIQLIFXView: onShow() called with $.LIFX_API_OBJ.auth_ok = " + $.LIFX_API_OBJ.auth_ok);

        if ($.LIFX_API_OBJ.auth_ok == true && $.LIFX_API_OBJ.applying_selection == false) {
            create_main_menu();
            //WatchUi.switchToView(main_menu, main_menu_delegate, WatchUi.SLIDE_DOWN);
        } else if ($.LIFX_API_OBJ.auth_ok == null){
            mMessage = "Loading data from LIFX...";
        } else if ($.LIFX_API_OBJ.applying_selection == true) {
            mMessage = "Sending signal to LIFX...";
        } else {
                mMessage = "Authentication Error\nSet API Key via\n Garmin Connect";
        }
    }

    // Update the view
    function onUpdate(dc) {
        System.println("ConnectIQLIFXView: onUpdate() called with $.LIFX_API_OBJ.auth_ok = " + $.LIFX_API_OBJ.auth_ok);
        if ($.LIFX_API_OBJ.auth_ok == true && $.LIFX_API_OBJ.applying_selection == false) {
            create_main_menu();
        } else {
            System.println("onUpdate() pushing mMessage, $.LIFX_API_OBJ.applying_selection = " + $.LIFX_API_OBJ.applying_selection);
            if ($.LIFX_API_OBJ.applying_selection == true) {
                mMessage = "Sending signal to LIFX...";
            } else if ($.LIFX_API_OBJ.auth_ok == false) {
                mMessage = "Authentication Error\nSet API Key via\n Garmin Connect";
            }
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.clear();
            dc.drawText(dc.getWidth()/2, dc.getHeight()/2, Graphics.FONT_SYSTEM_TINY, mMessage, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }


    }

    // Called when this View is removed from the screen. Save the
    // state of your app here.
    function onHide() {
        return true;
    }

    // Creates and pushes the main app menu
    function create_main_menu(){
        var init_menu = new WatchUi.Menu2({:title=>"LIFX Controller"});
        if (init_menu has :setTheme) {
            init_menu.setTheme(WatchUi.MENU_THEME_PURPLE);
        }
        var delegate;
        init_menu.addItem(
            new MenuItem(
                "Toggle all lights",
                null,
                "toggle_all_lights",
                {}
            )
        );
        init_menu.addItem(
            new MenuItem(
                "Toggle a light",
                null,
                "toggle_light",
                {}
            )
        );
        init_menu.addItem(
            new MenuItem(
                "Apply a scene",
                null,
                "apply_scene",
                {}
            )
        );
        delegate = new LifxMainInputDelegate();
        WatchUi.pushView(init_menu, delegate, WatchUi.SLIDE_IMMEDIATE);
        return true;
    }

    function onReceive(args) {
        if (args instanceof Lang.String) {
            mMessage = args;
        }
        else if (args instanceof Dictionary) {
            // Print the arguments duplicated and returned by jsonplaceholder.typicode.com
            var keys = args.keys();
            mMessage = "";
            for( var i = 0; i < keys.size(); i++ ) {
                mMessage += Lang.format("$1$: $2$\n", [keys[i], args[keys[i]]]);
            }
        }
        WatchUi.requestUpdate();
    }
}