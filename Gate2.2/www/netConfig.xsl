<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


	<xsl:include href="../adminPart.xsl" />

	<xsl:template match="configuration">
		<html>

			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
				<meta http-equiv="Content-Script-Type" content="text/javascript" />
				<title>M-Bus:BACnet Gateway</title>
				<link rel="stylesheet" href="/css/wine.css" />
				<link rel="shortcut icon" href="/images/32/logo_32.png"></link>

				<script type='text/javascript' src="/js/chm.js"></script>
				<script type='text/javascript' src="/js/validate.js"></script>
				<script language="Javascript">

					setInterval("settime()", 1000);

					function settime () {
					var elem = document.getElementById("browser_time");
					var now = new Date(); 
                    var now_utc = new Date(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate(),  now.getUTCHours(), now.getUTCMinutes(), now.getUTCSeconds())
					elem.innerHTML = now_utc.toLocaleString();
					document.date.epoch.value = parseInt(now.getTime() / 1000);
					}

					function setEpochTime (deviceTime) {
					var elem = document.getElementById("device_time");
					var now = new Date (deviceTime * 1000);
					var now_utc = new Date(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate(),  now.getUTCHours(), now.getUTCMinutes(), now.getUTCSeconds())
					
					elem.innerHTML = now_utc.toLocaleString();
					}

</script>

			</head>


			<body onload="settime" >
				<table style="width: 100%">
					<tr>
						<td style="vertical-align: top">
							<xsl:apply-templates mode="admin" select="gateways" />
						</td>
						<td style="width: 100%; Vertical-align: top">

							<div class="shadow" >
								<h3>
									<img style="vertical-align: middle; border: 0" src="/images/32/node_edit.png" />
									Network Configuration
								</h3>

								<div style="color: red">Attention: If you change any of these settings,
									it is possible
									that Gateway can not be reached any more!
			</div>

								<div style="color: red; font-weight: bold">
									<xsl:value-of select="message" />
								</div>
								
								
								
								Logged in User:
								<xsl:value-of select="remoteUser" />
								<p />


								<form method='GET' action='netConfig'>

									<table class='container' width="60%" id="netconf">
										<tbody class='container'>
											<td>
												<img border="0" src="/images/32/node_edit.png" />
											</td>
											<td colspan="2">
												Network Configuration
							</td>
											<td class='right'></td>
										</tbody>
										<tr class='spacer'>
											<td></td>
											<td></td>
											<td></td>
											<td></td>
										</tr>
										<tr>
											<td class='icon'></td>
											<td>
												Hostname:
							</td>
											<td>
												<input type='text' name='hostName'>
													<xsl:attribute name="value">
                        <xsl:value-of select="hostName" />
                         </xsl:attribute>
												</input>

											</td>
											<td class='right'></td>
										</tr>
										<tr>
											<td class='icon'></td>
											<td>IP-Address:</td>
											<td>
												<input type='text' name='ipAddress' onchange='validate(this.value)'>
													<xsl:attribute name="value">
                        <xsl:value-of select="ipAddress" />
                         </xsl:attribute>
												</input>
											</td>
											<td class='right'></td>
										</tr>
										<tr>
											<td class='icon'></td>
											<td>Subnetmask:</td>
											<td>
												<input type='text' name='netMask' onchange='validate(this.value)'>
													<xsl:attribute name="value">
                        <xsl:value-of select="netMask" />
                         </xsl:attribute>
												</input>
											</td>
											<td class='right'></td>
										</tr>
										<tr>
											<td class='icon'></td>
											<td>Default gateway:</td>
											<td>
												<input type='text' name='gateway' onchange='validate(this.value)'>
													<xsl:attribute name="value">
                        <xsl:value-of select="gateway" />
                         </xsl:attribute>
												</input>
											</td>
											<td class='right'></td>
										</tr>
										<tr>
											<td class='icon'></td>
											<td>Domain Name Server:</td>
											<td>
												<input type='text' name='nameServer' onchange='validate(this.value)'>
													<xsl:attribute name="value">
                        <xsl:value-of select="nameServer" />
                         </xsl:attribute>
												</input>
											</td>
											<td class='right'></td>
										</tr>
										
										<tr>
											<td class='icon'></td>
											<td>Mac Address:</td>
											<td>
												<xsl:value-of select="macAddress" />
											</td>
											<td class='right'></td>
										</tr>
										<tr class='spacer'>
											<td></td>
											<td></td>
											<td></td>
											<td></td>
										</tr>

										<tr class='spacer'>
											<td></td>
											<td></td>
											<td></td>
											<td></td>
										</tr>
									</table>
									<p />
									<input type='submit' style="width: 120px" onclick='return validatePage();'
										value='Save' />
									<img hspace="10" src="/images/spacer.gif" />
									
								</form>

								<p />
								<br />

								<form method='GET' name='date' action='netConfig'>
									<table class='container' width="60%" id="netconf">
										<tbody class='container'>
											<td>
												<img border="0" src="/images/32/player-time.png" />
											</td>
											<td colspan="2">
												Date-Time Synchronization
							</td>
											<td class='right'></td>
										</tbody>
										<tr class='spacer'>
											<td></td>
											<td></td>
											<td></td>
											<td></td>
										</tr>
										<tr>
											<td class='icon'></td>
											<td>
												Device Date-Time (UTC):
							</td>
											<td>
												<span id='device_time'></span>
											</td>
											<td class='right'></td>
										</tr>
										<tr>
											<td class='icon'></td>
											<td>Browser Date-Time (UTC):</td>
											<td>
												<span id='browser_time' name='browser_time'></span>

											</td>
											<td class='right'></td>
										</tr>

									</table>
									<p />
									<input type='submit' name="synchronize" style="width: 120px"
										value='Syncronize' />
									<img hspace="10" src="/images/spacer.gif" />
									<input id="epoch" name="epoch" type="hidden" />

								</form>
								<script>
									setEpochTime(parseInt(
									<xsl:value-of select="epoch" />
									));
								</script>
							</div>
						</td>
					</tr>
				</table>

			</body>
		</html>
	</xsl:template>

</xsl:stylesheet>
