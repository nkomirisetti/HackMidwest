using Toybox.WatchUi as Ui;

class ListView extends Ui.View {
var location;
    function initialize(description) {
    	Ui.View.initialize();
        location = description;
    }

    //! Load your resources here
    function onLayout(dc) {
    }

    //! Called when this View is brought to the foreground. Restore
    //! the state of this View and prepare it to be shown. This includes
    //! loading resources into memory.
    function onShow() {
    }

    //! Update the view
    function onUpdate(dc) {
        //dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
    }
}