<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="html" encoding="ISO-8859-1"/>
	<xsl:template match="records">
		<html>
			<head xmlns="http://www.w3.org/1999/xhtml">
				<title>M-Bus:BACnet Gateway</title>
				<link rel="stylesheet" href="../css/wine.css"></link>
				<link rel="shortcut icon" href="/images/32/logo_32.png"></link>

			</head>
			
			<script language="javascript">
				//	<![CDATA[
				function send(record)     {
				document.records.index2.value = record;
				document.records.submit();
				}
								
				 // ]]>

			</script>
			<body style="margin-top: 20px;">
				<p />
				<h2><img style="vertical-align: middle; border: 0" src="/images/48/logo_48.png"/> Kara Systems</h2>
				<H2>Records for Meter: <img border="0" hspace="4" src="/images/24/gauge2.png" /> <xsl:value-of select="meter" /></H2>
				<div style="color: green;font-weight: bold">
					<xsl:value-of select="message" />
				</div>
			    <p /> 
			    <div style="color: red; font-weight: bold"> <xsl:value-of select="errorMessage" />
				</div>
				<form name="records" action="baccgi" method="post">
					<input name="action" value="6" type="hidden" />
					<input name="gate" value="mbus" type="hidden" />
					<input name="index2" type="hidden" />
					<input name="index" type="hidden" >
					<xsl:attribute name="value">
                        			<xsl:value-of select="meterIndex" />
                    </xsl:attribute>
					</input>

				<table class='container' id="bacnet" cellpadding="2"
						cellspacing="2" border="3">
						<tbody class='container'>
							<td>No.</td>
							<td>Value</td>
							<td>Unit</td>
							<td>Description</td>
							<td>Function</td>
							<td>Sub-Unit</td>
							<td>Storage No.</td>
							<td>Tariff</td>
							<td>BACnet Inst.</td>
							<td>Modbus Addr.</td>
							<td>Edit</td>
																			
						</tbody>
				<xsl:for-each select="record">
				<tr onMouseOver="this.style.background='#FFFF00';" onMouseOut="this.style.background='#FFFFE0';" >
				<td style="text-align: right">
					<xsl:number value="position()" format="1"/>
				</td>
				<td style="text-align: right">
					<xsl:value-of select="value" />
				</td>
				<td>
					<xsl:value-of select="unit" />
				</td>
				<td>
					<xsl:value-of select="description" />
				</td>
				<td>
					<xsl:value-of select="function" />
				</td>
				<td style="text-align: right">
					<xsl:value-of select="subUnit" />
				</td>
				<td style="text-align: right">
					<xsl:value-of select="storage" />
				</td>
				<td style="text-align: right">
					<xsl:value-of select="tariff" />
				</td>
				
				<td style="text-align: center" >
					<xsl:value-of select="bacInst" />
				</td>
				<td style="text-align: center" >
					<xsl:value-of select="modbusAddr" />
				</td>
				
								
				<td style="text-align: right">
					<a >
					<xsl:attribute name="href">javascript:send(<xsl:number value="position()" format="1"/>);
                    </xsl:attribute>
                    <img style="border:0; padding-right: 8px;" src="/images/16/edit.png" />
                   			
					</a>
				</td>
				
				</tr>
			</xsl:for-each>

					</table>
					
					
					<p />
					
					
					<img hspace= "10" src="/images/spacer.gif" />
					
					<input type='button' 
						value='Refresh' >
					<xsl:attribute name="onclick">window.location.href='baccgi?gate=mbus&amp;action=3&amp;index=<xsl:value-of select="meterIndex"/>'; return false</xsl:attribute>	
					</input>
					<img hspace= "10" src="/images/spacer.gif" />
						
					<input type='button' value='Next >>' >
					<xsl:attribute name="onclick">window.location.href='baccgi?gate=mbus&amp;action=3&amp;index=<xsl:value-of select="meterIndex + 1"/>'; return false</xsl:attribute>	
						
					</input>
					<img hspace= "10" src="/images/spacer.gif" />	
					<input type='button' value="&lt;&lt; Back" >
					<xsl:attribute name="onclick">window.location.href='baccgi?gate=mbus&amp;action=3&amp;index=<xsl:value-of select="meterIndex - 1"/>'; return false</xsl:attribute>	
						
					</input>	
							
					<img hspace= "10" src="/images/spacer.gif" />	
					
					<A href="baccgi?gate=mbus&amp;action=1">
						<img style="vertical-align: middle; border: 0" src="/images/32/Backward_Yellow.png" />
						back to Meter List
					</A>
					
		
</form>
			</body>
		</html>
	</xsl:template>
	
	

</xsl:stylesheet>
