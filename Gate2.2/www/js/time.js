var in_time_interval  = 60000;    // request interval in milliseconds
var ds_time_request   = null;     // ajax request object
var ds_time_request_2 = null      // ajax request object
var in_time           = 0;	  // server time


function m_init_time() 
{ 
    if (typeof XMLHttpRequest != 'undefined') {
        ds_time_request = new XMLHttpRequest();
    }
    if (!ds_time_request) {
        try {
            ds_time_request  = new ActiveXObject("Msxml2.XMLHTTP");
        } catch(e) {
            try {
                ds_time_request  = new ActiveXObject("Microsoft.XMLHTTP");
            } catch(e) {
                ds_time_request  = null;
            }
        }
    }

    //-------------------------------
    // update time localy
    // each second:
    //-------------------------------
    window.setInterval("m_update_local()", 1000 );
}

            
function m_time_request() 
{
    if (ds_time_request) {
        ds_time_request.open("GET", "/date.cgi", true);
        ds_time_request.onreadystatechange = m_cb_time_request;
        ds_time_request.send("");
    }
}   


function m_cb_time_request()
{
    if ( ds_time_request.readyState == 4 ) {
        in_time = parseInt(ds_time_request.responseText)*1000;
        m_update_time();

        //-------------------------------
        // do another request 
        // after in_time_interval
        //-------------------------------
        window.setTimeout("m_time_request()", in_time_interval);
    }
}

function m_update_local()
{
    in_time = in_time + 1000;
    m_update_time();
}            


function m_update_time()
{
    var ds_elem = document.getElementById("wsp_time");
    var ds_time = new Date( in_time );
    ds_elem.innerHTML = ds_time.toLocaleString();
} // end of m_update_time

function m_sync_time()
{
    var ds_time = new Date();
    var str_date = "";
    
    // we will create a format like this:
    // MMDDhhmmYYYY.ss
    str_date += m_fill_2_string( ds_time.getUTCMonth() + 1 );
    str_date += m_fill_2_string( ds_time.getUTCDate() );
    str_date += m_fill_2_string( ds_time.getUTCHours() );
    str_date += m_fill_2_string( ds_time.getUTCMinutes() );
    str_date += ""  + ds_time.getUTCFullYear();
    str_date += "." + m_fill_2_string( ds_time.getUTCSeconds() );
    
    m_set_data( str_date ); 
}

function m_fill_2_string( in_number )
{
    if ( in_number < 0 ) {
    	return "00";
    }
    if ( in_number < 10 ) {
    	return ("0" + in_number);
    }
    if ( in_number < 99 ) {
    	return ("" + in_number);
    } else {
    	return "00";
    }
}

function m_set_data( str_date ) 
{ 
    if (typeof XMLHttpRequest != 'undefined') {
        ds_time_request_2 = new XMLHttpRequest();
    }
    if (!ds_time_request_2) {
        try {
            ds_time_request_2  = new ActiveXObject("Msxml2.XMLHTTP");
        } catch(e) {
            try {
                ds_time_request_2  = new ActiveXObject("Microsoft.XMLHTTP");
            } catch(e) {
                ds_time_request_2  = null;
            }
        }
    }
    if (ds_time_request_2) {
        ds_time_request_2.open("POST", "/date.cgi?date=" + str_date, true);
        ds_time_request_2.onreadystatechange = m_cb_time_request_2;
        ds_time_request_2.send("");
    }
}   


function m_cb_time_request_2()
{
    if ( ds_time_request_2.readyState == 4 ) {
    	if ( ds_time_request_2.status == 200 ) {
            m_time_request();
    	} else {
    	    alert( txt_error_tsync );
    	}
    }
}

