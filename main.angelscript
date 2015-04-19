/*
 Hello world!
*/

#include "eth_util.angelscript"

const bool debug = false;

// constants
const float snake_speed = 20.0f;
const float delta_snake = 26.0f;
const float bullet_speed = 15.0f;

enum directions
{
	D_UP = 2,
	D_LEFT = 4,
	D_RIGHT = 6, 
	D_DOWN = 8
}

// variables
int health;
int time;
int score = 0;
float difficulty;
bool movingLeft;
bool movingRight;
bool movingDown;
bool movingUp;
vector2 screenScale;
vector2 moveDirection;
vector3 headDirectionChange;
ETHEntity@ snakeHead;
ETHEntityArray snake;
vector3 lastPos;
vector3 lastPos2;
uint numBody;

void main()
{
	SetFixedWidth(854.0f);
	SetFixedHeight(480.0f);

	const vector2 screenSize = GetScreenSize();
	float xscale = screenSize.x / 854.0f;
	float yscale = screenSize.y / 480.0f;
	screenScale = vector2(xscale, yscale);

	LoadScene("scenes/Main.esc", "init", "gameLoop");

	// Prefer setting window properties in the app.enml file
	// SetWindowProperties("Ethanon Engine", 1024, 768, true, true, PF32BIT);
}

void init()
{
	// init variables
	health = 100;
	score = 0;
	time = 0;
	difficulty = 5.0f;
	moveDirection = vector2(0.0f, -snake_speed);
	movingUp = true;
	movingLeft = false;
	movingRight = false;
	movingDown = false;
	
	@snakeHead = SeekEntity("Snake_Head.ent");
	numBody = snake.Size();
	
	// init snake body sections
	GetEntityArray("Snake_Body.ent", snake);

	AddEntity("Food_Shell.ent", vector3(rand(50, 800), rand(50, 400), 1));

	// init music and sfx
	LoadMusic("bgm/Ouroboros.mp3");
	LoopSample("bgm/Ouroboros.mp3", true);
	PlaySample("bgm/Ouroboros.mp3");
	LoadSoundEffect("soundfx/pew.wav");
	LoadSoundEffect("soundfx/boom.wav");
	LoadSprite("entities/bullet.png");
}

void gameLoop()
{
	time += 1;
	
	DrawText(vector2(10, 5), "Health: " + health, "Verdana14_shadow.fnt", ARGB(250,255,255,255));
	DrawText(vector2(10, 20), "Score: " + score, "Verdana14_shadow.fnt", ARGB(250,255,255,255));
	difficulty = 5.0f + (snake.size() / 2);
	
	if(health <= 0){
		GameOver();
		return;
	}
	
	numBody = snake.size();
	
	if(time % 5 == 0) {
		for (uint t = 0; t < numBody; t++) {
			if(t == 0){
				lastPos2 = snake[t].GetPosition();
				snake[t].SetPosition(lastPos);
			}
			else {
				lastPos = snake[t].GetPosition();
				snake[t].SetPosition(lastPos2);
				lastPos2 = lastPos;
				lastPos = snake[t].GetPosition();
			}
		}
	}
}

void GameOver()
{
	// game over logic here
	LoadScene("scenes/gameover.esc", "initGameOver", "updateGameOver");
}

void initGameOver(){
	LoadSoundEffect("soundfx/boom.wav");
	StopSample("soundfx/Ouroboros.mp3");
	PlaySample("soundfx/boom.wav");
}

void updateGameOver()
{
	DrawText(vector2(10, 5), "Health: " + health, "Verdana14_shadow.fnt", ARGB(250,255,255,255));
	DrawText(vector2(10, 20), "Score: " + score, "Verdana14_shadow.fnt", ARGB(250,255,255,255));
	DrawText(vector2(360, 275) * screenScale, "Press Space to Restart", "Verdana14_shadow.fnt", ARGB(250,255,255,255));
}

