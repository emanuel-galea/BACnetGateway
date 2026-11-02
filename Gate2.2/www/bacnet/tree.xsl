<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="1.0">
	<xsl:output method="html"></xsl:output>
	<xsl:template match="/">
		<html>
			<head>
				<title>BACnet Browser</title>

				<link rel="stylesheet" type="text/css" href="../bacnet/xmlTree.css" />
				<script type="text/javascript" src="/bacnet/xmlTree.js" />

			</head>
			<body>
				<div id="divLeft" style="overflow:auto; height: 650px;">
					<span class="titleField">BACnet Browser</span>
					<hr></hr>
					<A href="/index.html">
						<img style="vertical-align: middle; border: 0" src="/images/32/Backward_Green.png" />
						Main-Menu
					</A>
					<hr></hr>
					<xsl:apply-templates />
				</div>

				<div id="divRight">
					<iframe id="icontent" src=""></iframe>
				</div>

			</body>
		</html>
	</xsl:template>

	<xsl:template match="root">
		<body>
			<xsl:apply-templates />
		</body>
	</xsl:template>

	<xsl:template match="device">
		<span class="trigger">
			<xsl:attribute name="onClick">
showBranch('<xsl:value-of select="@id" />');
</xsl:attribute>
			

			<a>
				<xsl:attribute name="href">javascript:showLeft("baccgi?gate=main&amp;action=8&amp;");
</xsl:attribute>
				<img style="border: 0; padding: 0px; vertical-align: middle">
					<xsl:attribute name="src">/images/16/<xsl:value-of
						select="name" />.png
				</xsl:attribute>

				</img>
				<xsl:value-of select="name" />
			</a>

			<br />
		</span>
		<span class="branch">
			<xsl:attribute name="id">
<xsl:value-of select="@id" />
</xsl:attribute>
			<xsl:apply-templates />
		</span>
	</xsl:template>



	<xsl:template match="type">
		<span class="trigger">

			<img style="border: 0; padding: 2px; vertical-align: middle" src="/images/16/arrow-down-3.png">
				<xsl:attribute name="id">I<xsl:value-of
					select="@id" /></xsl:attribute>
				<xsl:attribute name="onClick">
showBranch('<xsl:value-of select="@id" />');
</xsl:attribute>
			</img>

			<a>
				<xsl:attribute name="href">javascript:showLeft("baccgi?gate=main&amp;action=8&amp;index=
<xsl:value-of select="@id" />");
</xsl:attribute>
				<img style="border: 0; padding: 2px; vertical-align: middle">
					<xsl:attribute name="src">/images/16/<xsl:value-of
						select="name" />.png
				</xsl:attribute>

				</img>
				<xsl:value-of select="name" />
			</a>
		</span>


		<span class="branch">
			<xsl:attribute name="id">
<xsl:value-of select="@id" />
</xsl:attribute>
			<xsl:apply-templates />
		</span>
	</xsl:template>



	<xsl:template match="object">
		<img
			style="width: 10px; border: 0; padding-right: 4px; vertical-align: middle"
			src="/images/16/draw-circle.png" />
		<xsl:if test="status != '0'">
			<img src="/images/16/system-error-alt-02.png" style="vertical-align: middle; height: 16px;" />
		</xsl:if>
		<a>
			<xsl:attribute name="href">javascript:showLeft("baccgi?gate=main&amp;action=13&amp;
<xsl:value-of select="link" />")
</xsl:attribute>
			<xsl:value-of select="name" />
		</a>

		<br />
	</xsl:template>


	<!-- avoid output of text node with default template -->
	<xsl:template match="name" />

</xsl:stylesheet>
