<?xml version="1.0" encoding="ISO-8859-1" ?>

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exslt="http://exslt.org/common"
	extension-element-prefixes="exslt">
	<xsl:output method="html" encoding="ISO-8859-1" />


	<xsl:template match="modbus">
		<html>
			<head>
				<title>BACnet Gateway - Edit Modbus Object</title>
				<link rel="stylesheet" href="../css/wine.css"></link>
				<link rel="shortcut icon" href="/images/32/logo_32.png"></link>
				
				<script language="javascript">
					//	<![CDATA[
					function deleteObject() {
					val = confirm ("Do you really want to delete this Modbus Object ?");
					if (val == true) {
					document.forms[0].action.value = "7";
					}
					return val;
					}


				function gotoAction(wert)     {
				document.editObject.action.value =wert;
				document.editObject.submit();
				}
				
				function changeSelect () {

					if (document.forms[0].typeOption.value > 1) {
					// coild
					document.getElementById('d_unit').style.display = 'none';
					
					} else
					{
					document.getElementById('d_unit').style.display = 'block';
					}
					
					if (((document.forms[0].typeOption.value == 1) || (document.forms[0].typeOption.value == 0))&& (document.forms[0].unitOption.value == 0)) {
					// holding
					document.getElementById('hr_binary').style.display = 'block';
					document.getElementById('bitNo').style.display = 'block';
					
					} else 	{
					document.getElementById('hr_binary').style.display = 'none';
					document.getElementById('bitNo').style.display = 'none';
					}
					}
							
				 // ]]>
				</script>
			</head>
			<body style="margin-top: 40px;">

				<H2>
					<img border="0" src="/images/32/objects.png" />
					<xsl:choose>
						<xsl:when test="index2 = '-1'">
							Add new Modbus Object
						</xsl:when>
						<xsl:otherwise>
							Edit Modbus Object:
							<xsl:value-of select="name" />
						</xsl:otherwise>
					</xsl:choose>

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

				<form name="editObject" action="baccgi" method="post">
					<input name="action" value="3" type="hidden" />
					<input name="gate" value="modbus" type="hidden" />
					<input name="index" type="hidden">
						<xsl:attribute name="value">
                        			<xsl:value-of select="index" />
                        </xsl:attribute>
					</input>
					<input name="index2" type="hidden">
						<xsl:attribute name="value">
                                    <xsl:value-of select="index2" />
                        </xsl:attribute>
					</input>

					<div
						style="width: 700px; padding: 5px;margin: 0px auto;border: 2px; border-style: outset">

						<div class="row">
							<span class="label">Device:</span>
							<span class="formw">
								<xsl:value-of select="deviceName" />
							</span>
						</div>

						<div class="row">
							<span class="label">Name:</span>
							<span class="formw">
								<input style="width: 350px" max="32" id="name" name="name">
									<xsl:attribute name="value">
                                    <xsl:value-of select="name" />
                                     </xsl:attribute>
								</input>
							</span>
						</div>


						<div class="row">
							<span class="label">Type:</span>
							<span class="formw">
								<xsl:call-template name="selectBox">
									<xsl:with-param name="option1" select="'typeOption'" />
									<xsl:with-param name="value1" select="/modbus/typeValue" />
								</xsl:call-template>
							</span>
						</div>

						<div class="row">
							<span class="label">Address:</span>
							<span class="formw">
								<input style="width: 60px" maxLength="5" id="address"
									name="address">
									<xsl:attribute name="value">
                                    <xsl:value-of select="address" />
                                     </xsl:attribute>
								</input>
							</span>
						</div>
						
						<div class="row">
							<span class="label">BACnet Instance:</span>
							<span class="formw">
								<xsl:value-of select="bacInst" />
							</span>
						</div>
						
						<div class="row">
							<span class="label">As BACnet Object Value:</span>
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
						
						<div class="row" id="hr_binary" style="visibility: display;">
							<span class="label">Bits to BACnet BINARY:</span>
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
						
						<div class="row" id="bitNo" style="visibility: display;">
							<span class="label">Bit Number (0=LSBit):</span>
							<span class="formw">
								<input style="width: 60px" maxLength="5" id="intParam1"
									name="intParam1">
									<xsl:attribute name="value">
                                    <xsl:value-of select="intParam1" />
                                     </xsl:attribute>
								</input>
							</span>
						</div>

						<div class="row" id="d_unit" style="visibility: display;">
							<span class="label">Data Format:</span>
							<span class="formw">
								<xsl:call-template name="selectBox">
									<xsl:with-param name="option1" select="'unitOption'" />
									<xsl:with-param name="value1" select="/modbus/unitValue" />
								</xsl:call-template>
							</span>
						</div>

						<div class="row">
							<span class="label">Reading Interval (sec):</span>
							<span class="formw">
								<input style="text-align: right; width: 60px" maxLength="5"
									name="interval">

									<xsl:attribute name="value">
                        			<xsl:value-of select="interval" />
                        			 </xsl:attribute>
								</input>
							</span>
						</div>

						<img vspace="15" src="/images/spacer.gif" />

					</div>


					<img vspace="20" src="/images/spacer.gif" />
					<p></p>
					<input type='submit' style="width: 120px" value='Save' />
					<img hspace="10" src="/images/spacer.gif" />

					<xsl:choose>
						<xsl:when test="index2 != '-1'">
							<img hspace="10" src="/images/spacer.gif" />
							<input type='submit' style="width: 150px" onclick="return deleteObject();"
								value='Delete Object' />
						</xsl:when>

					</xsl:choose>

					<p></p>
					<img vspace="20" src="/images/spacer.gif" />

					<div id="container200" >
					<A href="javascript:gotoAction('1');">
						<img style="vertical-align: middle; border: 0" src="/images/32/Backward_Yellow.png" />
						List Objects</A>
					<p />
					
					<A href="javascript:gotoAction('0');">
						<img style="vertical-align: middle; border: 0" src="/images/32/Backward_Yellow.png" />
					List Devices</A>
					<p />
					<A href="/index.html"> 
					<img style="vertical-align: middle; border: 0" src="/images/32/Backward_Green.png" />
					Main-Menu</A>
					</div>


				</form>
					<script language="javascript">
					changeSelect();
                </script>

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
