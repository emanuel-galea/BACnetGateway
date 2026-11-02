<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	
	<xsl:template mode="admin" match="gateways">

			<script language="Javascript">
					function rebootConfirm() {
						if (confirm ("Do you really	want to reboot the device?")) {
							window.location = "netConfig?reboot=yes";
						}
					}
					function resetConfigConfirm() {
						if (confirm ("Do you really	want to reset the configuration to factory settings?")) {
							window.location = "update?action=7";
						}
					}
			</script>
		
		<div style="width: 280px; margin-left: 15px; float: left">
			<h3>Gateway Administration</h3>
			<p></p>		
			<A href="netConfig" class="btn">
				<img border="0" src="../images/32/node_edit.png" />
				Network Configuration
			</A>
			<A href="bacConfig?action=0" class="btn">
				<img border="0" src="../images/16/bacnetExplorer.png" />
				BACnet Configuration
			</A>
			
			<A href="baccgi?gate=main&amp;action=11" class="btn" >
				<img border="0" src="../images/24/fifteen_pieces.png" />
				Enable Gateways
			</A>
			
		
			<A href="baccgi?gate=mbus&amp;action=16" class="btn">
				<img border="0"  src="../images/24/MBus.png" />
				Configuration
			</A>
			
			<!-- <A href="baccgi?gate=modbusServer&amp;action=1" class="btn">
			<img border="0" width="80" src="/images/24/modbus.jpg" />
				 Server Configuration
			</A> -->
			
			
			<A href="passConfig" class="btn">
				<img border="0" src="../images/24/preferences-desktop-user-password.png" />
				Change Password
			</A>


			<A href="update?action=3" class="btn">
				<img border="0" src="../images/32/utilities-log_viewer.png" />
				View Logs
			</A>

			<A href="baccgi?gate=main&amp;action=9" class="btn">
				<img border="0" src="../images/32/text-x-log.png" />
				Configure Logs
			</A>

			<A href="update" class="btn">
				<img border="0" src="../images/32/box_software.png" />
				Update Software
			</A>

			<A href="baccgi?action=3&amp;gate=main" class="btn">
				<img border="0" src="../images/32/document_certificate.png" />
				Upgrade License
			</A>

			
			<A href="javascript:resetConfigConfirm()" class="btn">
				<img border="0" src="../images/32/system-config-boot.png" />
				Reset Configuration
			</A>
			
			<A href="javascript:rebootConfirm()" class="btn">
				<img border="0" src="../images/32/system-reboot.png" />
				Reboot Device
			</A>
			
			<A href="/index.html" class="btn">
				<img style="border: 0; vertical-align: middle" src="/images/32/Backward_Green.png" />
				Main-Menu
			</A>
		</div>
	</xsl:template>
</xsl:stylesheet>


