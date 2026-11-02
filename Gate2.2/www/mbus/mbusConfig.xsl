<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="html" encoding="ISO-8859-1" />
	
	<xsl:include href="../adminPart.xsl"/>
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

				<H2>BACnet Gateway</H2>

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
						<xsl:value-of select="message" /><br></br>
						</div>
				</xsl:if>

				<form method="GET" action='baccgi'>
					<input name="action" value="16" type="hidden" />
					<input name="gate" value="mbus" type="hidden" />
					<table class='container' id="bacnet" cellpadding="4"
						cellspacing="8">
						<tbody class='container'>
							<td>
								<img border="0" src="/images/24/MBus.png" />
							</td>
							<td colspan="3">Configuration</td>
						</tbody>
						<tr class='spacer'>
							<td colspan="3"></td>
						</tr>

						<tr>
							<td></td>
							<td>
								<label for="baud">Enabled Baudrates</label>
							</td>
							<td>
							<div>
							<xsl:for-each select="baud">
								<input type='checkbox'>
										<xsl:attribute name="name">_inst_<xsl:number
											value="position()-1" format="1" />
										</xsl:attribute>
											<xsl:if test="checked ='1'">
												<xsl:attribute name="checked">
					    	<xsl:value-of select="'checked'" />
			         		</xsl:attribute>
											</xsl:if>
										</input>
										<xsl:value-of select="name"/>
										<br></br>
								</xsl:for-each>
										</div>
							</td>
							<td class='right'></td>
						</tr>
						<tr>
							<td></td>
							<td>
								<label for="serialPortName">Serial Port Name</label>
							</td>
							<td>
								<xsl:call-template name="selectBox">
									<xsl:with-param name="option1" select="'serialPortOption'" />
									<xsl:with-param name="value1" select="/root/serialPortValue" />
								</xsl:call-template>
							</td>

							<td class='right'></td>
						</tr>

						

						<tr>
							<td></td>
							<td>
								<label for="mbusRS485">RS485 Interface</label>
							</td>
							<td>
								<input id="mbusRS485" name="keepOpen" type='checkbox'>
									<xsl:if test="keepOpen ='1'">
										<xsl:attribute name="checked">
										<xsl:value-of select="'checked'" />
			                         </xsl:attribute>
									</xsl:if>
								</input>
							</td>
							<td class='right'></td>
						</tr>
						<tr class='spacer'>
							<td colspan="3"></td>
						</tr>

						
						<tr class='spacer'>
							<td colspan="3"></td>
						</tr>
						<tr class='spacer'>
							<td colspan="3"></td>
						</tr>

					</table>
					<p />
					<input type='submit' style="width: 120px" name="save"
						onclick='return m_validate();' value='Save' />
					<img hspace="10" src="/images/spacer.gif" />
					
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


	
	<xsl:template name="make-select-baudrate">
		<select size="6" multiple="multiple" name="intArray1">
			<xsl:for-each select="baudOption">
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


</xsl:stylesheet>
