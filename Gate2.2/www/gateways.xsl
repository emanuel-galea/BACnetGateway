<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="html" encoding="ISO-8859-1" />

	<xsl:include href="../adminPart.xsl" />
	<xsl:template name="enableGateways" match="root">
		<html>
			<head xmlns="http://www.w3.org/1999/xhtml">
				<TITLE>Kara BACnet Gateway</TITLE>
				<link rel="stylesheet" href="../css/wine.css"></link>
				<link rel="shortcut icon" href="/images/32/logo_32.png"></link>

			</head>
			<body>
				<table style="width: 100%">
					<tr>
						<td style="vertical-align: top">
							<xsl:apply-templates select="*" mode="admin" />
						</td>
						<td style="width: 100%; Vertical-align: top">
							<div class="shadow">
								<p />
								<H2>
									<img src="../images/24/fifteen_pieces.png" />
									Enable Gateways
								</H2>

								<p />
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

								<form method="get" action='baccgi'>
									<input name="action" value="11" type="hidden" />
									<input name="gate" value="main" type="hidden" />
									<table class='container' id="bacnet" cellpadding="8"
										cellspacing="8" width="30%">
										<tbody class='container'>
											<td>
												Gateway Name
							</td>
											<td>Enable</td>
										</tbody>
										<xsl:for-each select="/root/gateways/child::*">

											<tr>
												<td>
													<xsl:value-of select="name()" />
												</td>

												<td>
													<input type='checkbox'>
														<xsl:attribute name="name">_inst_<xsl:value-of
															select="position()-1" /></xsl:attribute>
														<xsl:if test=".='1'">
															<xsl:attribute name="checked">
										<xsl:value-of select="'checked'" />
			                         </xsl:attribute>
														</xsl:if>
													</input>
												</td>

											</tr>
										</xsl:for-each>
									</table>
									<p />
									<input type='submit' style="width: 120px" name="save"
										value='Save' />
								</form>
							</div>
						</td>
					</tr>
				</table>

			</body>
		</html>
	</xsl:template>



</xsl:stylesheet>
