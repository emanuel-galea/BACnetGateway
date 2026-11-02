<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exslt="http://exslt.org/common"
	extension-element-prefixes="exslt">
	<xsl:output method="html" encoding="ISO-8859-1" />

	<xsl:include href="../adminPart.xsl" />

	<xsl:template match="root">
		<html>
			<head>
				<TITLE>The BACnet Gateway</TITLE>
				<link rel="stylesheet" href="/css/wine.css"></link>
				<link rel="shortcut icon" href="/images/32/logo_32.png"></link>

				<script language="javascript">
					function reboot() {
					if (confirm ("Do you
					really
					want to reboot the device ?")) {
					document.forms[0].reboot.value =
					"yes";
					document.indexForm.submit();
					}
					}

				</script>
			</head>


			<body style="margin-top: 5px;">
				<table style="width: 100%">
					<tr>
						<td style="vertical-align: top">
							<xsl:apply-templates mode="admin" select="gateways" />
						</td>
						<td style="width: 100%; Vertical-align: top">


							<xsl:if test="error='1'">
								<div class="shadow"
									style="margin: auto; color: red; font-weight: bold; font-size: large; border-width: 2px; border-style: solid; width: 600px">
									<xsl:value-of select="message" />
								</div>

							</xsl:if>
							<xsl:if test="error='0'">
								<div class="shadow"
									style="margin: auto; color: green; font-weight: bold; font-size: large; border-width: 2px; border-style: solid;width: 600px;">
									<xsl:value-of select="message" />
									<br></br>
								</div>
							</xsl:if>

							<xsl:if test="rebootMessage = '1'">
								<div class="shadow">
									Do you really want to reboot the device ?
									<p></p>
									<A href="netConfig?reboot=yes" style="width: 300px; text-align: left">
										<img border="0" src="../images/32/system-reboot.png" />
										Reboot Device now
									</A>
								</div>
							</xsl:if>



						</td>
						
						
					</tr>
					<tr>
							<td>
								
							</td>
						</tr>
				</table>
				
			</body>
		</html>
	</xsl:template>

</xsl:stylesheet>
