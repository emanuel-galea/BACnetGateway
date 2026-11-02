<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:template match="modbus">
		<html>
			<head xmlns="http://www.w3.org/1999/xhtml">
				<title>Modbus:BACnet Gateway - Devices</title>
				<link rel="stylesheet" href="../css/wine.css"></link>
				<link rel="shortcut icon" href="/images/32/logo_32.png"></link>
				<script language="javascript">
					//	<![CDATA[
				  				  
				 				  
				function export1()     {
				obj = document.getElementById("export1");
				obj.value = '1';
				document.forms[0].submit();
				}
				
				function refresh1()     {
				obj = document.getElementById("export1");
				obj.value = '0';
				document.forms[0].submit();
				}

											
				 // ]]>
				</script>
				
				
			</head>
			<body style="margin-top: 5px;">

				<form action="baccgi" method="post">
					<input name="action" value="0" type="hidden" />
					<input name="index" value="-1" type="hidden" />
					<input name="gate" value="modbus" type="hidden" />
					<input name="export1" value="0" type="hidden" />
					<span class="titleField">
						<img style="border: 0; height: 45px" src="/images/32/device.png" />

						MODBUS Devices
					</span>
					<br />
					<span style="font-size: small;">
						Licensed for:
						<xsl:value-of select="maxObjects" />
						Objects
					</span>
					<div style="color: green; font-weight: bold">
						<xsl:value-of select="scan" />
					</div>


					<p />
					<div style="color: red; font-weight: bold">
						<xsl:value-of select="message" />
						<p />
					</div>

					<input type='submit' value='Add New Device'
						onclick="this.form.action.value = 4; return true" />
					<img style="width: 10px" src="/images/spacer.gif" />
					<input type='submit' value='Read All'
						onclick="this.form.action.value = 8; return true" />
					<img style="width: 10px" src="/images/spacer.gif" />
					<input type='submit' value='Export to Excel' 
					onclick="this.form.export1.value = 1; return true" />
					<img style="width: 10px"  src="/images/spacer.gif" />
					
					Sort by:
					<xsl:call-template name="selectBox">
						<xsl:with-param name="option1" select="'sortOption'" />
						<xsl:with-param name="value1" select="/modbus/sortValue" />
					</xsl:call-template>
					
					<img style="width: 40px"  src="/images/spacer.gif" />
					<A href="/" style="text-align: left">
							<img style="vertical-align: middle; border: 0; text-align: left"
								src="/images/32/Backward_Green.png" />
							Main-Menu
						</A>	

					<p></p>
					
						<table class='container' id="bacnet" border="3">
							<tbody class='container'>
								<td>Name</td>
								<td>Connection</td>
								<td>Address</td>
								<!--        
								<td>Trans. Mode</td>  -->
								<!--<td>Vendor</td>
								<td>Product Code</td>
								<td>Revision</td>
								-->
								<td>Status</td>
								<td>Objects</td>
								<td>Edit</td>

							</tbody>

							<xsl:variable name="sortby" select="sortBy" />
							<xsl:variable name="sortorder" select="'ascending'" />

							<xsl:for-each select="device">
								<xsl:sort select="*[name(.)=$sortby]" order="{$sortorder}" />
								<tr onMouseOver="this.style.background='#FFFF00';"
									onMouseOut="this.style.background='#FFFFE0';">
									<td>
										<xsl:value-of select="name" />
									</td>
									<td>
										<xsl:value-of select="connection" />
									</td>
									<td>
										<xsl:value-of select="slaveAddress" />
									</td>
									<!--

									<td>
										<xsl:value-of select="vendor" />
									</td>
									<td>
										<xsl:value-of select="productCode" />
									</td>
									<td>
										<xsl:value-of select="revision" />
									</td>
									-->
									<td>
										<xsl:if test="status != 'OK'">
											<xsl:attribute name="style">color: red</xsl:attribute>
										</xsl:if>
										<xsl:value-of select="status" />

									</td>

									<td style="text-align: right">
										<a>
											<xsl:attribute name="href">baccgi?gate=modbus&amp;action=1&amp;index=<xsl:value-of
												select="index" />
							                       </xsl:attribute>
											<xsl:value-of select="records" />
											<img style="border:0;" src="/images/16/edit.png" title="Edit Object" />
										</a>
									</td>
									<td style="text-align: right">
										<a>
											<xsl:attribute name="href">baccgi?gate=modbus&amp;action=2&amp;index=<xsl:value-of select="index" />
											&amp;index2=<xsl:value-of select="index2" />
                                        </xsl:attribute>
											<img style="border:0; padding-right: 8px;" src="/images/16/edit.png"
												title="Edit Device" />
										</a>
									</td>
								</tr>
							</xsl:for-each>

						</table>
						<p />
						Total Devices:
						<xsl:value-of select="totalDevices" />
					

					<p />


				</form>

			</body>
		</html>
	</xsl:template>

		<xsl:template name="selectBox">
		<xsl:param name="option1">
		</xsl:param>
		<xsl:param name="value1" />
		<select size="1" name="{$option1}" id="{$option1}" >
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
