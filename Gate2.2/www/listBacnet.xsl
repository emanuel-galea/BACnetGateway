<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:template match="bacnet">
		<html>
			<head xmlns="http://www.w3.org/1999/xhtml">
				<title>BACnet Gateway - Devices</title>
				<link rel="stylesheet" href="../css/wine.css"></link>
				<link rel="shortcut icon" href="/images/32/logo_32.png"></link>
			</head>
			<body style="margin-top: 5px;">

				<form action="baccgi" method="post">
					<input name="action" value="8" type="hidden" />
					<input name="gate" value="main" type="hidden" />
					<input name="export" value="0" type="hidden" />
					<span class="titleField">
						<img style="border: 0;" src="/images/32/bacnet.png" />

						BACnet Objects
					</span>
					<br />
					
					<p />
					<div style="color: red; font-weight: bold">
						<xsl:value-of select="message" />
						<p />
					</div>
					
					<A href="/cgi/baccgi?gate=main&amp;action=8&amp;export=0&amp;bacnet=on">
						<img style="vertical-align: middle; border: 0; text-align: left"
							src="/images/32/view-refresh-4.png" />
						Refresh
					</A>

					<img hspace="10" src="/images/spacer.gif" />

					<A href="/cgi/baccgi?gate=main&amp;action=8&amp;export=1">
						<img style="vertical-align: middle; border: 0; text-align: left"
							src="/images/32/excel.png" />
						Export</A>
					<img hspace="10" src="/images/spacer.gif" />
	
					Sort by:
					<xsl:call-template name="selectBox">
						<xsl:with-param name="option1" select="'sortOption'" />
						<xsl:with-param name="value1" select="/bacnet/sortValue" />
					</xsl:call-template> 
					
					<p></p>
					
						<table class='container' id="bacnet" border="3">
							<tbody class='container'>
								<td>Name</td>
								<td>Type</td>
								<td>Instance</td>
								<td>Gateway</td>
								<td>Description</td>
								<td>Value</td>
								<td>Status</td>
								

							</tbody>

							<xsl:variable name="sortby" select="sortBy" />
							<xsl:variable name="sortorder" select="'ascending'" />

							<xsl:for-each select="object">
								<xsl:sort select="*[name(.)=$sortby]" order="{$sortorder}" />
								<xsl:sort select="instance" order="ascending" />
								<tr onMouseOver="this.style.background='#FFFF00';"
									onMouseOut="this.style.background='#FFFFE0';">
									<td>
										<xsl:value-of select="name" />
									</td>
									<td>
										<xsl:value-of select="type" />
									</td>
									<td style="text-align: right">
										<xsl:value-of select="instance" />
									</td>

									<td>
										<xsl:value-of select="gateway" />
									</td>
									<td>
										<xsl:value-of select="desc" />
									</td>
									<td style="text-align: right">
										<xsl:value-of select="value" />
									</td>
									<td>
										<xsl:if test="status != 'OK'">
											<xsl:attribute name="style">color: red;font-weight: strong</xsl:attribute>
										</xsl:if>
										<xsl:value-of select="status" />

									</td>
									
								</tr>
							</xsl:for-each>

						</table>
						<p />
						Total BACnet Objects:
						<xsl:value-of select="totalObjects" />
					

					<p />


				</form>

			</body>
		</html>
	</xsl:template>

		<xsl:template name="selectBox">
		<xsl:param name="option1" />
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