void incrementSnakeSection()
{
	int new_segment_id = AddEntity("Snake_Body.ent", vector3(-20, -20, 1));
	score++;
	snake.Insert(SeekEntity(new_segment_id));
}

float screenToCartesianAngle(float deg)
{
	return 270 - deg;
}

vector2 getDirectionVector(float deg)
{
	// returns a unit vector in the direction of the given angle
	float x = cos(degreeToRadian(deg));
	float y = sin(degreeToRadian(deg));

	return vector2(x, y);
}

vector3 getDirectionVector3(float deg)
{
	// returns a unit vector in the direction of the given angle
	float x = cos(degreeToRadian(deg));
	float y = sin(degreeToRadian(deg));

	return vector3(x, y, 0);
}

void ETHConstructorCallback_bullet(ETHEntity@ thisEntity)
{
	PlaySample("soundfx/pew.wav");
}

void ETHCallback_gameover(ETHEntity@ thisEntity)
{
	ETHInput@ input = GetInputHandle();
	if(input.GetKeyState(K_SPACE) == KS_HIT)
	{
		snake.Clear();
		main();
	}
}

void ETHCallback_Food_Shell(ETHEntity@ thisEntity)
{
	if(thisEntity.GetInt("destroyed") != 0)
	{
		// uncomment following line to spawn food
		//AddEntity("food.ent", thisEntity.GetPosition());

		// comment following 2 lines and uncomment above line to revert to food only mode
		incrementSnakeSection();
		AddEntity("Food_Shell.ent", vector3(rand(50, 800), rand(50, 400), 1));
		
		DeleteEntity(thisEntity);
		return;
	}
	ETHPhysicsController@ controller = thisEntity.GetPhysicsController();
	
	if(time % 10 == 0){
		controller.SetLinearVelocity(vector2(rand(-difficulty, difficulty), rand(-difficulty, difficulty)));
	}
	
}

void changeDirection(int direction)
{
	// 2 = up, 4 = left, 6 = right, 8 = down
	switch(direction){
		case D_UP:
			movingUp = true;
			movingLeft = false;
			movingRight = false;
			snakeHead.SetAngle(0);
			moveDirection = vector2(0.0f, -snake_speed);
			break;
		case D_LEFT:
			movingUp = false;
			movingLeft = true;
			movingDown = false;
			snakeHead.SetAngle(90);
			moveDirection = vector2(-snake_speed, 0.0f);
			break;
		case D_RIGHT:
			movingUp = false;
			movingRight = true;
			movingDown = false;
			snakeHead.SetAngle(270);
			moveDirection = vector2(snake_speed, 0.0f);
			break;
		case D_DOWN:
			movingLeft = false;
			movingRight = false;
			movingDown = true;
			snakeHead.SetAngle(180);
			moveDirection = vector2(0.0f, snake_speed);
			break;
	}
}

void ETHCallback_Snake_Head(ETHEntity@ thisEntity)
{
	ETHInput@ input = GetInputHandle();
	
	if(time % 5 == 0) {
		thisEntity.AddToPositionXY(moveDirection);
		lastPos = thisEntity.GetPosition();
	}

	if((input.GetKeyState(K_RIGHT) == KS_HIT) && !movingLeft){
		changeDirection(D_RIGHT);
	}
	else if ((input.GetKeyState(K_LEFT) == KS_HIT) && !movingRight){
		changeDirection(D_LEFT);
	}
	else if ((input.GetKeyState(K_UP) == KS_HIT)  && !movingDown){
		changeDirection(D_UP);
	}
	else if ((input.GetKeyState(K_DOWN) == KS_HIT)  && !movingUp){
		changeDirection(D_DOWN);
	}
	else if (input.GetKeyState(K_SPACE) == KS_HIT){ // change KS_HIT to KS_DOWN for laser snake
		vector3 facing = getDirectionVector3(270 - thisEntity.GetAngle());
		AddEntity("bullet.ent", thisEntity.GetPosition() + facing * 10);
	}
	else{
		// touch event handling here
	}

	if(input.GetKeyState(K_V) == KS_DOWN && debug)
	{
		// create new snake section
		incrementSnakeSection();
	}

	/*if(thisEntity.PlayParticleSystem(0))
	{
		
	}*/
}

