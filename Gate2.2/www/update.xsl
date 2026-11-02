<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exslt="http://exslt.org/common"
	extension-element-prefixes="exslt">
	<xsl:output method="html" encoding="ISO-8859-1" />

	<xsl:include href="../adminPart.xsl" />
	
	<xsl:template match="root">
		<HTML>
			<HEAD>
				<title>M-Bus:BACnet Gateway</title>
				<link rel="stylesheet" href="../css/wine.css"></link>
				<link rel="shortcut icon" href="/images/32/logo_32.png"></link>

			</HEAD>
			<body>
				<table style="width: 100%">
					<tr>
						<td style="vertical-align: top">
							<xsl:apply-templates mode="admin" select="gateways" />
						</td>
						<td style="width: 100%; Vertical-align: top">

							<div class="shadow">
								<form name="upload" action="update" enctype="MULTIPART/FORM-DATA"
									method="post">
									<p />
									
									<H2>
										<img border="0" src="../images/32/box_software.png" />
											Software Update
									</H2>

									<p />
										<br />
										Update File:
										<input type="file" size="80%" name="filename" value="firmware.zip" />
											<p />
												<input type='submit' style="width: 120px" value='Update'
													name="update" />
												
												<p />
												<br />

								</form>
							</div>
						</td>
					</tr>
				</table>
			</body>
		</HTML>
	</xsl:template>
</xsl:stylesheet>
