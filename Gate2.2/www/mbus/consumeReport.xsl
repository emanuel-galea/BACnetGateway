

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="html" encoding="ISO-8859-1" />
	<xsl:template match="meters">
		<html>
			<head xmlns="http://www.w3.org/1999/xhtml">
				<title>M-Bus:BACnet Gateway</title>
				<link rel="stylesheet" href="../css/wine.css"></link>
				<link rel="shortcut icon" href="/images/32/logo_32.png"></link>

			</head>
			<script language="javascript" src="/js/datetimepicker.js" />

			<script language="javascript">
				//	<![CDATA[
				function change()     {
				document.consume.output.value ='1';
				document.consume.submit();
				}
								
				 // ]]>

			</script>

			<body style="margin-top: 10px;">

				<form name="consume" action="baccgi" method="post">
					<input name="action" value="12" type="hidden" />
					<input name="gate" value="mbus" type="hidden" />
					<input name="export" value="0" type="hidden" />


					<h2>
						<img border="0" src="/images/32/data_yellow.png" />
						Meters Consumption Report
					</h2>
					! Attention: No warranty on consume reports
					<p />
					<div style="color: red; font-weight: bold">
						<xsl:value-of select="message" />
						<p />
					</div>

					<table style="margin: auto;border: 0px; text-align: left"
						cellspacing="4">
						<tr>
							<td>
								From:
							</td>
							<td>
								<div>
									<input id="fromDate" name="date1" type="text" size="10">

										<xsl:attribute name="value">
                        			<xsl:value-of select="fromDate" />
                    				</xsl:attribute>
									</input>
									<a href="javascript:NewCal('fromDate','ddmmyyyy')">
										<img src="/images/cal.gif" width="16" height="16" border="0"
											alt="Pick a date" />
									</a>
								</div>
							</td>
						</tr>
						<tr>
							<td>
								To:
							</td>
							<td>
								<div>
									<input id="toDate" name="date2" type="text" size="10">

										<xsl:attribute name="value">
                        			<xsl:value-of select="toDate" />
                    				</xsl:attribute>
									</input>
									<a href="javascript:NewCal('toDate','ddmmyyyy')">
										<img src="/images/cal.gif" width="16" height="16" border="0"
											alt="Pick a date" />
									</a>
								</div>
							</td>
						</tr>
						<tr>
							<td>
								Sort by:
							</td>
							<td>
								<xsl:call-template name="selectBox">
									<xsl:with-param name="option1" select="'sortOption'" />
									<xsl:with-param name="value1" select="/meters/sortValue" />
								</xsl:call-template>
							</td>
						</tr>
						<tr>
							<td>
								Medium:
							</td>
							<td>
								<xsl:call-template name="selectBox">
									<xsl:with-param name="option1" select="'mediumOption'" />
									<xsl:with-param name="value1" select="/meters/mediumValue" />
								</xsl:call-template>
							</td>
						</tr>
						<tr>
							<td>
								Type:
							</td>
							<td>
								<xsl:call-template name="selectBox">
									<xsl:with-param name="option1" select="'typeOption'" />
									<xsl:with-param name="value1" select="/meters/typeValue" />
								</xsl:call-template>
							</td>
						</tr>


					</table>
					
					<xsl:variable name="sortby" select="sortBy" />
					<xsl:variable name="sortorder" select="'ascending'" />

					<div
						style="margin: auto;border: solid 2px; padding : 4px;width: 500px; height: 260px; overflow : auto; ">
						<table class='container' id="bacnet" cellspacing="4" border="3"
							width="100%">
							<tbody class='container'>
								<td>Name</td>
								<td>Address</td>
								<td>Medium</td>
								<td>Select</td>
							</tbody>
							<xsl:for-each select="meter">
							<xsl:sort select="*[name(.)=$sortby]"  />
								<tr>
									<td>
										<xsl:value-of select="name" />
									</td>
									<td>
										<xsl:value-of select="address" />
									</td>
									<td>
										<xsl:value-of select="medium" />
									</td>
									<td style="text-align: center">
										<input type='checkbox'>
											<xsl:attribute name="name">_inst_<xsl:value-of select="index"/>
												
                     					</xsl:attribute>
											<xsl:if test="checked ='y'">
												<xsl:attribute name="checked">
					    	<xsl:value-of select="'checked'" />
			         		</xsl:attribute>
											</xsl:if>
										</input>
									</td>
								</tr>
							</xsl:for-each>
						</table>
					</div>
					<p />

					<a
						href="javascript:document.consume.export.value = '2'; document.consume.submit();">
						<img style="border: 0" src="/images/32/table2.png" />
						Display Table
					</a>

					<img hspace="15" src="/images/spacer.gif" />

					<a
						href="javascript:document.consume.export.value = '4'; document.consume.submit();">
						<img style="border: 0" src="/images/32/excel.png" />
						Export to Excel
					</a>


					<img hspace="15" src="/images/spacer.gif" />

					<a
						href="javascript:document.consume.export.value = '3'; document.consume.submit();">
						<img style="border: 0" src="/images/32/chart_line.png" />
						Chart
					</a>


					<p />

					<input type='button'
						onclick="window.location.href='../index.html'; return false"
						value='Main Menu' />
					<br></br>


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
