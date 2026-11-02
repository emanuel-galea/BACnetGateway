var openImg = new Image();
openImg.src = "/images/16/arrow-down-3.png";
var closedImg = new Image();
closedImg.src = "/images/16/arrow-right-3.png";

function showBranch(branch){
	var objBranch = document.getElementById(branch).style;
	var imgId = 'I' + branch;
	objImg = document.getElementById(imgId);
	if(objBranch.display=="block") {
		objBranch.display="none";
		objImg.src = closedImg.src;
	} else { 
		objBranch.display="block";
		objImg.src = openImg.src;
	}
}

function swapFolder(img){
	objImg = document.getElementById(img);
	if(objImg.src.indexOf('right')>-1)
		objImg.src = openImg.src;
	else
		objImg.src = closedImg.src;
}

function showLeft(link) {
	ref = document.getElementById('icontent');
	ref.src = link;
}



function setHeight() {
	var availableHeight = 0;

	if (document.all)
		availableHeight = document.body.clientHeight;
	else
		availableHeight = innerHeight;

	var tree = document.getElementById('divRight').style;
	var frame = document.getElementById('icontent').style;
	tree.height = availableHeight;
	frame.height = availableHeight;
}
