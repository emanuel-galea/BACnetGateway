<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:template match="root">
		<html>
			<head xmlns="http://www.w3.org/1999/xhtml">
				<title>BACnet Gateway</title>
				<link rel="stylesheet" href="../css/wine.css"></link>
				<link rel="shortcut icon" href="/images/32/logo_32.png"></link>
			</head>
			<body style="margin-top: 10px;">
				<H2>
					<img style="vertical-align: middle; border: 0" src="/images/48/logo_48.png" />
					Kara Systems
				</H2>
				<div class="titleField"> BACnet Gateway </div>
				Version: 2.3.1 
				<br />
					<p />
								Main-Menu
								<p></p>
								<br />
								<div  >
									<xsl:if test="gateways/mbus != '0'">
									<A href="/mbus/mbus.html" >
										<img style="border: 0; width: 100px" src="/images/mbus.gif" />
										MBus Gateway
									</A>
									</xsl:if>
									<xsl:if test="gateways/modbus != '0'">
									<p></p>
									<img vspace="10" src="/images/spacer.gif" />
									<A href="/modbus/modbus.html">
										<img style="border: 0; vertical-align: middle; width: 100px" src="/images/24/modbus.jpg" />
										Modbus Gateway
									</A>
									</xsl:if>
									
									<p />
									<img vspace="30" src="/images/spacer.gif" />
								<!--  	<A href="baccgi?gate=main&amp;action=17">
										<img style="border: 0; " src="../images/24/graphics-viewer.png" />
										Human Machine Interface
									</A>
								-->	
									<br></br>
									<A href="baccgi?gate=main&amp;action=12">
										<img style="border: 0; " src="../images/32/bacnet.png" />
										BACnet Browser
									</A>
									
									<img vspace="20" src="/images/spacer.gif" />
								</div>
								<xsl:if test="admin != '0'">
								<img vspace="45" src="/images/spacer.gif" />
								<img src="/images/32/control_panel2.png" />
								<A href="update?action=6"> Administration</A>
								</xsl:if>
								<p></p>
								<img vspace="100" src="/images/spacer.gif" />
								<div style="position: absolute; bottom: 10; width: 100%;">
									<a href="http://www.karasystems.eu">www.karasystems.eu</a>
								</div>
						
			</body>
		</html>
		</xsl:template>
</xsl:stylesheet>
