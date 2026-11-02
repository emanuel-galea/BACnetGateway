<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:include href="../adminPart.xsl" />

	<xsl:template match="configuration">
		<html>
			<head xmlns="http://www.w3.org/1999/xhtml">
				<TITLE>M-Bus:BACnet Gateway</TITLE>
				<link rel="stylesheet" href="../css/wine.css"></link>
				<link rel="shortcut icon" href="/images/32/logo_32.png"></link>
				<script type='text/javascript' src="/js/validate.js"></script>

				<script language="Javascript">

					function validatePage () {

					try {
					var form = document.forms[0];
					if (form == null) {
					return false;
					}
					if (validateNumber('deviceInstance', 0, 4194304) == false) {
					return false;
					}
					if (validateNumber('maxAPDU', 250, 1476) == false) {
					return false;
					}
					if (validateNumber('iamTime', 0, 1000) == false) {
					return false;
					}
					} catch (er) {
					alert ("EXCEPTION: " + er);
					return false;
					}
					}


</script>



			</head>
			<body>

				<table style="width: 100%">
					<tr>
						<td style="vertical-align: top">
							<xsl:apply-templates mode="admin" select="gateways" />
						</td>
						<td style="width: 100%; Vertical-align: top">
							<div class="shadow">
								<h2>
									<img style="vertical-align: middle; border: 0; height: 32px"
										src="/images/16/bacnetExplorer.png" />
									BACnet Configuration
								</h2>
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

								<form method="GET" action='bacConfig'>
									<input name="action" value="0" type="hidden" />
									<table class='container' id="bacnet" cellpadding="4"
										cellspacing="8">
										<tbody class='container'>
											<td colspan="3">Configuration</td>
										</tbody>
										<tr class='spacer'>
											<td colspan="3"></td>
										</tr>


										<tr>

											<td>
												<label for="bacnetType">BACnet Network Type</label>
											</td>
											<td>
												<xsl:call-template name="selectBox">
													<xsl:with-param name="option1" select="'bacnetTypeOption'" />
													<xsl:with-param name="value1"
														select="/configuration/bacnetTypeValue" />
												</xsl:call-template>
											</td>
											<td class='right'></td>
										</tr>

										<tr>

											<td>
												<label for="deviceInstance">BACnet Device Instance</label>
											</td>
											<td>
												<input id="deviceInstance" maxLength="7" name="deviceInstance"
													type='text' size="8">

													<xsl:attribute name="value">
                        <xsl:value-of select="objects/object/instance" />
                         </xsl:attribute>
												</input>
											</td>
											<td class='right'></td>
										</tr>
										<tr>

											<td>
												<label for="deviceName">BACnet Device Name</label>
											</td>
											<td>
												<input id="deviceName" name="deviceName" type='text'
													size="32">

													<xsl:attribute name="value">
                        <xsl:value-of select="objects/object/name" />
                         </xsl:attribute>
												</input>
											</td>
										</tr>
																				<tr>

											<td>
												<label for="maxAPDU">Max APDU</label>
											</td>
											<td>
												<input name="maxAPDU" maxLength="4" type='text' size="5">

													<xsl:attribute name="value">
                        <xsl:value-of select="/configuration/maxAPDU" />
                         </xsl:attribute>
												</input>
											</td>
											<td class='right'>default=1476</td>
										</tr>
										<tr>

											<td>
												<label for="iamTime">Broadcast I-am every</label>
											</td>
											<td>
												<input name="iamTime" maxLength="4" type='text' size="5">

													<xsl:attribute name="value">
                        <xsl:value-of select="/configuration/iamTime" />
                         </xsl:attribute>
												</input>
											</td>
											<td>munites</td>
										</tr>


										<tr class='spacer'>
											<td colspan="3"></td>
										</tr>

										<tr class='spacer'>
											<td colspan="3"></td>
										</tr>

									</table>
									<p />

									<table class='container' id="bbmd">
										<tbody class='container'>
											<td>BBMD Registration</td>
										</tbody>
										<tr>
											<td>
												<table cellpadding="2" cellspacing="8" border="1">
													<tbody class='container'>
														<td>IP Number</td>
														<td>Port</td>
														<td>IP Network Mask</td>
														
													</tbody>
													<xsl:for-each select="bbmd/entry">
														<tr>
															<td>
																<xsl:value-of select="ipAddress" />
															</td>
															<td style="text-align: right">
																<xsl:value-of select="port" />
															</td>
															<td style="text-align: right">
																<xsl:value-of select="mask" />
															</td>
															<td style="text-align: right">
																<a>

																	<xsl:attribute name="href">bacConfig?action=1&amp;bbmd_entry_index=<xsl:number
																		value="position()" format="1" />
                    </xsl:attribute>
																	<img style="border:0; padding-right: 2px;" src="/images/16/delete.png"
																		title="Delete" alt="Delete" />
																</a>
															</td>
														</tr>
													</xsl:for-each>
													<tr>
														<td>
															<input id="ipAddress" name="ipAddress" style="width: 160px">
															</input>
														</td>
														<td style="text-align: right">
															<input id="port" name="port" style="width: 60px"
																maximum="5" value="47808">
															</input>
														</td>
														<td style="text-align: right">
															<input id="mask" name="mask" style="width: 160px"
																value="255.255.255.255">
															</input>
														</td>
														<td style="text-align: right">
															
														</td>
													</tr>
												</table>
											</td>
										</tr>
									</table>
									<p></p>

									<input type='submit' style="width: 120px" name="save"
										onclick='return validatePage();' value='Save' />
									<img hspace="10" src="/images/spacer.gif" />


								</form>
								<p></p>
								<form method="POST" action='baccgi'>
									<input name="gate" value="main" type="hidden" />
									<input name="action" value="2" type="hidden" />
									<input type='submit' name="iam" value='Broadcast I-am' />
								</form>

							</div>
						</td>
					</tr>
				</table>
			</body>
		</html>
	</xsl:template>


	<xsl:template name="make-select">
		<select size="1" name="logLevel">
			<xsl:for-each select="logOptions/option">
				<option>
					<xsl:if test="./text() = /configuration/logLevel">
						<xsl:attribute name="selected">
							<xsl:value-of select="'selected'" />
                         </xsl:attribute>

					</xsl:if>
					<xsl:value-of select="./text()" />
				</option>
			</xsl:for-each>
		</select>
	</xsl:template>

	<xsl:template name="make-select-baudrate">
		<select size="6" multiple="multiple" name="baudrate">
			<xsl:for-each select="MBus/baudrates/option">
				<option>
					<xsl:if test="@enabled='true'">
						<xsl:attribute name="selected">
							<xsl:value-of select="'selected'" />
                         </xsl:attribute>

					</xsl:if>
					<xsl:value-of select="./text()" />
				</option>
			</xsl:for-each>
		</select>
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