void ETHCallback_bullet(ETHEntity@ thisEntity)
{
	const vector2 screenSize = GetScreenSize();
	vector3 bulletPos = thisEntity.GetPosition();
	vector2 bulletPos2(bulletPos.x, bulletPos.y);
	int destroy = thisEntity.GetInt("destroyed");

	if(!isPointInScreen(bulletPos2) || destroy > 0)
	{
		DeleteEntity(thisEntity);
		return;
	}

	if(thisEntity.GetInt("isDirectionSet") == 0)
	{
		ETHEntity@ playerEntity = SeekEntity("Snake_Head.ent");
		float angle = 270 - playerEntity.GetAngle();
		vector2 dir_vector = getDirectionVector(angle);
		float x = bullet_speed * dir_vector.x;
		float y = bullet_speed * dir_vector.y;

		thisEntity.SetFloat("xspeed", x);
		thisEntity.SetFloat("yspeed", y);
		thisEntity.SetInt("isDirectionSet", 1);
	}
	thisEntity.AddToPositionXY(vector2(thisEntity.GetFloat("xspeed"), thisEntity.GetFloat("yspeed")));
}

void ETHCallback_food(ETHEntity@ thisEntity)
{
	if(thisEntity.GetInt("destroyed") != 0)
	{	
		incrementSnakeSection();
		AddEntity("Food_Shell.ent", vector3(rand(50, 800), rand(50, 400), 1));
		DeleteEntity(thisEntity);
	}
}

void ETHBeginContactCallback_Food_Shell(
	ETHEntity@ thisEntity,
	ETHEntity@ other,
	vector2 contactPointA,
	vector2 contactPointB,
	vector2 contactNormal)
{
	if (other.GetEntityName() == "bullet.ent")
	{
		thisEntity.SetInt("destroyed", 1);
		other.SetInt("destroyed", 1);
		// a 'bullet.ent' hit the food capsule, that must result in an explosion
		//explodeMyBarrel(thisEntity);
	}
}

void ETHBeginContactCallback_food(
	ETHEntity@ thisEntity,
	ETHEntity@ other,
	vector2 contactPointA,
	vector2 contactPointB,
	vector2 contactNormal)
	{
		if (other.GetEntityName() == "Snake_Head.ent")
		{
			// elongate tail and destroy
			other.SetInt("destroyed", 1);
			thisEntity.SetInt("destroyed", 1);
		}
	}

void ETHBeginContactCallback_wall(
	ETHEntity@ thisEntity,
	ETHEntity@ other,
	vector2 contactPointA,
	vector2 contactPointB,
	vector2 contactNormal)
{
	if (other.GetEntityName() == "Snake_Head.ent")
	{
		// snake head hit wall. Game over.
		GameOver();
	}
	else if(other.GetEntityName() == "bullet.ent")
	{
		// Destroy bullet
		other.SetInt("destroyed", 1);
	}
}

void ETHBeginContactCallback_Snake_Body(
	ETHEntity@ thisEntity,
	ETHEntity@ other,
	vector2 contactPointA,
	vector2 contactPointB,
	vector2 contactNormal)
{
	if (other.GetEntityName() == "Snake_Head.ent")
	{
		// eats own body. game over.
		GameOver();
	}
	else if (other.GetEntityName() == "bullet.ent")
	{
		// shot itself. Decrease health
		health -= 20;
		other.SetInt("destroyed", 1);
		PlayParticleEffect("fire.par", thisEntity.GetPositionXY(), 0.0f, 1.0f);
		PlaySample("soundfx/boom.wav");
	}
}
