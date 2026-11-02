<?xml version="1.0" encoding="ISO-8859-1" ?>

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exslt="http://exslt.org/common"
	extension-element-prefixes="exslt">
	<xsl:output method="html" encoding="ISO-8859-1" />


	<xsl:template match="root">
		<html>
			<head>
				<title>BACnet Gateway - Edit </title>
				<link rel="stylesheet" href="../css/wine.css"></link>
				<link rel="shortcut icon" href="/images/32/logo_32.png"></link>
				
				<script language="javascript">
					//	<![CDATA[
					function deleteObject() {
					val = confirm ("Do you really want to delete this 1Wire Device ?");
					if (val == true) {
					document.forms[0].action.value = "4";
					}
					return val;
					}


				function gotoAction(wert)     {
				document.editObject.action.value =wert;
				document.editObject.submit();
				}
				
				function changeSelect () {

					obj = document.getElementById('ioOption')
					if ((obj.value == 4) ||
						(obj.value == 3)) {  // bianry output coil
				
					document.getElementById('unitOption').disabled = true;
					document.getElementById('multiplier').disabled = true;
					document.getElementById('pointOption').disabled = true;
					document.getElementById('vrefOption').disabled = true;
					document.getElementById('typeOption').disabled = true;
					} else
					{
					document.getElementById('unitOption').disabled = false;
					document.getElementById('multiplier').disabled = false;
					document.getElementById('pointOption').disabled = false;
					document.getElementById('vrefOption').disabled = false;
					document.getElementById('typeOption').disabled = false;
					
					}
					}
							
				 // ]]>
				</script>
			</head>
			<body style="margin-top: 20px;">

				<H2>
					<img border="0" src="/images/32/bacnet.png" />
					Edit BACnet Object
				</H2>
				<xsl:value-of select="moduleType" />

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
			
				<form name="editObject" action="baccgi" method="post">
					<input name="action" value="13" type="hidden" />
					<input name="gate" value="main" type="hidden" />
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
						style="width: 750px; padding: 12px 12px 35px 25px; margin: 0px auto;border: 2px; border-style: outset">

						<div class="row">
							<span class="label">Type:</span>
							<span class="formw" >
								<xsl:value-of select="type" />
								<img style="width: 15px" src="/images/spacer.gif" />
							</span>

							<span >Identifier: 
							<xsl:value-of select="index2" />
							<img style="width: 15px" src="/images/spacer.gif" />
							</span>
							
							<span >Gate: </span>
							<xsl:value-of select="gate" />
							
							
						</div>
						<div class="row">
							<span class="label">Name:</span>
							<span class="formw">
								<input style="width: 450px" max="64" name="name">
									<xsl:attribute name="value">
                                    <xsl:value-of select="name" />
                                     </xsl:attribute>
								</input>
							</span>
						</div>
						<div class="row">
							<span class="label">Description:</span>
							<span class="formw">
								<input style="width: 450px" max="64" name="address">
									<xsl:attribute name="value">
                                    <xsl:value-of select="desc" />
                                     </xsl:attribute>
								</input>
							</span>
						</div>
						
						<xsl:if test="bindAddresses">
						<div class="row">
							<span class="label">Bind-Addresses:</span>
							<span class="formw">
                                    <xsl:value-of select="bindAddresses" />
							</span>
						</div>
							
						</xsl:if>
						
						<xsl:if test="cov_subscriptions">
						<div class="row">
							<span class="label">COV Subscriptions:</span>
							<span class="formw">
                                    <xsl:value-of select="cov_subscriptions" />
							</span>
						</div>
						<div class="row">
							<span class="label">Clear COV Subscriptions:</span>
							<span class="formw">
								<input name="bacnet" type='checkbox'>
									
								</input>
							</span>
						</div>					
						</xsl:if>
						
						
						
						
						
						
						<xsl:if test="analogValue">
						<div class="row">
							<span class="label">Present Value:</span>
							<span class="formw">
								<input style="text-align: right; width: 120px" maxLength="10"
									name="floatValue">
									<xsl:attribute name="value">
                        			<xsl:value-of select="analogValue" />
                        			 </xsl:attribute>
								</input>
							</span>
							
							<span class="shortLabel"> Priority:</span>
							<span class="formw">
								<xsl:call-template name="selectBox">
									<xsl:with-param name="option1" select="'priorityOption'" />
									<xsl:with-param name="value1" select="/root/priorityValue" />
								</xsl:call-template>
							</span> 
						</div>
						
						<div class="row">
							<span class="label">Priority-Array :</span>
							<span style="float: left;text-align: left;width: 500px">
								<xsl:value-of select="priorityArray" />
							</span>
						</div>
						
						
						<div class="row" id="d_multiplier" style="visibility: display;">
							<span class="label">Multiplier:</span>
							<span class="formw">
								<input style="text-align: right; width: 100px" maxLength="8" id="multiplier"
									name="multiplier">
									<xsl:attribute name="value">
                                    <xsl:value-of select="multiplier" />
                                     </xsl:attribute>
								</input>
								<img style="width: 20px" src="/images/spacer.gif" />
								
							</span>

							<span class="shortLabel">Decimal Places:</span>
							<span class="formw">
								<xsl:call-template name="selectBox">
									<xsl:with-param name="option1" select="'pointOption'" />
									<xsl:with-param name="value1" select="/root/pointValue" />
								</xsl:call-template>
							</span>
						</div>
						
						
						</xsl:if>
						
						
						
						<xsl:if test="ioOption">
						<div class="row" id="d_unit" style="visibility: display;">
							<span class="label">Value:</span>
							<span class="formw">
								<xsl:call-template name="selectBox">
									<xsl:with-param name="option1" select="'ioOption'" />
									<xsl:with-param name="value1" select="/root/ioValue" />
								</xsl:call-template>
							</span>
						</div>
						</xsl:if>
						
						
						
						<xsl:if test="oos">						
						<div class="row">
							<span class="label">Out-Of-Service:</span>
							<span class="formw">
								<input name="bacnet" type='checkbox'>
									<xsl:if test="oos = '1'">
										<xsl:attribute name="checked">
                            <xsl:value-of select="'checked'" />
                            </xsl:attribute>
									</xsl:if>
								</input>
							</span>
						</div>
						</xsl:if>
						
						<xsl:if test="status">
						<div class="row">
							<span class="label">Status-Flags :</span>
							<span class="label" >
								<xsl:value-of select="status" />
							</span>
						</div>
						</xsl:if>
						<xsl:if test="unitOption">
						<div class="row" id="d_unit" style="visibility: display;">
							<span class="label">BACnet Unit:</span>
							<span class="formw">
								<xsl:call-template name="selectBox">
									<xsl:with-param name="option1" select="'unitOption'" />
									<xsl:with-param name="value1" select="/root/unitValue" />
								</xsl:call-template>
							</span>
						</div>
						</xsl:if>
						
						<xsl:if test="cov">
						<div class="row">
							<span class="label">Change Of Value :</span>
							<span class="formw">
								<input style="text-align: right; width: 90px" maxLength="5"
									name="float1">
									<xsl:attribute name="value">
                        			<xsl:value-of select="cov" />
                        			 </xsl:attribute>
								</input>
							</span>
						</div>	
						</xsl:if>
						
						<xsl:if test="lowLimit">
						<div class="row">
							<span class="label">Low-Limit :</span>
							<span class="formw">
								<input style="text-align: right; width: 90px" maxLength="10"
									name="float2">
									<xsl:attribute name="value">
                        			<xsl:value-of select="lowLimit" />
                        			 </xsl:attribute>
								</input>
								<img style="padding-right: 30px" src="/images/spacer.gif" />
							</span>
							
							<span class="shortLabel">High-Limit :</span>
							<span class="formw">
								<input style="text-align: right; width: 90px" maxLength="10"
									name="float3">
									<xsl:attribute name="value">
                        			<xsl:value-of select="highLimit" />
                        			 </xsl:attribute>
								</input>
							</span>
							
						</div>	
						</xsl:if>					
						
						
						<xsl:if test="deadBand">
						<div class="row">
							<span class="label">Dead-Band :</span>
							<span class="formw">
								<input style="text-align: right; width: 90px" maxLength="5"
									name="float4">
									<xsl:attribute name="value">
                        			<xsl:value-of select="deadBand" />
                        			 </xsl:attribute>
								</input>
							</span>
						</div>	
						</xsl:if>	
						
					</div>

					<p></p>
					<input type='submit' style="width: 120px" value='Save'  name="save"/>
					<img style="width: 10px" src="/images/spacer.gif" />

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
