<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:template match="record">
		<html>
			<head xmlns="http://www.w3.org/1999/xhtml">
				<title>M-Bus:BACnet Gateway</title>
				<link rel="stylesheet" href="../css/wine.css"></link>
				<link rel="shortcut icon" href="/images/32/logo_32.png"></link>

				<script language="javascript">
				//	<![CDATA[
				function readRecords()     {
				document.editRecord.action.value = 3;
				document.editRecord.submit();
				}
								
				 // ]]>

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
					M-Bus Editing Meter: <xsl:value-of select="name" />, Record No:
					<xsl:value-of select="recordNo" />
					<p />


				</H2>
				<div style="color: red; font-weight: bold">
					<xsl:value-of select="message" />
					<p />
				</div>

				<p />
				<br />

				<form name="editRecord" action="baccgi" method="post">
					<input name="action" value="6" type="hidden" />
					<input name="gate" value="mbus" type="hidden" />
					<input name="index" type="hidden">
						<xsl:attribute name="value">
                        			<xsl:value-of select="meterIndex" />
                        </xsl:attribute>
					</input>
					<input name="index2" type="hidden">
						<xsl:attribute name="value">
                        			<xsl:value-of select="recordNo" />
                        </xsl:attribute>
					</input>
					<table class='container' id="bacnet" cellpadding="4"
						cellspacing="4" border="3" width="60%">

						
						<tr>
							<td>
								To BACnet Object:
						</td>
							<td>
								<input name="bacnet" type='checkbox'>

									<xsl:if test="bacnet > '-1'">
										<xsl:attribute name="checked">
					    	<xsl:value-of select="'checked'" />
			         		</xsl:attribute>
									</xsl:if>
								</input>
							</td>
						</tr>
						
						<tr>
							<td>
								Modbus-Address (Even Addresses. Type float):
						</td>
							<td >
								<input style="width: 60px" maxLength="3" id="intParam1"
									name="intParam1">
									<xsl:attribute name="value">
                                    <xsl:value-of select="intParam1" />
                                     </xsl:attribute>
								</input>
							</td>
						</tr>

						<tr>
							<td>
								Unit:
						</td>
							<td >
								<xsl:call-template name="selectBox">
									<xsl:with-param name="option1" select="'unitOption'" />
									<xsl:with-param name="value1" select="/record/unitValue" />
								</xsl:call-template>
							</td>
						</tr>
						
					</table>
					<p />
					<input type='submit' name="save" value='Save' />
					<p />
					
					<a href="javascript:readRecords()">To Record List</a>
					<img hspace="10" src="/images/spacer.gif" />
						
					<a href="javascript:window.location.href='baccgi?gate=mbus&amp;action=1';">
						To Meter List</a>

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
