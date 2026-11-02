<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:template match="meters">
		<html>
			<head xmlns="http://www.w3.org/1999/xhtml">
				<title>M-Bus:BACnet Gateway</title>
				<link rel="stylesheet" href="../css/wine.css"></link>
				<link rel="stylesheet" href="../css/tooltip.css"></link>

				<link rel="shortcut icon" href="/images/32/logo_32.png"></link>
				<script type="text/javascript" language="javascript" src="../js/tooltip.js"></script>
				<script language="javascript">
					//	<![CDATA[
				  				  
				  function openModal(modalPanel)  {
				  	var modal= document.getElementById(modalPanel);
				  	var shade= document.getElementById('shade');
				   	modal.style.display=shade.style.display='block';
				  }
				  
				  function closeModal(modalPanel)  {
				  	var modal= document.getElementById(modalPanel);
				  	var shade= document.getElementById('shade');
				  	modal.style.display=shade.style.display= 'none';
				  }
				  
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

			<body>
				<div id="shade" class="shade" style="display: none"></div>
				<form action="baccgi" method="post">
					<input name="gate" value="mbus" type="hidden" />
					<input name="action" value="1" type="hidden" />
					<input name="export1" id='export1' value="0" type="hidden" />
					<span class="titleField">
						<img style="vertical-align: middle; border: 0" src="/images/32/data_table.png" />
						M-Bus Meter Reading
					</span>
					<br />
					<div style="font-size: small">
						Licensed for:
						<xsl:value-of select="maxObjects" />
						Objects
					</div>
					<div style="color: green; font-weight: bold">
						<xsl:value-of select="scan" />
					</div>


					<p />
					<div style="color: red; font-weight: bold">
						<xsl:value-of select="message" />
						<p />
					</div>

					<a href="javascript:refresh1();">
					<img style="border: 0" src="/images/24/view-refresh-6.png" />Refresh</a>
					<img width="10" src="/images/spacer.gif" />

					<a href="javascript:export1();">
						<img style="border: 0" src="/images/24/download.png" />
						Download
					</a>


					<img width="10" src="/images/spacer.gif" />

					<input type='button' value='Add Meter' onclick="openModal('newMeterPanel')" />
					<img width="10" src="/images/spacer.gif" />

					<input type='submit' onclick="document.forms[0].action.value='2'; return true"
						value='Start Scan' />
					<img width="10" src="/images/spacer.gif" />
					

					<img width="10" src="/images/spacer.gif" />

					Sort by:
					<xsl:call-template name="selectBox">
						<xsl:with-param name="option1" select="'sortOption'" />
						<xsl:with-param name="value1" select="/meters/sortValue" />
					</xsl:call-template>

					<xsl:variable name="sortby" select="sortBy" />
					<xsl:variable name="sortorder" select="'ascending'" />

					<img width="20" src="/images/spacer.gif" />
					<A href="/index.html">
						<img style="vertical-align: middle; border: 0" src="/images/32/Backward_Green.png" />
						Main-Menu
					</A>
					
					<img width="20" src="/images/spacer.gif" />
					<A href="/mbus/mbus.html">
						<img style="vertical-align: middle; border: 0" src="/images/32/Backward_Green.png" />
						MBus-Menu
					</A>
				
					


					<p></p>
					<table class='container' id="bacnet" border="3">
						<tbody class='container'>
							<td>Name</td>
							<td>Addr</td>
							<td>Ident.</td>
							<td>Baud</td>
							<td>Manu.</td>
							<td>Version</td>
							<td>Medium</td>
							<td>Status</td>
							<td>State</td>
							<td>Value</td>
							<td>Units</td>
							<td>Description</td>
							<td>Record_No=BAC_Inst.</td>
							<td>Record_No=Modbus_Addr.</td>
							<td>Records</td>
							<td>Edit</td>

						</tbody>


						<xsl:for-each select="meter">
							<xsl:sort select="*[name(.)=$sortby]" />
							<tr onMouseOver="this.style.background='#FFFF00';" onMouseOut="this.style.background='#FFFFE0';">
								<td>
									<xsl:value-of select="name" />
								</td>
								<td>
									<xsl:value-of select="address" />
								</td>
								<td>
									<xsl:value-of select="identification" />
								</td>
								<td>
									<xsl:value-of select="baudrate" />
								</td>
								<td>
									<xsl:value-of select="manufacture" />
								</td>
								<td>
									<xsl:value-of select="version" />
								</td>
								<td>
									<xsl:value-of select="medium" />
								</td>
								<td>
									<span class="hotspot" onmouseout="tooltip.hide();">
										<xsl:attribute name="onmouseover">tooltip.show('<xsl:value-of
											select="statusDesc" />');</xsl:attribute>
										<xsl:value-of select="status" />
									</span>

								</td>
								<td>
									<xsl:if test="state != 'OK'">
										<xsl:attribute name="style">color: red</xsl:attribute>
									</xsl:if>
									<xsl:value-of select="state" />

								</td>
								<td>
									<xsl:value-of select="wert" />
								</td>
								<td>
									<xsl:value-of select="unit" />
								</td>
								<td>
									<xsl:value-of select="desc" />
								</td>
								<td>
									<xsl:value-of select="bacInst" />
								</td>
								<td>
									<xsl:value-of select="modbusInst" />
								</td>


								<td style="text-align: right">
									<a>

										<xsl:attribute name="href">baccgi?gate=mbus&amp;action=3&amp;index=<xsl:value-of
											select="index" />
                    </xsl:attribute>
										<img style="border:0; padding-right: 2px;" src="/images/16/data_green.png" />
										<xsl:value-of select="records" />
										<img style="border:0;" src="/images/16/edit.png" />
									</a>
								</td>
								<td style="text-align: right">
									<a>

										<xsl:attribute name="href">baccgi?gate=mbus&amp;action=4&amp;index=<xsl:value-of
											select="index" />
                    </xsl:attribute>
										<img style="border:0; padding-right: 8px;" src="/images/16/edit.png" />

									</a>
								</td>



							</tr>
						</xsl:for-each>

					</table>
					<p />
					Total Meters:
					<xsl:value-of select="totalMeters" />

					<p />

				</form>

				<div id="newMeterPanel" class="modal" style="display: none">
					<h3>Add new Meter</h3>
					<form name="addMeter" action="baccgi" method="post">
						<input name="action" value="14" type="hidden" />
						<input name="gate" value="mbus" type="hidden" />

						<table class='container' id="bacnet" cellpadding="4"
							cellspacing="4" border="1">
							<tr>
								<td>
									Meter Address (decimal):
						</td>
								<td>
									<input maxlength="3" id="index" name="index">
									</input>
								</td>
							</tr>
							<tr>
								<td>
									Meter Identification (optional):
						</td>
								<td>
									<input maxlength="8" id="address" name="address">

									</input>
								</td>
							</tr>
						</table>
						<p />
						<input type='submit' value='Save' name="save" />
						<img hspace="10" src="/images/spacer.gif" />
						<input value="Cancel" type="button" onclick="closeModal('newMeterPanel')" />

					</form>
				</div>


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
