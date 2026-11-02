<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="html" encoding="ISO-8859-1" />
	<xsl:include href="../adminPart.xsl"/>
	<xsl:template match="license">
		<html>
			<head xmlns="http://www.w3.org/1999/xhtml">
				<TITLE>M-Bus:BACnet Gateway</TITLE>
				<link rel="stylesheet" href="../css/wine.css"></link>
				<link rel="shortcut icon" href="/images/32/logo_32.png"></link>
			</head>
			<body>
			<table style="width: 100%">
			<tr>
			<td style="vertical-align: top">
				<xsl:apply-templates mode="admin" select="gateways" />
			</td>
			<td style="width: 100%; vertical-align: top">
			<div class="shadow" >	
			
				<p />
				
				<H2> <img style="vertical-align: middle; border: 0" src="../images/32/document_certificate.png" />
				BACnet Gateway License</H2>

				Licensed for:
				<xsl:value-of select="maxObjects" />
				Objects, 
				
				in use :
				<xsl:value-of select="inUse" />
				
				Serial Number :
				<xsl:value-of select="serialNumber" />
				
				Gateways: 
				<xsl:value-of select="gatewayNames" />

				
				<p></p>
				Device ID:
				<xsl:value-of select="deviceId" />

				<p />
				<div style="color: red; font-weight: bold">
					<xsl:value-of select="message" />
				</div>

				<form action="baccgi" method="post">
				<input name="action" value="3" type="hidden" />
				<input name="gate" value="main" type="hidden" />
					Insert License Text here:
					<textarea style="width: 60%" rows="6" name="license">
					</textarea>
					<p></p>
					<input type='submit' style="width: 160px"
						value='Update License' />
						<img hspace="20" src="/images/spacer.gif" />
						
					<p />
										
						
						
				</form>
			</div>
			</td>
			</tr>
			</table>
			</body>
		</html>
	</xsl:template>



</xsl:stylesheet>
