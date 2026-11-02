<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exslt="http://exslt.org/common"
	extension-element-prefixes="exslt">
	<xsl:output method="html" encoding="ISO-8859-1" />


	<xsl:include href="../adminPart.xsl" />
	<xsl:template match="logging">
		<html>
			<head>
				<title>BACnet Gateway - Edit Logging</title>
				<link rel="stylesheet" href="../css/wine.css"></link>
				<link rel="shortcut icon" href="/images/32/logo_32.png"></link>

				<script language="javascript">

				</script>
			</head>
			<body>
				<table style="width: 100%">
					<tr>
						<td style="vertical-align: top">
							<xsl:apply-templates mode="admin" select="gateways" />
						</td>
						<td style="width: 100%; Vertical-align: top">

							<div class="shadow" >

				<H2>
					<img border="0" src="/images/32/text-x-log.png" />
					Logging Configuration
				</H2>
				
				<xsl:if test="error !='0'">
					<div style="margin: auto; color: red; font-weight: bold; ">
						<xsl:value-of select="message" />
					</div>
				</xsl:if>
				<xsl:if test="error ='0'">
					<div style="margin: auto; color: green; font-weight: bold; ">
						<xsl:value-of select="message" />
					</div>
				</xsl:if>


				<p />
				<br />

				<form name="configLog" action="baccgi" method="post">
					<input name="action" value="9" type="hidden" />
					<input name="gate" value="main" type="hidden" />
					<div
						style="width: 700px; padding: 5px;margin: 0px auto;border: 2px; border-style: outset">

						<div class="row">
							<span class="label">Logging Level:</span>
							<span class="formw">
								<xsl:call-template name="selectBox">
									<xsl:with-param name="option1" select="'logLevelOption'" />
									<xsl:with-param name="value1" select="/logging/logLevelValue" />
								</xsl:call-template>
							</span>
						</div>

						<div class="row">
							<span class="label">Logging Entries:</span>
							<span class="formw">
								<input style="width: 50px" max="3" id="index" name="index">
									<xsl:attribute name="value">
                                    <xsl:value-of select="index" />
                                     </xsl:attribute>
								</input>
							</span>
						</div>


						<div class="row">
							<span class="label">IP/UDP Tracer:</span>
							<span class="formw">
								<input style="width: 350px" maxlength="63" id="address" name="address">
									<xsl:attribute name="value">
                                    <xsl:value-of select="address" />
                                     </xsl:attribute>
								</input>
							</span>
						</div>

						<div class="row">
							<span class="label">BACnet Trace:</span>
							<span class="formw">
								<input name="bacnet" type='checkbox'>
									<xsl:if test="bacnet = '1'">
										<xsl:attribute name="checked">
                            <xsl:value-of select="'checked'" />
                            </xsl:attribute>
									</xsl:if>
								</input>
							</span>
						</div>
						<div class="row">
							<span class="label">MBus Trace:</span>
							<span class="formw">
								<input name="trace" type='checkbox'>
									<xsl:if test="trace = '1'">
										<xsl:attribute name="checked">
                            <xsl:value-of select="'checked'" />
                            </xsl:attribute>
									</xsl:if>
								</input>
							</span>
						</div>
						
						<div class="row">
							<span class="label">Enable Auto-Restart:</span>
							<span class="formw">
								<input name="keepOpen" type='checkbox'>
									<xsl:if test="keepOpen = '1'">
										<xsl:attribute name="checked">
                            <xsl:value-of select="'checked'" />
                            </xsl:attribute>
									</xsl:if>
								</input>
							</span>
						</div>


						<img vspace="15" src="/images/spacer.gif" />

					</div>


					<img vspace="20" src="/images/spacer.gif" />
					<p></p>
					<input type='submit' name="save" style="width: 120px" value='Save' />

				</form>
	</div>
	</td>
	</tr>
	</table>
			</body>
		</html>
	</xsl:template>



	<xsl:template name="selectBox">
		<xsl:param name="option1" />
		<xsl:param name="value1" />
		<select size="1" name="{$option1}" id="{$option1}" onchange="changeSelect();">
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
