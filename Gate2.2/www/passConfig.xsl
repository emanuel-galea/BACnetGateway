<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:include href="../adminPart.xsl" />

	<xsl:template match="root">
		<html>
			<head xmlns="http://www.w3.org/1999/xhtml">
				<TITLE>M-Bus:BACnet Gateway</TITLE>
				<link rel="stylesheet" href="../css/wine.css"></link>
				<link rel="shortcut icon" href="/images/32/logo_32.png"></link>

				<script>
				//	<![CDATA[
					function checkPasswords()
					{
					var txt_error_pwd = "Your asspasswords are not equal. Please try again!";
					// initialize some
					variables:
					var ds_pwd = document.getElementById("pwd");
					var ds_repwd
					= document.getElementById("repwd");
					if (ds_pwd.value.length == 0) {
					alert("Password is empty!");
					ds_pwd.value = "";
					ds_repwd.value = "";
					return false;
					}
					if ( ds_pwd.value == ds_repwd.value ) {
					return true;
					}
					else {
					alert( txt_error_pwd );
					ds_pwd.value = "";
					ds_repwd.value = "";
					return false;
					}
					}
				 // ]]>
				</script>
			</head>
			<body >
				<table >
					<tr>
						<td style="vertical-align: top">
							<xsl:apply-templates mode="admin" select="gateways" />
						</td>
						<td style="Vertical-align: top">
							<div class="shadow">
								<h2>
									<img style="vertical-align: middle; border: 0; height: 32px"
										src="../images/24/preferences-desktop-user-password.png" />
									Password Configuration
								</h2>

								<p />
								<xsl:if test="error='1'">
									<div class="shadow"
										style="margin: auto; color: red; font-weight: bold; font-size: large; border-width: 2px; border-style: solid; width: 600px">
										<xsl:value-of select="message" />
									</div>

								</xsl:if>
								<xsl:if test="error='0'">
									<div class="shadow"
										style="margin: auto; color: green; font-weight: bold; font-size: large; border-width: 2px; border-style: solid;width: 600px;">
										<xsl:value-of select="message" />
										<br></br>
									</div>
								</xsl:if>

								<form method="GET" action='passConfig'>
									<table class='container' width="50%" cellpadding="4"
										cellspacing="8">
										<tbody class='container'>
											<td colspan="3">Change Password</td>
										</tbody>
										<tr class='spacer'>
											<td colspan="3"></td>
										</tr>

										<tr >
											
											<td>For user:</td>
											<td>
												<select size="1" name="forUser">
													<option>admin</option>
													<option>user</option>
													<option>demo</option>
												</select>
											</td>

										</tr>


										<tr>											
											<td>
												<label for="pwd">New Password</label>
											</td>
											<td>
												<input id="pwd" name="password" type='password' value="" />
											</td>
											<td class='right'></td>
										</tr>
										<tr>
											
											<td>
												<label for="repwd">Repeat New password</label>
											</td>
											<td>
												<input id="repwd" name="repeatPassword" type="password"
													value="" />
											</td>
											<td class='right'></td>
										</tr>
										<tr class='spacer'>
											<td colspan="3"></td>
										</tr>

									</table>
									<p />
									<input type='submit' onclick='return checkPasswords();'
										value='Save' />
									
								</form>
							</div>
						</td>
					</tr>
				</table>
			</body>
		</html>
	</xsl:template>
</xsl:stylesheet>
