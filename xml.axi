program_name='xml'

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Include: xml
// 
// Description:
//
//    - This include file provides functions for working with XML (eXtensible Markup Language).
//
// Implementation:
//
//    - Any NetLinx program utilising the xml include file must use either the INCLUDE or #INCLUDE keywords to 
//      include the xml include file within the program. While the INCLUDE and #INCLUDE keywords are both 
//      functionally equivalent the #INCLUDE keyword is recommended only because it is the NetLinx keyword (the INCLUDE
//      keyword is from the earlier Axcess programming language and is included within the NetLinx programming language 
//      for backwards compatibility).
//
//      Note: The NetLinx language is not case-sensitive when it comes to keywords. The convention used in this project
//      is for keywords to be written in lower case (e.g., include instead of INCLUDE).
//
//      E.g:
//
//          define_program 'XML Demo'
//
//          #include 'xml'
//
// Usage:
//
//    - See function header comments below for usage details.
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#if_not_defined __XML__
#define __XML__


#include 'string'


define_constant

integer XML_MAX_CHARS = 20000;	// Adjust if necessary. Note that 100000 chars crashes NSX if you try to add a char array this big to the watch window


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: xmlString
//
// Parameters:
//    char elementName[]   -   Name of element.
//    char content[]       -   Content for the element.
//
// Returns:
//    char[XML_MAX_CHARS]   -   XML formatted string (e.g., '<element>content</element>').
//
// Description:
//    Creates an XML formatted string using the provided elemenet name and contents.
//    Assumes that element name and content are correctly formatted (e.g., no spaces, left angle brackets, right angle 
//    brackets, etc,, in element name).
//    The content may itself already be an XML formatted string so this function could be called repeatedly to build a 
//    complete XML string. E.g, to build the following XML string:
//
//    <country>
//        <name>Australia</name>
//        <state>
//            <name>Queensland</name>
//            <prefix>QLD</prefix>
//            <city>
//                <name>Brisbane</name>
//                <name>Gold Coast></name>
//            </city>
//        </state>
//        <state>
//            <name>New South Wales</name>
//            <prefix>NSW</prefix>
//            <city>
//                <name>Sydney</name>
//            </city>
//        </state>
//    </country>
//
//    You could write the following code:
//
//    stack_var sXml[XML_MAX_CHARS]
//    stack_var sXmlTemp[XML_MAX_CHARS]
//
//    sXmlTemp = xmlString('name','New South Wales');
//    sXmlTemp = "sXmlTemp,xmlString('prefix','NSW')";
//    sXmlTemp = "sXmlTemp,xmlString('city',xmlString('name','Sydney'));
//    sXmlTemp = xmlString('state',sXmlTemp);
//
//    sXml = sXmlTemp;
//
//    sXmlTemp = xmlString('name','Queensland');
//    sXmlTemp = "sXmlTemp,xmlString('prefix','QLD')";
//    sXmlTemp = "sXmlTemp,xmlString('city',"xmlString('name','Brisbane'),xmlString('name','Gold Coast')")";
//    sXmlTemp = xmlString('state',sXmlTemp);
//
//    sXml = "sXml,sXmlTemp";
//
//    sXml = "xmlString('name','Australia'),sXml";
//    sXml	= xmlString('country',sXml);
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[XML_MAX_CHARS] xmlString (char elementName[], char content[]) {
	return "'<',elementName,'>',content,'</',elementName,'>'"
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: xmlGetElement
//
// Parameters:
//    char xml[]           -   XML formatted character string.
//    char elementName[]   -   Name of element to filter search.
//    char attribName[]    -   Name of attribute to filter search.
//    char attribValue[]   -   Value of attribute to filter search.
//
// Returns:
//    char[XML_MAX_CHARS]   -   Element including opening and closing XML tags.
//
// Description:
//    Returns an element from an XML string.
//    An element name can be provided to refine the search but is optional. If the element name is left out the 1st 
//    element in the XMl string will be returned. If the element name is provided the 1st element in the XML string with a 
//    matching name will be returned.
//    An attribute name/value pair can also be provided to further refine the search but is also optional.
//
//    Usage:
//        If a variable (called xmlBooks) contained the following XML data:
//
//            <catalog>
//                <book id="bk101">
//                    <author>Gambardella, Matthew</author>
//                    <title>XML Developer's Guide</title>
//                    <genre>Computer</genre>
//                    <price>44.95</price>
//                    <publish_date>2000-10-01</publish_date>
//                    <description>An in-depth look at creating applications 
//                    with XML.</description>
//                </book>
//                <book id="bk102">
//                    <author>Ralls, Kim</author>
//                    <title>Midnight Rain</title>
//                    <genre>Fantasy</genre>
//                    <price>5.95</price>
//                    <publish_date>2000-12-16</publish_date>
//                    <description>A former architect battles corporate zombies, 
//                    an evil sorceress, and her own childhood to become queen 
//                    of the world.</description>
//                </book>
//            <catalog>
//
//        Calling xmlGetElement(xmlBooks,'','','') would return:
//
//            <catalog>
//                <book id="bk101">
//                    <author>Gambardella, Matthew</author>
//                    <title>XML Developer's Guide</title>
//                    <genre>Computer</genre>
//                    <price>44.95</price>
//                    <publish_date>2000-10-01</publish_date>
//                    <description>An in-depth look at creating applications 
//                    with XML.</description>
//                </book>
//                <book id="bk102">
//                    <author>Ralls, Kim</author>
//                    <title>Midnight Rain</title>
//                    <genre>Fantasy</genre>
//                    <price>5.95</price>
//                    <publish_date>2000-12-16</publish_date>
//                    <description>A former architect battles corporate zombies, 
//                    an evil sorceress, and her own childhood to become queen 
//                    of the world.</description>
//                </book>
//            <catalog>
//
//        Calling xmlGetElement(xmlBooks,'book','','') would return:
//
//            <book id="bk101">
//                <author>Gambardella, Matthew</author>
//                <title>XML Developer's Guide</title>
//                <genre>Computer</genre>
//                <price>44.95</price>
//                <publish_date>2000-10-01</publish_date>
//                <description>An in-depth look at creating applications 
//                with XML.</description>
//            </book>
//
//        Calling xmlGetElement(xmlBooks,'book','id','bk102') would return:
//
//            <book id="bk102">
//                <author>Ralls, Kim</author>
//                <title>Midnight Rain</title>
//                <genre>Fantasy</genre>
//                <price>5.95</price>
//                <publish_date>2000-12-16</publish_date>
//                <description>A former architect battles corporate zombies, 
//                an evil sorceress, and her own childhood to become queen 
//                of the world.</description>
//            </book>
//
//	Calling xmlGetElement(xmlBooks,'book','id','bk103') would return nothing
//
//	Calling xmlGetElement(xmlBooks,'chapter','','') would return nothing
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[XML_MAX_CHARS] xmlGetElement (char xml[], char elementName[], char attribName[], char attribValue[]) {
	stack_var integer idxOpenTag;
	stack_var integer idxCloseTag;
	stack_var integer idxOpenTagChild;
	stack_var integer idxOpenTagRightBracket;
	stack_var integer idxCloseTagRightBracket;
	stack_var char leftBracket[1];
	stack_var char rightBracket[1];
	stack_var char xmlElement[XML_MAX_CHARS];
	stack_var char elementNameTemp[100];
	stack_var integer match;

	match = false;
	leftBracket = "'<'";
	rightBracket = "'>'";

	if(elementName == '')
		elementNameTemp = xmlGetName(xml);
	else
		elementNameTemp = elementName;

	idxOpenTag = find_string(xml,"'<',elementNameTemp",1);

	while(!match) {
		// search for open tag
		if(idxOpenTag == 0)
			return '';

		while( (find_string(xml,"'<',elementNameTemp,'>'",idxOpenTag) != idxOpenTag) && (find_string(xml,"'<',elementNameTemp,' '",idxOpenTag) != idxOpenTag) ) {
			idxOpenTag = find_string(xml,"'<',elementNameTemp",idxOpenTag+1);
			if(idxOpenTag == 0)
				return '';
		}

		// search for close tag
		idxCloseTag = find_string(xml,"'</',elementNameTemp,'>'",idxOpenTag);
		if(idxCloseTag == 0) // poorly formed XML (XML rules state that all elements must have a closing tag)
			return '';

		// check for other opening tags between the opening tag and closing tage we have found (child elements with matching names)
		idxOpenTagChild = find_string(xml,"'<',elementNameTemp",idxOpenTag+1);

		while(idxOpenTagChild) {
			while( (find_string(xml,"'<',elementNameTemp,'>'",idxOpenTagChild) != idxOpenTagChild) && (find_string(xml,"'<',elementNameTemp,' '",idxOpenTagChild) != idxOpenTagChild) ) {
				idxOpenTagChild = find_string(xml,"'<',elementNameTemp",idxOpenTagChild+1);
				if((idxOpenTagChild == 0) || (idxOpenTagChild > idxCloseTag))	// want to break out of both whiles but we can't so we'll break out here and then again after this while
					break;
			}

			if((idxOpenTagChild == 0) || (idxOpenTagChild > idxCloseTag))	// need to break again
				break;

			idxCloseTag = find_string(xml,"'</',elementNameTemp,'>'",idxCloseTag+1);
			if(idxCloseTag == 0) // poorly formed XML (XML rules state that all elements must have a closing tag)
				return '';

			idxOpenTagChild = find_string(xml,"'<',elementNameTemp",idxOpenTagChild+1);
		}

		// we made it to here so we know we have an element with a matching name (and child elements with matching names haven't caused us issues)
		idxCloseTagRightBracket = find_string(xml,"'>'",idxCloseTag);
		xmlElement = mid_string(xml,idxOpenTag,(idxCloseTagRightBracket-idxOpenTag+1));
		if(attribName == '') {
			match = true;
		}
		else if((attribName != '') && (attribValue != '')) {
			stack_var char xmlOpenTag[XML_MAX_CHARS];
			stack_var char attributeValue[200];
			stack_var char rightAngleBracket[1];

			idxOpenTagRightBracket = FIND_STRING(xmlElement,"'>'",1);
			if(!(idxOpenTag && idxOpenTagRightBracket))
				return '';

			xmlOpenTag = MID_STRING(xmlElement,1,idxOpenTagRightBracket);
			if(find_string(xmlOpenTag,"' ',attribName,'='",1)) {
				remove_string(xmlOpenTag,"' ',attribName,'='",1);
				if(xmlOpenTag[1] == '"') {	// value is a string
					remove_string(xmlOpenTag,"'"'",1);
					attributeValue = remove_string(xmlOpenTag,"'"'",1);
					attributeValue = left_string(attributeValue,(length_string(attributeValue)-1));
				} else { // value is a number, might be followed by a space (' ') or a right angle bracket ('>')
					if(find_string(xmlOpenTag,"' '",1)) {
						attributeValue = remove_string(xmlOpenTag,"' '",1);
					} else {
						attributeValue = remove_string(xmlOpenTag,"'>'",1);
					}
					attributeValue = left_string(attributeValue,(length_string(attributeValue)-1));
				}

				if(attribValue == attributeValue) {
					match = true;
				}
				else {
					idxOpenTag = find_string(xml,"'<',elementNameTemp",idxOpenTag+1);
				}
			}
			else {
				idxOpenTag = find_string(xml,"'<',elementNameTemp",idxOpenTag+1);
			}
		}
		else {
			idxOpenTag = find_string(xml,"'<',elementNameTemp",idxOpenTag+1);
			//idxOpenTag = find_string(xml,"'<',elementNameTemp",idxCloseTagRightBracket+1);
		}
	}

	return xmlElement;
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: xmlGetContent
//
// Parameters:
//    char xml[]           -   XML formatted character string.
//    char elementName[]   -   Name of element to filter search.
//    char attribName[]    -   Name of attribute to filter search.
//    char attribValue[]   -   Value of attribute to filter search.
//
// Returns:
//    char[XML_MAX_CHARS]   -   Content of element.
//
// Description:
//    Returns the content of an element in an XML string. An element name can be provided to refine the search but is 
//    optional. If the element name is left out the content of the 1st element in the XML string will be returned. If the 
//    element name is provided the content of the 1st element in the XML string with a matching name will be returned. An 
//    attribute name/value pair can also be provided to further refine the search but is also optional.
//
//    Usage:
//        If a variable (called xmlBooks) contained the following XML data:
//
//            <catalog>
//                <book id="bk101">
//                    <author>Gambardella, Matthew</author>
//                    <title>XML Developer's Guide</title>
//                    <genre>Computer</genre>
//                    <price>44.95</price>
//                    <publish_date>2000-10-01</publish_date>
//                    <description>An in-depth look at creating applications 
//                    with XML.</description>
//                </book>
//                <book id="bk102">
//                    <author>Ralls, Kim</author>
//                    <title>Midnight Rain</title>
//                    <genre>Fantasy</genre>
//                    <price>5.95</price>
//                    <publish_date>2000-12-16</publish_date>
//                    <description>A former architect battles corporate zombies, 
//                    an evil sorceress, and her own childhood to become queen 
//                    of the world.</description>
//                </book>
//            <catalog>
//
//        Calling xmlGetContent(xmlBooks,'','','') would return:
//
//            <book id="bk101">
//                <author>Gambardella, Matthew</author>
//                <title>XML Developer's Guide</title>
//                <genre>Computer</genre>
//                <price>44.95</price>
//                <publish_date>2000-10-01</publish_date>
//                <description>An in-depth look at creating applications 
//                with XML.</description>
//            </book>
//            <book id="bk102">
//                <author>Ralls, Kim</author>
//                <title>Midnight Rain</title>
//                <genre>Fantasy</genre>
//                <price>5.95</price>
//                <publish_date>2000-12-16</publish_date>
//                <description>A former architect battles corporate zombies, 
//                an evil sorceress, and her own childhood to become queen 
//                of the world.</description>
//            </book>
//
//        Calling xmlGetContent(xmlBooks,'book','','') would return:
//
//            <author>Gambardella, Matthew</author>
//            <title>XML Developer's Guide</title>
//            <genre>Computer</genre>
//            <price>44.95</price>
//            <publish_date>2000-10-01</publish_date>
//            <description>An in-depth look at creating applications 
//            with XML.</description>
//
//        Calling xmlGetContent(xmlBooks,'book','id','bk102') would return:
//
//            <author>Ralls, Kim</author>
//            <title>Midnight Rain</title>
//            <genre>Fantasy</genre>
//            <price>5.95</price>
//            <publish_date>2000-12-16</publish_date>
//            <description>A former architect battles corporate zombies, 
//            an evil sorceress, and her own childhood to become queen 
//            of the world.</description>
//
//        Calling xmlGetContent(xmlBooks,'book','id','bk103') would return nothing
//
//        Calling xmlGetContent(xmlBooks,'chapter','','') would return nothing
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[XML_MAX_CHARS] xmlGetContent (char xml[], char elementName[], char attribName[], char attribValue[]) {
	stack_var char xmlElement[XML_MAX_CHARS];
	stack_var char content[XML_MAX_CHARS];
	stack_var integer idxRightAngleBracket;
	stack_var integer idxCloseTag;
	stack_var char elementNameTemp[200];
	stack_var integer idxOpenTagChild;

	if(elementName == '')
		elementNameTemp = xmlGetName(xml);
	else
		elementNameTemp = elementName

	xmlElement = xmlGetElement(xml,elementNameTemp,attribName,attribValue);
	if(xmlElement == '')
		return '';

	idxRightAngleBracket = find_string(xmlElement,"'>'",1);
	if(!idxRightAngleBracket)
		return '';

	// search for close tag
	idxCloseTag = find_string(xmlElement,"'</',elementNameTemp,'>'",1);
	if(idxCloseTag == 0) // poorly formed XML (XML rules state that all elements must have a closing tag)
		return '';

	// check for other opening tags between the opening tag and closing tage we have found (child elements with matching names)
	idxOpenTagChild = find_string(xmlElement,"'<',elementNameTemp",2);
	while(idxOpenTagChild) {
		while( (find_string(xmlElement,"'<',elementNameTemp,'>'",idxOpenTagChild) != idxOpenTagChild) && (find_string(xmlElement,"'<',elementNameTemp,' '",idxOpenTagChild) != idxOpenTagChild) ) {
			idxOpenTagChild = find_string(xmlElement,"'<',elementNameTemp",idxOpenTagChild+1);
			if((idxOpenTagChild == 0) || (idxOpenTagChild > idxCloseTag))	// want to break out of both whiles but we can't so we'll break out here and then again after this while
				break;
		}

		if((idxOpenTagChild == 0) || (idxOpenTagChild > idxCloseTag))	// need to break again
			break;

		idxCloseTag = find_string(xmlElement,"'</',elementNameTemp,'>'",idxCloseTag+1);
		if(idxCloseTag == 0) // poorly formed XML (XML rules state that all elements must have a closing tag)
			return '';

		idxOpenTagChild = find_string(xmlElement,"'<',elementNameTemp",idxOpenTagChild+1);
	}

	content = MID_STRING(xmlElement,
	                     (idxRightAngleBracket+1),
	                     (idxCloseTag-idxRightAngleBracket-1));

	return content;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: xmlGetName
//
// Parameters:
//    char xml[]   -   XML formatted character string.
//
// Returns:
//    char[200]   -   Name of element.
//
// Description:
//    Returns the name of the 1st element in an XML string.
//
//    Usage:
//        If a variable (called xmlBooks) contained the following XML data:
//
//            <catalog>
//                <book id="bk101">
//                    <author>Gambardella, Matthew</author>
//                    <title>XML Developer's Guide</title>
//                    <genre>Computer</genre>
//                    <price>44.95</price>
//                    <publish_date>2000-10-01</publish_date>
//                    <description>An in-depth look at creating applications 
//                    with XML.</description>
//                </book>
//                <book id="bk102">
//                    <author>Ralls, Kim</author>
//                    <title>Midnight Rain</title>
//                    <genre>Fantasy</genre>
//                    <price>5.95</price>
//                    <publish_date>2000-12-16</publish_date>
//                    <description>A former architect battles corporate zombies, 
//                    an evil sorceress, and her own childhood to become queen 
//                    of the world.</description>
//                </book>
//            <catalog>
//
//        Calling xmlGetName(xmlBooks) would return:
//
//            catalog
//
//        If a variable (called xmlBooks) contained the following XML data:
//
//            <book id="bk101">
//                <author>Gambardella, Matthew</author>
//                <title>XML Developer's Guide</title>
//                <genre>Computer</genre>
//                <price>44.95</price>
//                <publish_date>2000-10-01</publish_date>
//                <description>An in-depth look at creating applications 
//                with XML.</description>
//            </book>
//            <book id="bk102">
//                <author>Ralls, Kim</author>
//                <title>Midnight Rain</title>
//                <genre>Fantasy</genre>
//                <price>5.95</price>
//                <publish_date>2000-12-16</publish_date>
//                <description>A former architect battles corporate zombies, 
//                an evil sorceress, and her own childhood to become queen 
//                of the world.</description>
//            </book>
//
//        Calling xmlGetName(xmlBooks) would return:
//
//            book
//
//        If a variable (called xmlBooks) contained the following XML data:
//
//            <author>Gambardella, Matthew</author>
//            <title>XML Developer's Guide</title>
//            <genre>Computer</genre>
//            <price>44.95</price>
//            <publish_date>2000-10-01</publish_date>
//            <description>An in-depth look at creating applications 
//            with XML.</description>
//
//        Calling xmlGetName(xmlBooks) would return:
//
//            author
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[200] xmlGetName (char xml[]) {
	stack_var integer idxOpenTag;
	stack_var char elementName[50];
	stack_var integer idx;

	idxOpenTag = FIND_STRING(xml,"'<'",1);

	if(!idxOpenTag)
		return '';

	idx = idxOpenTag+1;
	while((xml[idx] != ' ') and (xml[idx] != '>')) {
		idx++;
	}

	elementName = MID_STRING(xml,idxOpenTag+1,(idx-idxOpenTag-1));

	return elementName;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: xmlGetAttribute
//
// Parameters:
//    char xml[]                 -   XML formatted character string.
//    char elementName[]         -   XML element tag identifier.
//    char attribName[]          -   Name of attribute to obtain value of.
//    char attribNameFilter[]    -   Name of attribute to filter search.
//    char attribValueFilter[]   -   Value of attribute to filter search.
//
// Returns:
//    char[50]   -   Value of attribute.
//
// Description:
//    Returns the value of a specified attribute from an element in an XML string. An element name can be provided to 
//    refine the search but is optional. If the element name is left out the 1st element in the XML string will be used. If 
//    the element name is provided the 1st element in the XML string with a matching name will be used. An attribute 
//    name/value pair can also be provided to further refine the search but is also optional.
//
//    Usage:
//        If a variable (called xmlBooks) contained the following XML data:
//
//            <catalog>
//                <book id="bk101" isbn-13="9780843953893">
//                    <author>Gambardella, Matthew</author>
//                    <title>XML Developer's Guide</title>
//                    <genre>Computer</genre>
//                    <price>44.95</price>
//                    <publish_date>2000-10-01</publish_date>
//                    <description>An in-depth look at creating applications 
//                    with XML.</description>
//                </book>
//                <book id="bk102">
//                    <author>Ralls, Kim</author>
//                    <title>Midnight Rain</title>
//                    <genre>Fantasy</genre>
//                    <price>5.95</price>
//                    <publish_date>2000-12-16</publish_date>
//                    <description>A former architect battles corporate zombies, 
//                    an evil sorceress, and her own childhood to become queen 
//                    of the world.</description>
//                </book>
//            <catalog>
//
//        Calling xmlGetAttribute(xmlBooks,'book','','','') would return:
//
//            <catalog>
//                <book id="bk101">
//                    <author>Gambardella, Matthew</author>
//                    <title>XML Developer's Guide</title>
//                    <genre>Computer</genre>
//                    <price>44.95</price>
//                    <publish_date>2000-10-01</publish_date>
//                    <description>An in-depth look at creating applications 
//                    with XML.</description>
//                </book>
//                <book id="bk102">
//                    <author>Ralls, Kim</author>
//                    <title>Midnight Rain</title>
//                    <genre>Fantasy</genre>
//                    <price>5.95</price>
//                    <publish_date>2000-12-16</publish_date>
//                    <description>A former architect battles corporate zombies, 
//                    an evil sorceress, and her own childhood to become queen 
//                    of the world.</description>
//                </book>
//            <catalog>
//
//        Calling xmlGetAttribute(xmlBooks,'book','','') would return:
//
//            <book id="bk101">
//                <author>Gambardella, Matthew</author>
//                <title>XML Developer's Guide</title>
//                <genre>Computer</genre>
//                <price>44.95</price>
//                <publish_date>2000-10-01</publish_date>
//                <description>An in-depth look at creating applications 
//                with XML.</description>
//            </book>
//
//        Calling xmlGetAttribute(xmlBooks,'book','id','bk102') would return:
//
//            <book id="bk102">
//                <author>Ralls, Kim</author>
//                <title>Midnight Rain</title>
//                <genre>Fantasy</genre>
//                <price>5.95</price>
//                <publish_date>2000-12-16</publish_date>
//                <description>A former architect battles corporate zombies, 
//                an evil sorceress, and her own childhood to become queen 
//                of the world.</description>
//            </book>
//
//        Calling xmlGetAttribute(xmlBooks,'book','id','bk103') would return nothing
//
//        Calling xmlGetAttribute(xmlBooks,'chapter','','') would return nothing
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[50]    xmlGetAttribute (char xml[], char elementName[], char attribName[], char attribNameFilter[], char attribValueFilter[]) {
	stack_var integer idxRightAngleBracket;
	stack_var char xmlOpenTag[500];
	stack_var char attributeValue[200];
	stack_var char xmlElement[XML_MAX_CHARS];

	if((xml == '') || (attribName == ''))
		return '';

	xmlElement = xmlGetElement(xml, elementName, attribNameFilter, attribValueFilter);

	if(xmlElement == '')
		return '';

	if(attribName == '')
		return xmlElement;

	idxRightAngleBracket = FIND_STRING(xmlElement,"'>'",1);

	if(!idxRightAngleBracket)
		return '';

	xmlOpenTag = MID_STRING(xmlElement,1,idxRightAngleBracket);	// we can get away with this because the trailing delimiter is only one character

	if(!find_string(xmlOpenTag,"' ',attribName,'='",1))
		return '';

	remove_string(xmlOpenTag,"' ',attribName,'='",1);
	
	if(xmlOpenTag[1] == '"') {	// value is a string
		remove_string(xmlOpenTag,"'"'",1);
		attributeValue = remove_string(xmlOpenTag,"'"'",1);
		attributeValue = left_string(attributeValue,(length_string(attributeValue)-1));
	} else { // value is a number, might be followed by a space (' ') or a right angle bracket ('>')
		if(find_string(xmlOpenTag,"' '",1)) {
			attributeValue = remove_string(xmlOpenTag,"' '",1);
		} else {
			attributeValue = remove_string(xmlOpenTag,"'>'",1);
		}
		attributeValue = left_string(attributeValue,(length_string(attributeValue)-1));
	}

	return attributeValue;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: xmlParseElement
//
// Parameters:
//    char xml[]           -   XML formatted character string.
//    char elementName[]   -   Name of element to filter search.
//    char attribName[]    -   Name of attribute to filter search.
//    char attribValue[]   -   Value of attribute to filter search.
//
// Returns:
//    char[XML_MAX_CHARS]   -   Element including opening and closing XML tags.
//
// Description:
//    Returns an element in an XML string. An element name can be provided to refine the search but is optional. If the 
//    element name is left out the 1st element in the XMl string will be returned. If the element name is provided the 1st 
//    element in the XML string with a matching name will be returned. An attribute name/value pair can also be provided to 
//    further refine the search but is also optional. The returned element is also removed from the XML string.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[XML_MAX_CHARS] xmlParseElement (char xml[], char elementName[], char attribName[], char attribValue[]) {
	stack_var char xmlElement[XML_MAX_CHARS];

	if(elementName == '')
		elementName = xmlGetName(xml);

	xmlElement = xmlGetElement(xml,elementName,attribName,attribValue);

	delete_string(xml,xmlElement);

	return xmlElement;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: xmlParseContent
//
// Parameters:
//    char xml[]           -   XML formatted character string.
//    char elementName[]   -   Name of element to filter search.
//    char attribName[]    -   Name of attribute to filter search.
//    char attribValue[]   -   Value of attribute to filter search.
//
// Returns:
//    char[XML_MAX_CHARS]   -   Content of element.
//
// Description:
//    Returns the content of an element in an XML string. An element name can be provided to refine the search but is 
//    optional. If the element name is left out the content of the 1st element in the XML string will be returned. If the 
//    element name is provided the content of the 1st element in the XML string with a matching name will be returned. An 
//    attribute name/value pair can also be provided to further refine the search but is also optional. The returned 
//    content is also removed from the XML string.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[XML_MAX_CHARS] xmlParseContent (char xml[], char elementName[], char attribName[], char attribValue[]) {
	stack_var char xmlElement[XML_MAX_CHARS];
	stack_var char xmlElementContentRemoved[XML_MAX_CHARS];
	stack_var char content[XML_MAX_CHARS];

	if(elementName == '')
		elementName = xmlGetName(xml);

	xmlElement = xmlGetElement(xml,elementName,attribName,attribValue);

	content = xmlGetContent(xmlElement,elementName,attribName,attribValue);

	xmlElementContentRemoved = xmlElement;
	delete_string(xmlElementContentRemoved,content);
	replace_string(xml,xmlElement,xmlElementContentRemoved);

	return content;
}


#end_if
