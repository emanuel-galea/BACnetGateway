// used constants:
var MAX_LEN_HOSTNAME = 256;

var octet = '(?:25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]|[0-9])';
var ip    = '(?:' + octet + '\\.){3}' + octet;
var quad  = '(?:\\[' + ip + '\\])|(?:' + ip + ')';
var ipRE  = new RegExp( '(' + quad + ')' );
//
//
//
function validateIP( value ) {
	if (value.lenght < 1) {
		return false;
	}
    if ( ipRE.test( value ) ) {
      return true;
    } else {
      return false;
    }
  }
//
//
//
function validatePage() {
	var form = document.forms[0];
	if (form == null) {
		return false;
	}
	var elem = document.getElementsByName('hostName')[0];
	if (elem.value.length > MAX_LEN_HOSTNAME) {
		elem.focus();
		alert("Please insert a shorter Hostname!");
		return false;
	} else if (elem.value.length < 1) {
		elem.focus();
		alert("Please insert an Hostname!");
		return false;
	}
// 	ip address
	elem = document.getElementsByName('ipAddress')[0];
	if (validateIP(elem.value) == false) {
		elem.focus();
		alert("Please insert a valid IP-Address!");
		return false;
	}
	
	elem = document.getElementsByName('netMask')[0];
	if (validateIP(elem.value) == false) {
		elem.focus();
		alert("Please insert a valid Subnet Mask!");
		return false;
	} 
	
	elem = document.getElementsByName('gateway')[0];
	if (validateIP(elem.value) == false) {
		elem.focus();
		alert("Please insert a valid Gateway IP Address!");
		return false;
	} 
	
	elem = document.getElementsByName('nameServer')[0];
	if (validateIP(elem.value) == false) {
		elem.focus();
		alert("Please insert a valid nameServer IP Address!");
		return false;
	} 
	
	return true;
}

function validateNumber(elementName, minValue, maxValue) {
	var elem = document.getElementsByName(elementName)[0];
	var elemValue = elem.value;
	for ( var ind = 0; ind < elemValue.length; ind++) {
		switch (elemValue.charAt(ind)) {
		case "0":
		case "1":
		case "2":
		case "3":
		case "4":
		case "5":
		case "6":
		case "7":
		case "8":
		case "9":
			break;
		default:
			alert (elementName + " is not a number" );
			elem.select();
			elem.focus();
			return false;
		}
	}

	var in_num = parseInt(elemValue);
	if ((typeof (in_num) != "number") || isNaN(in_num) || in_num < minValue
			|| in_num > maxValue) {
		alert (elementName + " is out of range. Range: " + minValue +  " to " + maxValue);
		elem.select();
		elem.focus();
		return false;
	} else {
		return true;
	}
} // end of valid_port
