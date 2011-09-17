
var world;
var currentCircle;

var bgImage = new Image();
bgImage.src = "../Resources/images/game/bg.png";

var ballImage = new Image();
ballImage.src = "../Resources/images/game/bouncingball.png";

var balls = new Array;
var circles = new Array;

InitGame();

function InitGame ()
{
	world = createWorld();
	
	var ball = createBall(world, 100,100);
	ball.WakeUp();
	ball.ApplyForce( new b2Vec2( 2000000, 2000000 ),
	                    new b2Vec2( ball.m_position.x, ball.m_position.y ) );
	
	//ball.ApplyForce(new b2Vec2(0, 0), new b2Vec2(ball.GetOriginPosition.x, ball.GetOriginPosition.y));
}

function step(cnt) 
{
	if (currentCircle != null)
	{
		for (var s = currentCircle.GetShapeList(); s != null; s = s.GetNext()) {
			s.m_radius = s.m_radius + 2;
		}
		//currentCircle.m_radius = currentCircle.m_radius + 10;
	}
	var stepping = false;
	var timeStep = 1.0/60;
	var iteration = 1;
	world.Step(timeStep, iteration);
	ctx.clearRect(0, 0, canvasWidth, canvasHeight);
	drawWorld(world, ctx);
	setTimeout('step(' + (cnt || 0) + ')', 10);
}

Event.observe(window, 'load', function() 
{
	ctx = $('canvas').getContext('2d');
	var canvasElm = $('canvas');
	canvasWidth = parseInt(canvasElm.width);
	canvasHeight = parseInt(canvasElm.height);
	canvasTop = parseInt(canvasElm.style.top);
	canvasLeft = parseInt(canvasElm.style.left);
	
	Event.observe('canvas', 'mousedown', function(e) {

			var circle = createCircle(world, Event.pointerX(e), Event.pointerY(e));
			currentCircle = circle;
	});
	
	Event.observe('canvas', 'mouseup', function(e) {

			currentCircle = null;
	});
	
	Event.observe('canvas', 'contextmenu', function(e) {
		
		return false;
	});
	
	step();
});



function createWorld() {
	var worldAABB = new b2AABB();
	worldAABB.minVertex.Set(-1000, -1000);
	worldAABB.maxVertex.Set(1000, 1000);
	var gravity = new b2Vec2(0, 0);
	var doSleep = true;
	var world = new b2World(worldAABB, gravity, doSleep);
	createGround(world);
	createBox(world, 28, 40, 1, 320);
	createBox(world, 0, 40, 480, 1);
	createBox(world, 480, 0, 1, 320);
	return world;
}

function createGround(world) {
	var groundSd = new b2BoxDef();
	groundSd.extents.Set(1000, 1);
	groundSd.restitution = 1.0;
	groundSd.friction = 0.0;
	groundSd.density = 0.0;
	var groundBd = new b2BodyDef();
	groundBd.AddShape(groundSd);
	groundBd.position.Set(0, 315);
	return world.CreateBody(groundBd)
}

function createBall(world, x, y) {
	var ballSd = new b2CircleDef();
	ballSd.density = 1.0;
	ballSd.radius = 10;
	ballSd.restitution = 1.0;
	ballSd.friction = 0.0;
	// ballSd.groupIndex = -1;
	// ballSd.maskBits = 1;
	// ballSd.categoryBits = 1;
	var ballBd = new b2BodyDef();
	ballBd.AddShape(ballSd);
	ballBd.position.Set(x,y);
	var body = world.CreateBody(ballBd);
	balls[balls.length] = body;
	return body;
}

function createCircle(world, x, y) {
	var ballSd = new b2CircleDef();
	ballSd.density = 999999999999999999999;
	ballSd.radius = 10;
	ballSd.restitution = 0.0;
	ballSd.friction = 0.0;
	ballSd.groupIndex = -8;
	//ballSd.categoryBits = 2;
	//ballSd.maskBits = 4;
	var ballBd = new b2BodyDef();
	ballBd.AddShape(ballSd);
	ballBd.position.Set(x,y);
	var body = world.CreateBody(ballBd);
	circles[circles.length] = body;
	return body;
}

function createBox(world, x, y, width, height, fixed) {
	if (typeof(fixed) == 'undefined') fixed = true;
	var boxSd = new b2BoxDef();
	if (!fixed) boxSd.density = 1.0;
	boxSd.friction = 0.0;
	boxSd.groupIndex = -8;
	//boxSd.categoryBits = 2;
	//boxSd.maskBits = 4;
	boxSd.extents.Set(width, height);
	var boxBd = new b2BodyDef();
	boxBd.AddShape(boxSd);
	boxBd.position.Set(x,y);
	return world.CreateBody(boxBd)
}






function drawWorld(world, context) 
{
	// for (var b = world.m_bodyList; b; b = b.m_next) {
	// 	for (var s = b.GetShapeList(); s != null; s = s.GetNext()) {
	// 		drawShape(s, context);
	// 	}
	// }
	
	for (var i = 0; i < circles.length; i++)
	{
		for (var s = circles[i].GetShapeList(); s != null; s = s.GetNext()) {
			drawShape(s, context);
		}
	}
	
	for (var i = 0; i < balls.length; i++)
	{
		var ball = balls[i];
		context.drawImage(ballImage, ball.m_position.x-10, ball.m_position.y-10);
	}
	
	context.drawImage(bgImage, 0, 0);
}


function drawShape(shape, context) 
{
	context.strokeStyle = '#000';
	context.beginPath();
	switch (shape.m_type) {
	case b2Shape.e_circleShape:
		{
			var circle = shape;
			var pos = circle.m_position;
			var r = circle.m_radius;
			var segments = 16.0;
			
			context.beginPath();
			context.arc(pos.x, pos.y, r, 0, Math.PI*2, true);
			context.closePath();
			context.fill();
			
						// 
						// var theta = 0.0;
						// var dtheta = 2.0 * Math.PI / segments;
						// // draw circle
						// context.moveTo(pos.x + r, pos.y);
						// for (var i = 0; i < segments; i++) {
						// 	var d = new b2Vec2(r * Math.cos(theta), r * Math.sin(theta));
						// 	var v = b2Math.AddVV(pos, d);
						// 	context.lineTo(v.x, v.y);
						// 	theta += dtheta;
						// }
						// context.lineTo(pos.x + r, pos.y);
						// 	
						// // draw radius
						// context.moveTo(pos.x, pos.y);
						// var ax = circle.m_R.col1;
						// var pos2 = new b2Vec2(pos.x + r * ax.x, pos.y + r * ax.y);
						// context.lineTo(pos2.x, pos2.y);
		}
		break;
	case b2Shape.e_polyShape:
		{
			var poly = shape;
			var tV = b2Math.AddVV(poly.m_position, b2Math.b2MulMV(poly.m_R, poly.m_vertices[0]));
			context.moveTo(tV.x, tV.y);
			for (var i = 0; i < poly.m_vertexCount; i++) {
				var v = b2Math.AddVV(poly.m_position, b2Math.b2MulMV(poly.m_R, poly.m_vertices[i]));
				context.lineTo(v.x, v.y);
			}
			context.lineTo(tV.x, tV.y);
		}
		break;
	}
	context.stroke();
}

