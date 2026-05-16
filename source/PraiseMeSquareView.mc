import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class PraiseMeSquareView extends WatchUi.WatchFace {

    function initialize() {  WatchFace.initialize(); }
    function onLayout(dc as Dc) as Void { }
    function onShow() as Void { }
    function onHide() as Void { }
    function onExitSleep() as Void {}
    function onEnterSleep() as Void {}

    function onUpdate(dc as Dc) as Void 
    {
        var smallFont =  WatchUi.loadResource( Rez.Fonts.WeatherFont );
        var wordFont =  WatchUi.loadResource( Rez.Fonts.smallFont );
        var mySettings = System.getDeviceSettings();

        //anchors
        var centerX = (dc.getWidth()) / 2;
        var centerY = (dc.getHeight()) / 2;

        View.onUpdate(dc);

        SetRectangles(dc, mySettings);
        SetMonthDisplay(dc, centerX, centerY, wordFont);
        SetTimeDisplay(dc, centerX, centerY);
        SetCaloriesDisplay(dc, wordFont, centerX, centerY);
        SetStepsDisplay(dc, wordFont, centerX, centerY);
        SetWeatherDisplay(dc, smallFont, wordFont, centerX, centerY);
        SetNotificationsDisplay(dc, wordFont, centerX, centerY, mySettings);
        SetBatteryDisplay(dc, wordFont, centerX, centerY);
    }

    private function SetRectangles(dc as Dc, mySettings as Toybox.System.DeviceSettings) 
    {
        if (mySettings.screenShape != 1){
            var ExactY = (dc.getHeight());
            var ExactX = (dc.getWidth());
            dc.setPenWidth(7);    
            dc.setColor(0xFF29FF, Graphics.COLOR_TRANSPARENT);        
            dc.drawRectangle(0,0, ExactX, ExactY) ;
            dc.setColor(0x44F9FF, Graphics.COLOR_TRANSPARENT);        
            dc.drawRectangle(10,10, ExactX-20, ExactY-20) ; 
        }
    }

    private function SetMonthDisplay(dc as Dc, centerX as Number, centerY as Number, wordFont as Graphics.FontType) 
    {
        var weekdayArray = ["Day", "SUNDAY", "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY"] as Array<String>;
        var monthArray = ["Month", "JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE", "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"] as Array<String>;
        var today = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);

        dc.setColor(0x44F9FF, Graphics.COLOR_TRANSPARENT);  
        dc.drawText(centerX,30,wordFont,(weekdayArray[today.day_of_week]+" , "+ monthArray[today.month]+" "+ today.day +" " +today.year), Graphics.TEXT_JUSTIFY_CENTER );
    }

    private function SetTimeDisplay(dc as Dc, centerX as Number, centerY as Number) 
    {
        var timeFormat = "$1$:$2$";
        var clockTime = System.getClockTime();
        var hours = clockTime.hour;
        var timeString = Lang.format(timeFormat, [hours, clockTime.min.format("%02d")]);
        var timeFont =  WatchUi.loadResource( Rez.Fonts.timeFont );

        dc.setColor(0xFF00AA, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX + 3, centerY-43, timeFont, timeString, Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(0x00FFFF, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, centerY-45, timeFont, timeString, Graphics.TEXT_JUSTIFY_CENTER);
    }

    // Heart rate is not currently being used in the watch face, but this function can be used to retrieve the current heart rate if you want to add it in the future
    private function SetHeartRateDisplay(dc as Dc, centerX as Number, centerY as Number) 
    {
        var heartRate = null;
        var info = Activity.getActivityInfo();
        if (info != null) 
        {
            heartRate = info.currentHeartRate;
        } 
        else 
        { 
            var latestHeartRateSample = ActivityMonitor.getHeartRateHistory(1, true).next();
            if (latestHeartRateSample != null) 
            {
                heartRate = latestHeartRateSample.heartRate;
            } 
        }

        // You can use the heartRate variable to display the heart rate on the watch face if desired
    }

    private function SetCaloriesDisplay(dc as Dc, wordFont as Graphics.FontType, centerX as Number, centerY as Number) 
    {
        var userCAL = 0;
        var info = ActivityMonitor.getInfo();
        if (info != null && info.calories != null)
        {
            userCAL = info.calories.toNumber();
        } 

        dc.setColor(0x44F9FF, Graphics.COLOR_TRANSPARENT); 
        dc.drawText( centerX-(centerX/2), centerY-(centerY/2), wordFont,  (" "+userCAL), Graphics.TEXT_JUSTIFY_LEFT );
        dc.setColor(0xFF00AA, Graphics.COLOR_TRANSPARENT);  
        dc.drawText( centerX-(centerX/2)+1,  centerY-(centerY/2)+6, wordFont,  (" ~ "), Graphics.TEXT_JUSTIFY_RIGHT );
        dc.setColor(0x44F9FF, Graphics.COLOR_TRANSPARENT);  
        dc.drawText( centerX-(centerX/2),  centerY-(centerY/2)+5, wordFont,  (" ~ "), Graphics.TEXT_JUSTIFY_RIGHT );
    }

    private function SetStepsDisplay(dc as Dc, wordFont as Graphics.FontType, centerX as Number, centerY as Number) 
    {
        var userSTEPS = 0;
        var info = ActivityMonitor.getInfo();
        if (info != null && info.steps != null)
        {
            userSTEPS = info.steps.toNumber();
        }

        dc.setColor(0x44F9FF, Graphics.COLOR_TRANSPARENT); 
        dc.drawText( centerX+(centerX/2)-20,  centerY-(centerY/2), wordFont,  (" "+userSTEPS), Graphics.TEXT_JUSTIFY_LEFT);
        dc.setColor(0xFF00AA, Graphics.COLOR_TRANSPARENT);
        dc.drawText( centerX+(centerX/2)-20+1,  centerY-(centerY/2)+6, wordFont,  (" ^ "), Graphics.TEXT_JUSTIFY_RIGHT );
        dc.setColor(0x44F9FF, Graphics.COLOR_TRANSPARENT);
        dc.drawText( centerX+(centerX/2)-20,  centerY-(centerY/2)+5, wordFont,  (" ^ "), Graphics.TEXT_JUSTIFY_RIGHT );
    }

    function weather(cond) 
    {
        if (cond == 0 || cond == 40){return "b";}//sun
        else if (cond == 50 || cond == 49 ||cond == 47||cond == 45||cond == 44||cond == 42||cond == 31||cond == 27||cond == 26||cond == 25||cond == 24||cond == 21||cond == 18||cond == 15||cond == 14||cond == 13||cond == 11||cond == 3){return "a";}//rain
        else if (cond == 52||cond == 20||cond == 2||cond == 1){return "e";}//cloud
        else if (cond == 5 || cond == 8|| cond == 9|| cond == 29|| cond == 30|| cond == 33|| cond == 35|| cond == 37|| cond == 38|| cond == 39){return "g";}//wind
        else if (cond == 51 || cond == 48|| cond == 46|| cond == 43|| cond == 10|| cond == 4){return "i";}//snow
        else if (cond == 32 || cond == 37|| cond == 41|| cond == 42){return "f";}//whirlwind 
        else {return "c";}//suncloudrain 
    }

    private function SetWeatherDisplay(dc as Dc, smallFont as Graphics.FontType, wordFont as Graphics.FontType, centerX as Number, centerY as Number) 
    {
        var getCC = Toybox.Weather.getCurrentConditions();
        var TEMP = "000";
        var FC = "0";
        if(getCC != null && getCC.temperature!=null)
        {     
            if (System.getDeviceSettings().temperatureUnits == 0)
            {  
                FC = "C";
                TEMP = getCC.temperature.format("%d");
            }
            else
            {
                TEMP = (((getCC.temperature*9)/5)+32).format("%d"); 
                FC = "F";   
            }
        }
        else 
        {
            TEMP = "000";
        }
        
        var cond=0;
        if (getCC != null)
        { 
            cond = getCC.condition.toNumber();
        }
        else
        {
            cond = 0;
        }

        dc.setColor(0xFF00AA, Graphics.COLOR_TRANSPARENT);
        dc.drawText( centerX-(centerX/2)+1,  centerY+(centerY/2)-4-20, smallFont, weather(cond), Graphics.TEXT_JUSTIFY_RIGHT );
        dc.setColor(0x44F9FF, Graphics.COLOR_TRANSPARENT);
        dc.drawText( centerX-(centerX/2),  centerY+(centerY/2)-5-20, smallFont, weather(cond), Graphics.TEXT_JUSTIFY_RIGHT );
        dc.setColor(0x44F9FF, Graphics.COLOR_TRANSPARENT); 
        dc.drawText( centerX-(centerX/2)+10,  centerY+(centerY/2)-20, wordFont, (TEMP+" " +FC), Graphics.TEXT_JUSTIFY_LEFT );
    }

    private function SetNotificationsDisplay(dc as Dc, wordFont as Graphics.FontType, centerX as Number, centerY as Number, mySettings as Toybox.System.DeviceSettings) 
    {
        var numberNotify = 0;
        if (mySettings.notificationCount != null){numberNotify = mySettings.notificationCount.toNumber();}

        dc.setColor(0x44F9FF, Graphics.COLOR_TRANSPARENT);  
        dc.drawText(centerX+(centerX/2)-20,  centerY+(centerY/2)-20, wordFont,(" "+numberNotify),Graphics.TEXT_JUSTIFY_LEFT);
        dc.setColor(0xFF00AA, Graphics.COLOR_TRANSPARENT); 
        dc.drawText(centerX+(centerX/2)-20+1,  centerY+(centerY/2)-4-20, wordFont,  (" # "),Graphics.TEXT_JUSTIFY_RIGHT);
        dc.setColor(0x44F9FF, Graphics.COLOR_TRANSPARENT); 
        dc.drawText(centerX+(centerX/2)-20,  centerY+(centerY/2)-5-20, wordFont,  (" # "),Graphics.TEXT_JUSTIFY_RIGHT);
    }

    private function SetBatteryDisplay(dc as Dc, wordFont as Graphics.FontType, centerX as Number, centerY as Number) 
    {
        var batteryMeter = 1;
        var myStats = System.getSystemStats();
        if (myStats.battery != null)
        {
            batteryMeter = myStats.battery.toNumber();
        }

        dc.setColor(0x44F9FF, Graphics.COLOR_TRANSPARENT); 
        dc.drawText( centerX, centerY+(centerY/1.5)+12, wordFont,  (batteryMeter+"%"), Graphics.TEXT_JUSTIFY_LEFT );
        dc.setColor(0xFF00AA, Graphics.COLOR_TRANSPARENT); 
        dc.drawText( centerX+1 , centerY+(centerY/1.5)+11, wordFont,  " [ ", Graphics.TEXT_JUSTIFY_RIGHT );
        dc.setColor(0x44F9FF, Graphics.COLOR_TRANSPARENT); 
        dc.drawText( centerX, centerY+(centerY/1.5)+10, wordFont,  " [ ", Graphics.TEXT_JUSTIFY_RIGHT );
    }
}
