<?xml version="1.0" encoding="ISO-8859-1" ?>

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exslt="http://exslt.org/common"
	extension-element-prefixes="exslt">
	<xsl:output method="html" encoding="ISO-8859-1" />


	<xsl:template match="modbus">
		<html>
			<head>
				<title>BACnet Gateway - Edit Modbus Device</title>
				<link rel="stylesheet" href="../css/wine.css"></link>
				<link rel="shortcut icon" href="/images/32/logo_32.png"></link>

				<script language="javascript">
					//	<![CDATA[
					function deleteDevice() {
					val = confirm ("Do you really want to delete this Modbus Device and all it's objects?");
					if (val == true) {
					document.forms[0].action.value = "6";
					}
					return val;
					}

					function
					deleteAllDevices() {
					val = confirm ("Do you really want to delete ALL Modbus Devices and their objects?");
					if (val == true) {
					document.forms[0].action.value = "f";
					}
					return val;
					}

					function
					changeConnection () {

					if
					(document.forms[0].typeOption.value == 0) {
					// serial
					document.getElementById('d_port').style.display = 'none';
					document.getElementById('d_tcpAddress').style.display = 'none';
					document.getElementById('d_baud').style.display = 'block';
					document.getElementById('d_parity').style.display = 'block';
					document.getElementById('d_stopBits').style.display = 'block';
					document.getElementById('d_serialPort').style.display = 'block';
					} else
					{
					// TCP
					document.getElementById('d_port').style.display = 'block';
					document.getElementById('d_tcpAddress').style.display = 'block';
					document.getElementById('d_baud').style.display = 'none';
					document.getElementById('d_parity').style.display = 'none';
					document.getElementById('d_stopBits').style.display = 'none';
					document.getElementById('d_serialPort').style.display = 'none';
					
					
					}
					}

		 // ]]>
				</script>
			</head>
			<body style="margin-top: 50px;">

				<p />
				<H2>
					<img style="border: 0; height: 40px" src="/images/32/device.png" />

					<xsl:choose>
						<xsl:when test="index = '-1'">
							Add new Modbus Device
						</xsl:when>
						<xsl:otherwise>
							Edit Modbus Device:
							<xsl:value-of select="name" />
						</xsl:otherwise>
					</xsl:choose>

					<p />

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

				<form action="baccgi" method="post">
					<input name="action" value="2" type="hidden" />
					<input name="gate" value="modbus" type="hidden" />
					<input name="index" type="hidden">
						<xsl:attribute name="value"><xsl:value-of
							select="index" /></xsl:attribute>
					</input>

					<div
						style="width: 700px; padding: 5px;margin: 0px auto;border: 2px; border-style: outset">

						<div class="row">
							<span class="label">Device Name:</span>
							<span class="formw">
								<input maxLength="64" id="name" name="name">
									<xsl:attribute name="value">
                        			<xsl:value-of select="name" />
                        			 </xsl:attribute>
								</input>
							</span>
						</div>

						<div class="row">
							<span class="label">Connection Type:</span>
							<span class="formw">
								<xsl:call-template name="selectBox">
									<xsl:with-param name="option1" select="'typeOption'" />
									<xsl:with-param name="value1" select="/modbus/typeValue" />
								</xsl:call-template>
							</span>
						</div>
						<!-- <div class="row"> <span class="label">Transmision Mode:</span> 
							<span class="formw"> <xsl:call-template name="selectBoxTrans" /> </span> 
							</div> -->
						<div class="row" id="d_tcpAddress">
							<span class="label">TCP Address:</span>
							<span class="formw">
								<input style="width: 250px" max="64" id="address" name="address">
									<xsl:attribute name="value">
                                    <xsl:value-of select="tcpAddress" />
                                     </xsl:attribute>
								</input>
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
						<div class="row" id="d_port" style="visibility: display;">
							<span class="label">Port: </span>
							<span class="formw">
								<input style="width: 60px" maxLength="5" id="port" name="port">
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
									<xsl:with-param name="value1" select="/modbus/serialPortValue" />
								</xsl:call-template>
							</span>
						</div>

						<div class="row" id="d_parity" style="visibility: display;">
							<span class="label">Parity:</span>
							<span class="formw">
								<xsl:call-template name="selectBox">
									<xsl:with-param name="option1" select="'parityOption'" />
									<xsl:with-param name="value1" select="/modbus/parityValue" />
								</xsl:call-template>
							</span>
						</div>
						<div class="row" id="d_stopBits" style="visibility: display;">
							<span class="label">Stop Bits:</span>
							<span class="formw">
								<xsl:call-template name="selectBox">
									<xsl:with-param name="option1" select="'pointOption'" />
									<xsl:with-param name="value1" select="/modbus/pointValue" />
								</xsl:call-template>
							</span>
						</div>
						<div class="row" id="d_baud" style="visibility: display;">
							<span class="label">Baudrate:</span>
							<span class="formw">
								<xsl:call-template name="selectBox">
									<xsl:with-param name="option1" select="'baudOption'" />
									<xsl:with-param name="value1" select="/modbus/baudValue" />
								</xsl:call-template>
							</span>
						</div>
						<div class="row">
							<span class="label">Keep Connection Open:</span>
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

						<img vspace="15" src="/images/spacer.gif" />

					</div>
					<br />
					<p></p>
					<input type='submit' value='Save' style="width: 150px" />
					<xsl:choose>
						<xsl:when test="index != '-1'">
							<img hspace="10" src="/images/spacer.gif" />
							<input type='submit' style="width: 150px" onclick="return deleteDevice();"
								value='Delete' />
						</xsl:when>

					</xsl:choose>


					<p></p>
					<img vspace="10" src="/images/spacer.gif" />

					<div id="container200">
						<A href="/cgi/baccgi?gate=modbus&amp;action=0" style="text-align: left">
							<img style="vertical-align: middle; border: 0" src="/images/32/Backward_Yellow.png" />
							Device List Menu
						</A>
						<p />
						<A href="/" style="text-align: left">
							<img style="vertical-align: middle; border: 0; text-align: left"
								src="/images/32/Backward_Green.png" />
							Main-Menu
						</A>
					</div>



				</form>
				<script language="javascript">
					changeConnection();
                </script>

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
