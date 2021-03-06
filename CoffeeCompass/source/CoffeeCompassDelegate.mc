using Toybox.WatchUi as Ui;
using Toybox.Communications as Comm;
using Toybox.System;
using Toybox.Position;

class CoffeeCompassDelegate extends Ui.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }
    

//    function headingToString( heading ) {
//        if( heading <= 22.5 and heading > -22.5 ) {
//            return "E";
//        } else if( heading <= 67.5 and heading > 22.5 ) {
//            return "NE";
//        } else if( heading <= 112.5 and heading > 67.5 ) {
//            return "N";
//        } else if( heading <= 157.5 and heading > 112.5 ) {
//            return "NW";
//        } else if( heading <= 202.5 and heading > 157.5 ) {
//            return "W";
//        } else if( heading <= 247.5 and heading > 202.5 ) {
//            return "SW";
//        } else if( heading >= -157.5 and heading <  ) {
//            return "S";
//        } else {
//            return "SE";
//        } 
//    }
    
    // callback for position data aquisition
    function onPosition( info ) {
        //var location = info.position.toDegrees();
	}
    
    function onCoffeePress() {
        queryFoursquare( "coffee", null, 1 );
        showLoadingScreen();
        return true;
    }
    
    hidden var _fs_section;
    hidden var _fs_query;
    hidden var _fs_limit;
    
    function queryFoursquare( section, query, limit ) {
        _fs_section = section;
        _fs_query = query;
        _fs_limit = limit;
        Position.enableLocationEvents( Position.LOCATION_ONE_SHOT, method( :_queryFoursquare ) );
        _queryFoursquare( null );
    }
    
    function _queryFoursquare( info ) {
        
        // TODO uncomment this when uploading
        //var position = info.position.toRadians();
        var position = [ 39.14443, -94.579239 ];
        
        var ll = position[0].format("%.2f") + "," + position[1].format("%.2f");
        var url = "https://api.foursquare.com/v2/venues/explore";
        var params = {
            "client_id" => "Q0FXJ3D4IYOSCZI3TYDJH5Y1A3IK5GXPWBCVYVIXW2RHGNDN",
            "client_secret" => "45CSDE1CMHITQPRCLAEAUPGZRBFWAPX0XQRMCY4GZS0FZ4SW",
            "v" => 20180721,
            "ll" => ll,
            "radius" => 3000,
            "limit" => _fs_limit,
            "section" => _fs_section,
            "query" => _fs_query,
            "openNow" => 0
        };
        var options = {
           :method => Communications.HTTP_REQUEST_METHOD_GET,
           :headers => {
               "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED
           },
           :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };
        
        Comm.makeWebRequest(
            url,
            params,
            options,
            method(:onReceive)
        );
    }
    
    // show the loading screen now that venues are being loaded
    function showLoadingScreen() {
        return true;
    }
    
    // an error occurred while loading venues
    function onLoadingFailed( responseCode ) {
        System.print( "ERROR: failed to get Foursquare data: " );
        System.println( responseCode );
    }
    
    // no venues were found nearby
    function onNoVenues() {
        System.print( "ERROR: There weren't any venues open" );
    }
    
    // at least one venue was successfully loaded
    function onLoadingSuccess( data ) {
        Ui.pushView(new CompassView(data), new CompassDelegate(), Ui.SLIDE_IMMEDIATE);  
    }
    
    // receive the data from the web request
    function onReceive(responseCode, data) {
        if( responseCode != 200 ) {
            onLoadingFailed( responseCode );
        } else {
            var output = convertFoursquare( data );
            if( output.size() > 0 ) {
                onLoadingSuccess( output );
            } else {
                onNoVenues();
            }           
        }   
    }

    // format Foursquare data
    function convertFoursquare( data ) {
	    var items = data.get( "response" ).get( "groups" )[0].get( "items" );
	    var items_size = items.size();
	    var output = new [ items_size ];
	    for( var i = 0; i < items_size; i++ ) {
	        output[ i ] = {};
	        var this_output = output[ i ];
	        var venue = items[ i ].get( "venue" );
	        var location = venue.get( "location" );
	        this_output.put( "name", venue.get( "name" ) );
	        this_output.put( "address", location.get( "address" ) );
	        this_output.put( "lat", location.get( "lat" ).toFloat() );
	        this_output.put( "lng", location.get( "lng" ).toFloat() );
	    }
        return output;
    }
}