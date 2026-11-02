function initialize() {
  var xmlDoc
  var xslDoc

  xmlDoc = new ActiveXObject('Microsoft.XMLDOM')
  xmlDoc.async = false;

  xslDoc = new ActiveXObject('Microsoft.XMLDOM')
  xslDoc.async = false;

  xmlDoc.load("tree/tree.xml")
  xslDoc.load("tree/tree.xsl")

  folderTree.innerHTML = xmlDoc.documentElement.transformNode(xslDoc)
}

function clickOnEntity(entity) {
  if(entity.open == "false") {
    expand(entity, true)
  }
  else {
    collapse(entity)
  }
  window.event.cancelBubble = true
}

function expand(entity) {
  var oImage

  oImage = entity.childNodes(0).all["image"]
  oImage.src = entity.imageOpen

  for(i=0; i < entity.childNodes.length; i++) {
    if(entity.childNodes(i).tagName == "DIV") {
      entity.childNodes(i).style.display = "block"
    }
  }
  entity.open = "true"
}

function collapse(entity) {
  var oImage
  var i

  oImage = entity.childNodes(0).all["image"]
  oImage.src = entity.image

  // collapse and hide children
  for(i=0; i < entity.childNodes.length; i++) {
      if(entity.childNodes(i).tagName == "DIV") {
        if(entity.id != "folderTree") entity.childNodes(i).style.display = "none"
        collapse(entity.childNodes(i))
      }
    }
  entity.open = "false"
}

function expandAll(entity) {
  var oImage
  var i

  expand(entity, false)

  // expand children
  for(i=0; i < entity.childNodes.length; i++) {
    if(entity.childNodes(i).tagName == "DIV") {
      expandAll(entity.childNodes(i))
    }
  }
}
