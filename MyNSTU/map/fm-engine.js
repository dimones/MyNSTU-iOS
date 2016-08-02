var container, stats;
var camera, scene, renderer;

var cam_factor = 1;


var map_data;
$.getJSON("nstu_map_data.json",
function(json)
{
	console.log(json);
	map_data = json;
	init();
	animate();
});

function init() {

	container = document.createElement( 'div' );
	document.body.appendChild( container );

	// var info = document.createElement( 'div' );
	// info.style.position = 'absolute';
	// info.style.top = '10px';
	// info.style.width = '100%';
	// info.style.textAlign = 'center';
	// info.innerHTML = '<a href="http://threejs.org" target="_blank">three.js</a> - orthographic view';
	// container.appendChild( info );

	camera = new THREE.OrthographicCamera( 
		-window.innerWidth * cam_factor, 
		window.innerWidth * cam_factor,
		window.innerHeight * cam_factor,
		-window.innerHeight * cam_factor, - 2000, 100000 );
	camera.position.x = 2000;
	camera.position.y = 2000;
	camera.position.z = 2000;

	scene = new THREE.Scene();

	// Cubes
	var material = new THREE.MeshLambertMaterial( { color: 0xffffff, overdraw: 0.5 } );

	var geometry = new THREE.BoxGeometry(1700, 1, 2500);
	var cubest = new THREE.Mesh(geometry, material);
	cubest.position.set(0,-25,0);
	//cubest.lookAt(camera.position);
	//scene.add(cubest);
	
	geometry = new THREE.BoxGeometry( 1, 50, 1);

	var walls = map_data.map.builds[7].floors[1].walls;
	for (var w in walls) 
	{
		var cube = new THREE.Mesh(geometry, material);
		var c1 = new THREE.Vector3( -walls[w].coord1.y+750, 0, -walls[w].coord1.x+1250);
		var c2 = new THREE.Vector3( -walls[w].coord2.y+750, 0, -walls[w].coord2.x+1250);

		cube.scale.z = c1.distanceTo(c2);
		cube.scale.x = 10;//walls[w].width;

		c1 = c1.add(c2);
		c1 = c1.divideScalar(2);

		cube.position.x = c1.x
		cube.position.y = 0;
		cube.position.z = c1.z

		cube.lookAt(c2);

		scene.add( cube );
	}

	// Lights
	var directionalLight = new THREE.DirectionalLight( 0x10D7EA );
	directionalLight.position.x = 0.55;
	directionalLight.position.y = 0.45;
	directionalLight.position.z = 0.8;
	directionalLight.position.normalize();
	scene.add( directionalLight );

	var directionalLight = new THREE.DirectionalLight( 0x10D7EA );
	directionalLight.position.x = -0.55;
	directionalLight.position.y = 0.45;
	directionalLight.position.z = -0.8;
	directionalLight.position.normalize();
	scene.add( directionalLight );

	scene.add( new THREE.AxisHelper(1500) );
	
	
	//renderer = new THREE.CanvasRenderer();
	renderer = new THREE.WebGLRenderer({ antialias: true, logarithmicDepthBuffer: false });
	renderer.setClearColor( 0xf0f0f0 );
	renderer.setPixelRatio( window.devicePixelRatio );
	renderer.setSize( window.innerWidth, window.innerHeight );
	container.appendChild( renderer.domElement );

	camera.lookAt(cubest.position);

	var controls = new THREE.OrbitControls( camera, renderer.domElement );
	//controls.maxPolarAngle = Math.PI * 0.5;
	//controls.minDistance = 1000;
	//controls.maxDistance = 7500;

	window.addEventListener( 'resize', onWindowResize, false );

}

function onWindowResize() {

	camera.left = -window.innerWidth * cam_factor;
	camera.right = window.innerWidth * cam_factor;
	camera.top = window.innerHeight * cam_factor;
	camera.bottom = -window.innerHeight * cam_factor;

	camera.updateProjectionMatrix();

	renderer.setSize( window.innerWidth, window.innerHeight );

}

//

function animate() {

	requestAnimationFrame( animate );

	//stats.begin();
	render();
	//stats.end();

}

function render() {

	var timer = Date.now() * 0.0001;

	//camera.position.x = Math.cos( timer ) * 200;
	//camera.position.z = Math.sin( timer ) * 200;
	//camera.lookAt( scene.position );

	renderer.render( scene, camera );

}
