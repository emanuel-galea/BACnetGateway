<?xml version="1.0" encoding="ISO-8859-1" ?>

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="html" encoding="ISO-8859-1" />

	<xsl:template match="meter">
		<html>
			<head>
				<title>M-Bus:BACnet Gateway EditMeter</title>
				<link rel="stylesheet" href="../css/wine.css"></link>
				<link rel="shortcut icon" href="/images/32/logo_32.png"></link>

				<script language="javascript">
					function deleteMeter() {
					val = confirm ("Do you really want to delete this meter ?");
					if (val == true) {
					document.forms[0].action.value = "5";
					}
					return val;
					}

					function deleteAllMeter() {
					val = confirm ("Do you really want to delete ALL the meters ?");
					if (val == true) {
					document.forms[0].action.value = "8";
					}
					return val;
					}

					function intervalAllMeter() {
					val = confirm ("Do you want to set the Interval to ALL the meters ?");
					if (val == true) {
					document.forms[0].action.value = "9";
					}
					return val;
					}


</script>
			</head>
			<body style="margin-top: 50px;">

				<p />
				<h2>
					<img style="vertical-align: middle; border: 0" src="/images/48/logo_48.png" />
					Kara Systems
				</h2>
				<H2>
					<img border="0" src="/images/24/gauge2.png" />
					M-Bus Edit Meter:
					<xsl:value-of select="name" />
					<p />


				</H2>
				<div style="color: red; font-weight: bold">
					<xsl:value-of select="message" />
					<p />
				</div>


				<p />
				<br />

				<form action="baccgi" method="post">
					<input name="action" value="4" type="hidden" />
					<input name="gate" value="mbus" type="hidden" />
					<input name="index" type="hidden">
						<xsl:attribute name="value">
                        			<xsl:value-of select="meterIndex" />
                        </xsl:attribute>
					</input>
					<table class='container' id="bacnet" cellpadding="4"
						cellspacing="4" Style="border: 3;border-style: solid; width: 70%">

						<tr>
							<td>
								MBus Address:
						</td>
							<td>
									<xsl:value-of select="address" />
							</td>
						</tr>
						<tr>
							<td>
								Name:
						</td>
							<td>
								<input style="text-align: right" max="64" id="name" name="name">

									<xsl:attribute name="value">
                        			<xsl:value-of select="name" />
                        			 </xsl:attribute>
								</input>
							</td>
						</tr>

						<tr>
							<td>
								Reading Interval (minutes):
						</td>
							<td>
								<input style="text-align: right" max="5" id="interval"
									name="interval">

									<xsl:attribute name="value">
                        			<xsl:value-of select="readInterval" />
                        			 </xsl:attribute>
								</input>
							</td>
						</tr>
						<tr>
							<td>
								Convert All Records to BACnet:
						</td>
							<td>
								<input name="statistics" type='checkbox'>

									<xsl:if test="hour = '1'">
										<xsl:attribute name="checked">
					    	<xsl:value-of select="'checked'" />
			         		</xsl:attribute>
									</xsl:if>
								</input>
							</td>
						</tr>

						<tr>
							<td>
								Baudrate: 
						</td>
							<td>
								<xsl:call-template name="selectBox">
									<xsl:with-param name="option1" select="'baudOption'" />
									<xsl:with-param name="value1" select="/meter/baudValue" />
								</xsl:call-template>
							</td>
						</tr>

						<tr>
							<td>
								Default Record No: 
						</td>
							<td>
								<xsl:call-template name="selectBox">
									<xsl:with-param name="option1" select="'recordOption'" />
									<xsl:with-param name="value1" select="/meter/recordValue" />
								</xsl:call-template>
							</td>
						</tr>



					</table>
					<p />
					<input type='submit' style="width: 150px" value='Save' />
					<img hspace="20" src="/images/spacer.gif" />
					
											
					<input type='button' value='Next >>' >
					<xsl:attribute name="onclick">window.location.href='baccgi?gate=mbus&amp;action=4&amp;index=<xsl:value-of select="meterIndex + 1"/>'; return false</xsl:attribute>	
						
					</input>
					<img hspace= "1" src="/images/spacer.gif" />	
					<input type='button' value="&lt;&lt; Back" >
					<xsl:attribute name="onclick">window.location.href='baccgi?gate=mbus&amp;action=4&amp;index=<xsl:value-of select="meterIndex - 1"/>'; return false</xsl:attribute>	
						
					</input>	
					<img hspace= "20" src="/images/spacer.gif" />
					<input type='submit' onclick="return deleteMeter();" value='Delete Meter' />
															
					<p></p>
					<A href="baccgi?gate=mbus&amp;action=1">
						<img style="vertical-align: middle; border: 0" src="/images/32/Backward_Yellow.png" />
						back to Meter List
					</A>
					<p></p>
					<img vspace="30" src="/images/spacer.gif" />

					<input type='submit' onclick="return deleteAllMeter();"
						value='Delete ALL Meters' />
					<img hspace="10" src="/images/spacer.gif" />
					<input type='submit' onclick="return intervalAllMeter();"
						value='Set Interval To ALL Meters' />



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
