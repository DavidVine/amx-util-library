program_name='date-time'

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Include: date-time
// 
// Description:
//
//    - This include file provides functions for working with dates and time.
//
// Implementation:
//
//    - Any NetLinx program utilising the date-time include file must use either the INCLUDE or #INCLUDE keywords to 
//      include the date-time include file within the program. While the INCLUDE and #INCLUDE keywords are both 
//      functionally equivalent the #INCLUDE keyword is recommended only because it is the NetLinx keyword (the INCLUDE
//      keyword is from the earlier Axcess programming language and is included within the NetLinx programming language 
//      for backwards compatibility).
//
//      Note: The NetLinx language is not case-sensitive when it comes to keywords. The convention used in this project
//      is for keywords to be written in lower case (e.g., include instead of INCLUDE).
//
//      E.g:
//
//          define_program 'DateTime Demo'
//
//          #include 'date-time'
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


#if_not_defined __DATE_TIME__
#define __DATE_TIME__


define_type

struct DateTime {
	integer ss;
	integer mm;
	integer hh;
	integer dd;
	integer mn;
	integer yr;
}


define_constant

integer EPOCH_YEAR = 1970;
integer EPOCH_MONTH = 1;
integer EPOCH_DAY = 1;
integer EPOCH_HOUR = 0;
integer EPOCH_MINUTE = 0;
integer EPOCH_SECOND = 0;


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: secondsSinceEpoch
//
// Parameters:
//    none
//
// Returns:
//    slong   -   Seconds since epoch.
//
// Description:
//    Returns the number of seconds that have passed since epoch (00:00:00 1/1/1970).
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function slong secondsSinceEpoch() {
	char currentTime[8];
	DateTime currentDateTime;
	
	currentTime = TIME;  // 'hh:mm:ss'
	
	currentDateTime.hh = atoi(remove_string(currentTime,':',1));
	currentDateTime.mm = atoi(remove_string(currentTime,':',1));
	currentDateTime.ss = atoi(currentTime);
	
	return (daysSinceEpoch() * 24 * 60 * 60) + (currentDateTime.hh * 60 * 60) + (currentDateTime.mm * 60) + currentDateTime.ss;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: daysSinceEpoch
//
// Parameters:
//    none.
//
// Returns:
//    slong   -   Days since epoch.
//
// Description:
//    Returns the number of days that have passed since epoch (00:00:00 1/1/1970).
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function slong daysSinceEpoch() {
	char currentDate[10];
	DateTime currentDateTime;
	slong era;
	long yoe, doy, doe;
	slong y;
	
	AMX_LOG(AMX_DEBUG, "'date-time::daysSinceEpoch'");
	
	currentDate = LDATE; // 'MM/DD/YYYY'
	
	currentDateTime.mn = atoi(remove_string(currentDate,'/',1));
	currentDateTime.dd = atoi(remove_string(currentDate,'/',1));
	currentDateTime.yr = atoi(currentDate);
	
	y = (currentDateTime.yr - (currentDateTime.mn <= 2));
	
	AMX_LOG(AMX_DEBUG, "'date-time::daysSinceEpoch:y = ',itoa(y)");
	
	if(y >= 0) {
		era = (y / 400);
	}
	else {
		era = ((y-399) / 400);
	}
	
	AMX_LOG(AMX_DEBUG, "'date-time::daysSinceEpoch:era = ',itoa(era)");
	
	yoe = type_cast(y - (era * 400));
	
	AMX_LOG(AMX_DEBUG, "'date-time::daysSinceEpoch:yoe = ',itoa(yoe)");
	
	if(currentDateTime.mn > 2) {
		doy = (((153 * (currentDateTime.mn - 3) + 2) / 5) + currentDateTime.dd - 1);
	}
	else {
		doy = (((153 * (currentDateTime.mn + 9) + 2) / 5) + currentDateTime.dd - 1);
	}
	
	AMX_LOG(AMX_DEBUG, "'date-time::daysSinceEpoch:doy = ',itoa(doy)");
	
	doe = ((yoe * 365) + (yoe / 4) - (yoe/100) + doy);
	
	AMX_LOG(AMX_DEBUG, "'date-time::daysSinceEpoch:doe = ',itoa(doe)");
	
	return ((era * type_cast(146097)) + type_cast(doe - 719468));
	
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: isLeapYear
//
// Parameters:
//    integer year   -   The year to test.
//
// Returns:
//    integer   -   boolean value (0==false | 1==true).
//
// Description:
//    Tests if the specified calendar year is a leap year and returns a boolean result.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function integer isLeapYear(integer year) {
	if((year % 4) == 0) {
		return false;
	}
	else if((year % 100) == 0) {
		if((year % 400) == 0) {
			return true;
		}
		else {
			return false;
		}
	}
	else {
		return true;
	}
}


#end_if
