<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:template match="logs">
		<html>
			<head xmlns="http://www.w3.org/1999/xhtml">
				<title>M-Bus:BACnet Gateway</title>
				<link rel="stylesheet" href="../css/wine.css"></link>
				<link rel="shortcut icon" href="/images/32/logo_32.png"></link>
				<script src="../js/prototype.js" type="text/javascript"></script>
				<script src="../js/effects.js" type="text/javascript"></script>
				<script src="../js/dragdrop.js" type="text/javascript"></script>
				<script src="../js/popup.js" type="text/javascript"></script>
				<link rel="stylesheet" href="../js/popup.css" type="text/css" />
				
				<script language="javascript">
				//	<![CDATA[
				function export1()     {
				obj = document.getElementById("export1");
				obj.value = '1';
				document.log.submit();
				}
				
				function refresh1()     {
				obj = document.getElementById("export1");
				obj.value = '0';
				document.log.submit();
				}
				
				function clear1()     {
				obj = document.getElementById("action");
				obj.value = '7';
				document.log.submit();
				}
								
				 // ]]>
				 </script>
				
				
			</head>

			<body style="margin-top: 5px;">

			<form name="log" action="baccgi" method="post">
					<input name="gate" value="main" type="hidden" />
					<input name="action" value="6" type="hidden" />
					
					<input name="export1" id='export1' value='0' type="hidden" />
					<span class="titleField">
						<img border="0" src="/images/32/utilities-log_viewer.png" />
						Logging 
					</span>

					<p />
					<img hspace="10" src="/images/spacer.gif" />

			
					<img hspace="10" src="/images/spacer.gif" />
					
					<a href="/cgi/update?action=3">
					<img style="border: 0" src="/images/24/view-refresh-6.png" />Refresh</a>
					
					<img hspace="10" src="/images/spacer.gif" />
					
					<a href="/cgi/update?action=5"><img style="border: 0" src="/images/24/download.png" />Download</a>
					
					<img hspace="10" src="/images/spacer.gif" />
					
					<a href="/cgi/baccgi?gate=main&amp;action=7"><img style="border: 0" src="/images/16/delete.png" /> Clear</a>
					
							
						
					<img hspace="10" src="/images/spacer.gif" />
					
					Sort by:
					<xsl:call-template name="selectBox">
						<xsl:with-param name="option1" select="'sortOption'" />
						<xsl:with-param name="value1" select="/logs/sortValue" />
					</xsl:call-template>
					
						<xsl:variable name="sortby" select="sortBy" />
						<xsl:variable name="sortorder" select="'ascending'" />
					
					<img hspace="40" src="/images/spacer.gif" />
					<A href="/index.html">
						<img style="vertical-align: middle; border: 0" src="/images/32/Backward_Green.png" />
						Main-Menu
					</A>
					<img hspace="10" src="/images/spacer.gif" />
					<A href="/cgi/update?action=6">
						<img style="vertical-align: middle; border: 0" src="/images/32/Backward_Yellow.png" />
						Administration
					</A>	
			
					<p></p>
					<table class='container' style="font-size: small" id="bacnet" border="3">
						<tbody class='container'>
							<td>Time</td>
							<td>Level</td>
							<td>Logger</td>
							<td>Mesage</td>
						</tbody>


						<xsl:for-each select="log">
							<xsl:sort select="*[name(.)=$sortby]"  />
							<tr onMouseOver="this.style.background='#FFFF00';" onMouseOut="this.style.background='#FFFFE0';">
								<td>
									<xsl:value-of select="time" />
								</td>
								<td>
									<xsl:value-of select="level" />
								</td>
								<td>
									<xsl:value-of select="logger" />
								</td>
								<td>
									<xsl:value-of select="message" />
								</td>
								
	
							</tr>
						</xsl:for-each>

					</table>
					<p />
					Total logs:
					<xsl:value-of select="totalLogs" />

					<p />
					
				</form>


			</body>
		</html>
	</xsl:template>

	<xsl:template name="selectBox">
		<xsl:param name="option1" />
		<xsl:param name="value1" />
		<select size="1" name="{$option1}" onchange="changeConnection();">
			<xsl:for-each select="*[name(.)=$option1]">
				<option>
					<xsl:attribute name="value">
							<xsl:value-of select="./@value" />
                    </xsl:attribute>
					<xsl:if test="./@value = $value1">
						<xsl:attribute name="selected">
							<xsl:value-of select="'selected'" />
                         </xsl:attribute>
					</xsl:if>
					<xsl:value-of select="./text()" />
				</option>
			</xsl:for-each>
		</select>
	</xsl:template>



</xsl:stylesheet>
