<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:template match="root">
		<html>
			<head xmlns="http://www.w3.org/1999/xhtml">
				<TITLE>M-Bus BACnet Gateway</TITLE>
				<link rel="stylesheet" href="/css/wine.css"></link>

			</head>
			<body style="margin-top: 50px;">
				<p />
				<h2>
					<img style="vertical-align: middle; border: 0" src="/images/48/logo_48.png" />
					Kara Systems
				</h2>
				<H2>Message</H2>
				<p />
				<xsl:if test="error='true'">
					<div
						style="margin: auto; color: red; font-weight: bold; font-size: large; border-width: 2px; border-style: solid; width: 600px">
						<xsl:value-of select="message" />
					</div>
				</xsl:if>
				<xsl:if test="error='false'">
					<div
						style="margin: auto; color: green; font-weight: bold; font-size: large; border-width: 2px; border-style: solid;width: 600px;">
						<xsl:value-of select="message" /><br></br>
						</div>
				</xsl:if>		
						
				<p></p>
					<div
						style="margin: auto;text-align: left; font-weight: normal; font-size: normal; width: 800px; border-width: 1px; border-style: dotted">
												
						<xsl:for-each select="line">
							<!--<span style="margin-left: 0; border: 1; width: 600px;border-style: solid" > -->
							<xsl:value-of select="data" /><br />
						<!--	</span>-->
						</xsl:for-each>
						
					</div>



				<p />
				<div class="shadow" >
				Reboot the device <p></p>
				<A href="netConfig?reboot=yes"  style="width: 350px; text-align: left">
				<img border="0" src="../images/32/system-reboot.png" />
				Reboot Device now
				</A>
				</div>
			</body>
		</html>
	</xsl:template>



</xsl:stylesheet>
