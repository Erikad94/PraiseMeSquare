import Toybox.Application;
import Toybox.Application.Properties;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class PraiseMeSquareView extends WatchUi.WatchFace {

    var mode   = "dominant";
    var gender = "female";
    var praiseColor = 0xd61ad6;
    var firstColor = 0x44F9FF;
    var accentColor = 0xFF29FF;

    function initialize() {  WatchFace.initialize(); }
    function onLayout(dc as Dc) as Void { }

    function onShow() as Void {
        UpdateModeForDate();
    }

    function UpdateModeForDate() as Void {
        var today = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        if (today.day_of_week == 1) {
            mode = "dominant";
        } else if (today.day_of_week == 2) {
            mode = "flirty";
        } else if (today.day_of_week == 3) {
            mode = "chaotic";
        } else if (today.day_of_week == 4) {
            mode = "degrading";
        } else if (today.day_of_week == 5) {
            mode = "flirty";
        } else if (today.day_of_week == 6) {
            mode = "chaotic";
        } else if (today.day_of_week == 7) {
            mode = "dominant";
        }
    }

    function onHide() as Void { }
    function onExitSleep() as Void {}
    function onEnterSleep() as Void {}

    function onUpdate(dc as Dc) as Void 
    {
        var profile = UserProfile.getProfile();
        var gender = profile.gender;

        if (gender == UserProfile.GENDER_MALE) {
            gender = "male";
        }

        UpdateModeForDate();
        var smallFont =  WatchUi.loadResource( Rez.Fonts.WeatherFont);
        var wordFont =  WatchUi.loadResource( Rez.Fonts.smallFont);
        var praiseFont = WatchUi.loadResource( Rez.Fonts.praiseFont);
        var mySettings = System.getDeviceSettings();

        View.onUpdate(dc);

        //anchors
        var centerX = (dc.getWidth()) / 2;
        var centerY = (dc.getHeight()) / 2;

        var steps    = 0;
        var info = ActivityMonitor.getInfo();
            if (info != null && info.steps    != null) { steps    = info.steps; }
        var praiseText = GetPraise(steps.toNumber());
        var offsetTimeForPraise = 0;
        var offsetTopIconsForPraise = 0;
        var offsetBottomIconsForPraise = 0;
        var textOffsetTopLine = 0;
        var textOffsetMidLine = 25;
        var textOffsetBottomLine = 50;
        
        dc.setColor(praiseColor, Graphics.COLOR_TRANSPARENT);

        var lines = [];
        for (var i = 0; i < 3; i++) {
            var line = praiseText[i];
            if (line == null || line.length() == 0) 
            { 
                break; 
            }
            lines.add(line);
        }

        if (lines.size() > 0) 
        {
            offsetTimeForPraise = 30;
            offsetTopIconsForPraise = 20;
            offsetBottomIconsForPraise = 20;

            if (lines.size() == 1) 
            {
                textOffsetTopLine = 25;
                dc.drawText(centerX, centerY + textOffsetTopLine, praiseFont, lines[0], Graphics.TEXT_JUSTIFY_CENTER);
            } 
            else if (lines.size() == 2) 
            {
                textOffsetTopLine = 10;
                textOffsetMidLine = 40;

                dc.drawText(centerX, centerY + textOffsetTopLine, praiseFont, lines[0], Graphics.TEXT_JUSTIFY_CENTER);
                dc.drawText(centerX, centerY + textOffsetMidLine, praiseFont, lines[1], Graphics.TEXT_JUSTIFY_CENTER);
            } 
            else if (lines.size() == 3) 
            {
                textOffsetTopLine = 0;
                textOffsetMidLine = 25;
                textOffsetBottomLine = 50;
                offsetTimeForPraise = 40;

                dc.drawText(centerX, centerY + textOffsetTopLine, praiseFont, lines[0], Graphics.TEXT_JUSTIFY_CENTER);
                dc.drawText(centerX, centerY + textOffsetMidLine, praiseFont, lines[1], Graphics.TEXT_JUSTIFY_CENTER);
                dc.drawText(centerX, centerY + textOffsetBottomLine, praiseFont, lines[2], Graphics.TEXT_JUSTIFY_CENTER);
            }
        }

        SetRectangles(dc, mySettings);
        SetMonthDisplay(dc, centerX, centerY, wordFont);
        SetTimeDisplay(dc, centerX, centerY, offsetTimeForPraise);
        SetCaloriesDisplay(dc, wordFont, centerX, centerY, offsetTopIconsForPraise);
        SetStepsDisplay(dc, wordFont, centerX, centerY, offsetTopIconsForPraise);
        SetWeatherDisplay(dc, smallFont, wordFont, centerX, centerY, offsetBottomIconsForPraise);
        SetNotificationsDisplay(dc, wordFont, centerX, centerY, mySettings, offsetBottomIconsForPraise);
        SetBatteryDisplay(dc, wordFont, centerX, centerY);
    }

    private function SetRectangles(dc as Dc, mySettings as Toybox.System.DeviceSettings) 
    {
        if (mySettings.screenShape != 1)
        {
            var ExactY = (dc.getHeight());
            var ExactX = (dc.getWidth());
            dc.setPenWidth(7);    
            dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);        
            dc.drawRectangle(0,0, ExactX, ExactY) ;
            dc.setColor(firstColor, Graphics.COLOR_TRANSPARENT);        
            dc.drawRectangle(10,10, ExactX-20, ExactY-20) ; 
        }
    }

    private function SetMonthDisplay(dc as Dc, centerX as Number, centerY as Number, wordFont as Graphics.FontType) 
    {
        var weekdayArray = ["Day", "SUNDAY", "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY"] as Array<String>;
        var monthArray = ["Month", "JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE", "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"] as Array<String>;
        var today = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);

        dc.setColor(firstColor, Graphics.COLOR_TRANSPARENT);  
        dc.drawText(centerX,30,wordFont,(weekdayArray[today.day_of_week]+", "+ monthArray[today.month]+" "+ today.day +" " +today.year), Graphics.TEXT_JUSTIFY_CENTER );
    }

    private function SetTimeDisplay(dc as Dc, centerX as Number, centerY as Number, offsetForPraise as Number) 
    {
        var timeFormat = "$1$:$2$";
        var clockTime = System.getClockTime();
        var hours = clockTime.hour;
        var timeString = Lang.format(timeFormat, [hours, clockTime.min.format("%02d")]);
        var timeFont =  WatchUi.loadResource( Rez.Fonts.timeFont );

        dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX + 3, centerY-43-offsetForPraise, timeFont, timeString, Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(firstColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, centerY-45-offsetForPraise, timeFont, timeString, Graphics.TEXT_JUSTIFY_CENTER);
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

    private function SetCaloriesDisplay(dc as Dc, wordFont as Graphics.FontType, centerX as Number, centerY as Number, offsetForPraise as Number) 
    {
        var userCAL = 0;
        var info = ActivityMonitor.getInfo();
        if (info != null && info.calories != null)
        {
            userCAL = info.calories.toNumber();
        } 

        dc.setColor(firstColor, Graphics.COLOR_TRANSPARENT); 
        dc.drawText( centerX-(centerX/2), centerY-(centerY/2)-offsetForPraise, wordFont,  (" "+userCAL), Graphics.TEXT_JUSTIFY_LEFT );
        dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);  
        dc.drawText( centerX-(centerX/2)+1,  centerY-(centerY/2)+6-offsetForPraise, wordFont,  (" ~ "), Graphics.TEXT_JUSTIFY_RIGHT );
        dc.setColor(firstColor, Graphics.COLOR_TRANSPARENT);  
        dc.drawText( centerX-(centerX/2),  centerY-(centerY/2)+5-offsetForPraise, wordFont,  (" ~ "), Graphics.TEXT_JUSTIFY_RIGHT );
    }

    private function SetStepsDisplay(dc as Dc, wordFont as Graphics.FontType, centerX as Number, centerY as Number, offsetForPraise as Number) 
    {
        var userSTEPS = 0;
        var info = ActivityMonitor.getInfo();
        if (info != null && info.steps != null)
        {
            userSTEPS = info.steps.toNumber();
        }

        dc.setColor(firstColor, Graphics.COLOR_TRANSPARENT); 
        dc.drawText( centerX+(centerX/2)-20,  centerY-(centerY/2)-offsetForPraise, wordFont,  (" "+userSTEPS), Graphics.TEXT_JUSTIFY_LEFT);
        dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText( centerX+(centerX/2)-20+1,  centerY-(centerY/2)+6-offsetForPraise, wordFont,  (" ^ "), Graphics.TEXT_JUSTIFY_RIGHT );
        dc.setColor(firstColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText( centerX+(centerX/2)-20,  centerY-(centerY/2)+5-offsetForPraise, wordFont,  (" ^ "), Graphics.TEXT_JUSTIFY_RIGHT );
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

    private function SetWeatherDisplay(dc as Dc, smallFont as Graphics.FontType, wordFont as Graphics.FontType, centerX as Number, centerY as Number, offsetForPraise as Number) 
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

        dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText( centerX-(centerX/2)+1,  centerY+(centerY/2)-4-20+offsetForPraise, smallFont, weather(cond), Graphics.TEXT_JUSTIFY_RIGHT );
        dc.setColor(firstColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText( centerX-(centerX/2),  centerY+(centerY/2)-5-20+offsetForPraise, smallFont, weather(cond), Graphics.TEXT_JUSTIFY_RIGHT );
        dc.setColor(firstColor, Graphics.COLOR_TRANSPARENT); 
        dc.drawText( centerX-(centerX/2)+10,  centerY+(centerY/2)-20+offsetForPraise, wordFont, (TEMP+" " +FC), Graphics.TEXT_JUSTIFY_LEFT );
    }

    private function SetNotificationsDisplay(dc as Dc, wordFont as Graphics.FontType, centerX as Number, centerY as Number, mySettings as Toybox.System.DeviceSettings, offsetForPraise as Number) 
    {
        var numberNotify = 0;
        if (mySettings.notificationCount != null){numberNotify = mySettings.notificationCount.toNumber();}

        dc.setColor(firstColor, Graphics.COLOR_TRANSPARENT);  
        dc.drawText(centerX+(centerX/2)-20,  centerY+(centerY/2)-20+offsetForPraise, wordFont,(" "+numberNotify),Graphics.TEXT_JUSTIFY_LEFT);
        dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT); 
        dc.drawText(centerX+(centerX/2)-20+1,  centerY+(centerY/2)-4-20+offsetForPraise, wordFont,  (" # "),Graphics.TEXT_JUSTIFY_RIGHT);
        dc.setColor(firstColor, Graphics.COLOR_TRANSPARENT); 
        dc.drawText(centerX+(centerX/2)-20,  centerY+(centerY/2)-5-20+offsetForPraise, wordFont,  (" # "),Graphics.TEXT_JUSTIFY_RIGHT);
    }

    private function SetBatteryDisplay(dc as Dc, wordFont as Graphics.FontType, centerX as Number, centerY as Number) 
    {
        var batteryMeter = 1;
        var myStats = System.getSystemStats();
        if (myStats.battery != null)
        {
            batteryMeter = myStats.battery.toNumber();
        }

        dc.setColor(firstColor, Graphics.COLOR_TRANSPARENT); 
        dc.drawText( centerX, centerY+(centerY/1.5)+12, wordFont,  (batteryMeter+"%"), Graphics.TEXT_JUSTIFY_LEFT );
        dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT); 
        dc.drawText( centerX+1 , centerY+(centerY/1.5)+11, wordFont,  " [ ", Graphics.TEXT_JUSTIFY_RIGHT );
        dc.setColor(firstColor, Graphics.COLOR_TRANSPARENT); 
        dc.drawText( centerX, centerY+(centerY/1.5)+10, wordFont,  " [ ", Graphics.TEXT_JUSTIFY_RIGHT );
    }

    function GetPetName(steps) {
        var namesBoy  = ["puppy", "pet", "kitten", "baby boy"];
        var namesGirl = ["puppy", "pet", "kitten", "baby girl", "princess"];
        var list  = (gender == "male") ? namesBoy : namesGirl;
        var index = Math.floor((steps / 1000) % list.size()).toNumber();
        return list[index];
    }

    function GetNickName(steps) {
        var namesBoy  = ["puppy", "pet", "boy"];
        var namesGirl = ["kitten", "pet", "girl"];
        var list  = (gender == "male") ? namesBoy : namesGirl;
        var index = Math.floor((steps / 1000) % list.size()).toNumber();
        return list[index];
    }

    function GetDegradingNickname(steps) {
        var namesBoy  = ["whore", "slut", "princess", "plaything"];
        var namesGirl = ["whore", "slut", "plaything"];
        var list  = (gender == "male") ? namesBoy : namesGirl;
        var index = Math.floor((steps / 1000) % list.size()).toNumber();
        return list[index];
    }

    function GetPraise(steps) {
        var pet = GetPetName(steps);
        var nick = GetNickName(steps);
        var degradingNick = GetDegradingNickname(steps);

        if ((Math.rand() % 100) == 0) {
            if (mode == "dominant")  { return ["...good.","Keep it that way.", ""]; }
            if (mode == "flirty")    { return ["...mm,","I noticed that.",""]; }
            if (mode == "chaotic")   { return ["Oh?","That caught my attention.",""]; }
            if (mode == "degrading") { return ["...finally." ,"Took you long enough,",pet + "."]; }
        }

        if (mode.equals("flirty")) {
            if (steps >= 15000) { return ["You really did", "that for me...", "I like it."]; }
            if (steps >= 12000) { return ["You just keep going.", "don't you?", ""]; }
            if (steps >= 10000) { return ["10k already?", "Such a good " + nick + ".", ""]; }
            if (steps >= 7500)  { return ["Trying to impress me,", pet + "?", ""]; }
            if (steps >= 5000)  { return ["Keep going...", "I'm watching.", ""]; }
            if (steps >= 2000)  { return ["That's it...", "steady.", ""]; }
            return ["Don't make me wait...", "", ""];
        }

        if (mode.equals("chaotic")) {
            if (steps >= 15000) { return ["Okay WOW--", "this is getting", "out of hand."]; }
            if (steps >= 12000) { return ["You're actually", "doing this", "huh?"]; }
            if (steps >= 10000) { return ["Look at you go.", "", ""]; }
            if (steps >= 7500)  { return ["Oh?", "Now you care?", ""]; }
            if (steps >= 5000)  { return ["That's...", "something, " + pet + ".", ""]; }
            if (steps >= 2000)  { return ["Try harder.", "", ""]; }
            return ["Really?","That's it?",""];
        }

        if (mode.equals("dominant")) {
            if (steps >= 15000) { return ["You finished what", "you started.", "Good " + nick + "."]; }
            if (steps >= 12000) { return ["Keep pushing.", "Don't stop, " + pet + ".", ""]; }
            if (steps >= 10000) { return ["10k.", "Acceptable.", ""]; }
            if (steps >= 7500)  { return ["Not done...", "yet.", ""]; }
            if (steps >= 5000)  { return ["Focus", "", ""]; }
            if (steps >= 2000)  { return ["Move", "", ""]; }
            return ["Start. Now", "", ""];
        }

        if (mode.equals("degrading")) {
            if (steps >= 15000) { return ["Huh.", "You actually did it.", "Fine, " + pet + "."]; }
            if (steps >= 12000) { return ["You met expectations.", "Barely.", ""]; }
            if (steps >= 10000) { return ["10k. Minimum reached,", "good" + degradingNick + ".", ""]; }
            if (steps >= 7500)  { return ["Still not enough.", "", ""]; }
            if (steps >= 5000)  { return ["Weak effort.", "", ""]; }
            if (steps >= 2000)  { return ["Move faster,", "" + degradingNick + ".", ""]; }
            return ["Embarrassing.", "", ""];
        }

        return ["", "", ""];
    }
}
