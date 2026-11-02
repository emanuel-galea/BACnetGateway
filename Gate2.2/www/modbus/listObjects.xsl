<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:template match="modbus">
		<html>
			<head xmlns="http://www.w3.org/1999/xhtml">
				<title>Modbus:BACnet Gateway - Objects</title>
				<link rel="stylesheet" href="../css/wine.css"></link>
				<link rel="shortcut icon" href="/images/32/logo_32.png"></link>

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

				function changed (objectName, index, index2, wert) {
				document.getElementById('pindex').value = index;
				document.getElementById('pindex2').value = index2;
				document.getElementById('objectName').innerHTML = objectName;
				document.getElementById('address').value = wert;
				openModal('changePanel');
					
				}
														
				 // ]]>
				</script>


			</head>
			<body style="margin-top: 5px;">
				<div id="shade" class="shade"></div>
				<form action="baccgi" method="post">
					<input name="action" value="3" type="hidden" />
					<input name="gate" value="modbus" type="hidden" />
					<input name="export" value="0" type="hidden" />
					<input name="index2" id="index2" value="-1" type="hidden" />
					<input name="index" id="index" value="-1" type="hidden" >
						<xsl:attribute name="value">
                             <xsl:value-of select="index" />
                         </xsl:attribute>
                    </input>     
					<span class="titleField">
						<img border="0" src="/images/32/objects.png" />
						Modbus Objects
						<xsl:value-of select="device" />
					</span>
					<br />

					<div style="color: red; font-weight: bold">
						<xsl:value-of select="message" />
						<p />
					</div>


					<xsl:choose>
						<xsl:when test="index != '-1'">
							<img style="width: 10px" src="/images/spacer.gif" />
							<input type='submit' onclick="this.form.action.value = 3; return true"
								value='Add New Object' />
						</xsl:when>

					</xsl:choose>


					<img style="width: 10px" src="/images/spacer.gif" />
					<input type='submit' value='Read All'
						onclick="this.form.action.value = 1; return true" />
					<img style="width: 10px" src="/images/spacer.gif" />

					<input type='submit'
						onclick="this.form.export.value = 1; this.form.action.value = 1; return true"
						value='Export to Excel' />
					<img style="width: 10px" src="/images/spacer.gif" />

					Sort by:
					<xsl:call-template name="selectBox">
						<xsl:with-param name="option1" select="'sortOption'" />
						<xsl:with-param name="value1" select="/modbus/sortValue" />
					</xsl:call-template>

					<img style="width: 10px" src="/images/spacer.gif" />


					<A href="/cgi/baccgi?gate=modbus&amp;action=0">
						<img style="vertical-align: middle; border: 0" src="/images/32/Backward_Yellow.png" />
						List Devices
					</A>
					<img style="width: 5px" src="/images/spacer.gif" />
					<A href="/index.html">
						<img style="vertical-align: middle; border: 0" src="/images/32/Backward_Green.png" />
						Main-Menu
					</A>



					<p></p>

					<table class='container' id="bacnet" border="3">
						<tbody class='container'>
							<td>Name</td>
							<td>Device</td>
							<td>Modbus-Type</td>
							<td>Modbus-BitNo</td>
							<td>Address</td>
							<td>BACnet-Object</td>
							<td>BACnet Inst.</td>
							<td>Read Interv.</td>
							<td>Value</td>
							<td>Unit</td>
							<td>Status</td>
							<td>Edit</td>

						</tbody>

						<xsl:variable name="sortby" select="sortBy" />
						<xsl:variable name="sortorder" select="'ascending'" />

						<xsl:for-each select="object">
							<xsl:sort select="*[name(.)=$sortby]" order="{$sortorder}" />

							<tr onMouseOver="this.style.background='#FFFF00';" onMouseOut="this.style.background='#FFFFE0';">
								<td>
									<xsl:value-of select="name" />
								</td>
								<td>
									<xsl:value-of select="device" />
								</td>
								<td>
									<xsl:value-of select="type" />
								</td>
								<td>
									<xsl:value-of select="bitNo" />
								</td>

								<td>
									<xsl:value-of select="address" />
								</td>
								<td>
									<xsl:value-of select="bacType" />
								</td>
								<td>
									<xsl:value-of select="bacInst" />
								</td>

								<td style="text-align: right;">
									<xsl:value-of select="interval" />
								</td>

								<td style="text-align: right;">
									<span style="padding-right: 5px">
										<xsl:value-of select="wert" />
									</span>
									
								</td>
								<td>
									<xsl:value-of select="unit" />
								</td>
								<td>
									<xsl:if test="status != 'OK'">
										<xsl:attribute name="style">color: red</xsl:attribute>
									</xsl:if>
									<xsl:value-of select="status" />

								</td>
								
								

								<td style="text-align: right">
									<a>
										<xsl:attribute name="href">baccgi?gate=modbus&amp;action=3&amp;index=<xsl:value-of
											select="index" />&amp;index2=<xsl:value-of
											select="index2" />
                                        </xsl:attribute>
										<img style="border:0;" src="/images/16/edit.png" />
									</a>
								</td>


							</tr>
						</xsl:for-each>

					</table>
					<p />
					Total Objects:
					<xsl:value-of select="totalObjects" />
				</form>

				<div id="changePanel" class="modal" style="display: none">
					<h3>Write Value</h3>
					<form name="changeValue" action="baccgi" method="post">
						<input name="action" value="9" type="hidden" />
						<input name="gate" value="modbus" type="hidden" />
						<input name="index2" id="pindex2" value="-1" type="hidden" />
						<input name="index" id="pindex" value="-1" type="hidden"  />
										
						<table class='container' cellpadding="4" cellspacing="4"
							border="1">
							<tr>
								<td>
									Object Name:
						</td>
								<td>
									<span id="objectName"></span>
								</td>
							</tr>
							<tr>
								<td>
									Value:
						</td>
								<td>
									<input maxlength="8" id="address" name="address">

									</input>
								</td>
							</tr>
						</table>
						<p />
						<input type='submit' name="save" value='Write' />
						<img hspace="10" src="/images/spacer.gif" />
						<input value="Cancel" type="button" onclick="closeModal('changePanel')" />

					</form>
				</div>
				
		



			</body>
		</html>
	</xsl:template>

	<xsl:template name="selectBox">
		<xsl:param name="option1">
			A.
		</xsl:param>
		<xsl:param name="value1" />
		<select size="1" name="{$option1}" id="{$option1}">
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
