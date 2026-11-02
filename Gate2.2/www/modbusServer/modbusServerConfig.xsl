<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="html" encoding="ISO-8859-1" />

	<xsl:include href="../adminPart.xsl" />
	<xsl:template match="root">
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
							<xsl:apply-templates mode="admin" select="gateways" />
						</td>
						<td style="width: 100%; Vertical-align: top">
							<div class="shadow">
								<p />
								<h2>
									<img style="vertical-align: middle; border: 0" src="/images/48/logo_48.png" />
									Kara Systems
								</h2>

								<H2>Modbus Server Configuration</H2>

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


								<form method="GET" action='baccgi'>
									<input name="action" value="1" type="hidden" />
									<input name="gate" value="modbusServer" type="hidden" />
									<div
										style="width: 700px; padding: 5px;margin: 0px auto;border: 2px; border-style: outset">

										<div class="row" id="d_port" style="visibility: display;">
											<span class="label">TCP-Port: </span>
											<span class="formw">
												<input style="width: 60px" maxLength="5" id="port"
													name="port">
													<xsl:attribute name="value">
                                    <xsl:value-of select="port" />
                                </xsl:attribute>
												</input>
											</span>
										</div>

										<div class="row" id="d_serialPort" style="visibility: display;">
											<span class="label">Serial Port:</span>
											<span class="formw">
												<xsl:call-template name="selectBox">
													<xsl:with-param name="option1" select="'serialPortOption'" />
													<xsl:with-param name="value1" select="serialPortValue" />
												</xsl:call-template>
											</span>
										</div>
										<div class="row">
											<span class="label">Slave Address:</span>
											<span class="formw">
												<input style="width: 60px" maxLength="3" id="intParam1"
													name="intParam1">
													<xsl:attribute name="value">
                                    <xsl:value-of select="intParam1" />
                                     </xsl:attribute>
												</input>
											</span>
										</div>
										<div class="row" id="d_baud" style="visibility: display;">
											<span class="label">Baudrate:</span>
											<span class="formw">
												<xsl:call-template name="selectBox">
													<xsl:with-param name="option1" select="'baudOption'" />
													<xsl:with-param name="value1" select="baudValue" />
												</xsl:call-template>
											</span>
										</div>

										<div class="row" id="d_parity" style="visibility: display;">
											<span class="label">Parity:</span>
											<span class="formw">
												<xsl:call-template name="selectBox">
													<xsl:with-param name="option1" select="'parityOption'" />
													<xsl:with-param name="value1" select="parityValue" />
												</xsl:call-template>
											</span>
										</div>

										<div class="row" id="d_stopBits" style="visibility: display;">
											<span class="label">Stop Bits:</span>
											<span class="formw">
												<xsl:call-template name="selectBox">
													<xsl:with-param name="option1" select="'pointOption'" />
													<xsl:with-param name="value1" select="pointValue" />
												</xsl:call-template>
											</span>
										</div>


										<div class="row">
											<span class="label">Enable Trace:</span>
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

										<p />
										<br />
										<input type='submit' style="width: 120px" name="save"
											onclick='return m_validate();' value='Save' />
										<img hspace="10" src="/images/spacer.gif" />
									</div>

								</form>
							</div>
						</td>
					</tr>
				</table>

			</body>
		</html>
	</xsl:template>

	<xsl:template name="selectBox">
		<xsl:param name="option1">
		</xsl:param>
		<xsl:param name="value1" />
		<select size="1" name="{$option1}" id="{$option1}" onchange="changeConnection();">
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
