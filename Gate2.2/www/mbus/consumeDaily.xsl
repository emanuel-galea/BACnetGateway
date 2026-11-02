

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="html" encoding="ISO-8859-1"/>
	<xsl:template match="meters">
		<html>
			<head xmlns="http://www.w3.org/1999/xhtml">
				<title>M-Bus:BACnet Gateway</title>
				<link rel="stylesheet" href="../css/wine.css"></link>
				<link rel="shortcut icon" href="/images/32/logo_32.png"></link>

			</head>
			<script language="javascript" src="/js/datetimepicker.js" />


			<body style="margin-top: 10px;">
					

				<form name="consume" action="readMeters" method="post">
					<input name="action" value="12" type="hidden" />
					<input name="gate" value="mbus" type="hidden" />
					<input name="export" value="0" type="hidden" />


					<h2>
						<img border="0" src="/images/32/data_yellow.png" />
						Meters <xsl:value-of select="title" /> Consumption Report
					</h2>
					<p />
					<div style="color: red; font-weight: bold">
						<xsl:value-of select="message" />
						<p />
					</div>

					From:  <xsl:value-of select="fromDate" />

					<img hspace="20" src="/images/spacer.gif" />
					To:	<xsl:value-of select="toDate" />

					<img hspace="20" src="/images/spacer.gif" />
					Sort by: <xsl:value-of select="sortBy" />
					
					<img hspace="20" src="/images/spacer.gif" />
					Medium:	<xsl:value-of select="medium" />
						
					<img hspace="30" src="/images/spacer.gif" />					
					<input type='button'
						onclick="window.location.href='baccgi?gate=mbus&amp;action=12'; return false"
						value='Back' />
					<br></br>


					<p />
					<table class='container' id="bacnet" cellspacing="4" border="3">
						<tbody class='container'>
							<td>Name</td>
							<td>Address</td>
							<td>Medium</td>
							<td>Consume</td>
							<td>Units</td>
							<td>Date</td>
							
						</tbody>
						<xsl:for-each select="meter">
						
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


								<td style="text-align: right">
									<xsl:value-of select="value" />
								</td>
								<td>
									<xsl:value-of select="unit" />
								</td>
								<td>
									<xsl:value-of select="date" />
								</td>
							</tr>
						</xsl:for-each>

					</table>
					<p />
					
				</form>

			</body>
		</html>
	</xsl:template>


</xsl:stylesheet>
