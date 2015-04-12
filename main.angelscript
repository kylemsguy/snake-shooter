/*
 Hello world!
*/

#include "eth_util.angelscript"

// constants
const float snake_speed = 20.0f;
const float delta_snake = 26.0f;
const float bullet_speed = 15.0f;

// variables
int health;
int time;
bool directionFlag;
bool movingLeft;
bool movingRight;
bool movingDown;
bool movingUp;
vector2 moveDirection;
vector3 headDirectionChange;
ETHEntityArray snake;
vector3 lastPos;
vector3 lastPos2;
uint numBody;

void main()
{
	LoadScene("scenes/Main.esc", "init", "gameLoop");

	// Prefer setting window properties in the app.enml file
	// SetWindowProperties("Ethanon Engine", 1024, 768, true, true, PF32BIT);
}

void init()
{
	// init variables
	health = 100;
	time = 0;
	moveDirection = vector2(0.0f, -snake_speed);
	directionFlag = false;
	movingUp = true;
	movingLeft = false;
	movingRight = false;
	movingDown = false;
	
	numBody = snake.Size();
	
	// init snake body sections
	GetEntityArray("Snake_Body.ent", snake);

	//snake[1].SetInt("target_obj", 0);

	// init music and sfx
	LoadMusic("bgm/Ouroboros.mp3");
	LoopSample("bgm/Ouroboros.mp3", true);
	PlaySample("bgm/Ouroboros.mp3");
	LoadSoundEffect("soundfx/pew.wav");
	LoadSoundEffect("soundfx/boom.wav");
}

void gameLoop()
{
	time += 1;
	
	DrawText(vector2(10, 5), "Health: " + health, "Verdana14_shadow.fnt", ARGB(250,255,255,255));
	DrawText(vector2(10, 20), "Score: " + snake.size(), "Verdana14_shadow.fnt", ARGB(250,255,255,255));
	if(health <= 0){
		GameOver();
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
	snake.Clear();
	LoadScene("scenes/gameover.esc", "initGameOver", "updateGameOver");
}

void initGameOver(){
	LoadSoundEffect("soundfx/boom.wav");
	StopSample("soundfx/Ouroboros.mp3");
	PlaySample("soundfx/boom.wav");
}

void updateGameOver()
{
	DrawText(vector2(10,10), "Health: " + 0, "Verdana14_shadow.fnt", ARGB(250,255,255,255));
	DrawText(vector2(360, 275), "Press Space to Restart", "Verdana14_shadow.fnt", ARGB(250,255,255,255));
}

void incrementSnakeSection()
{
	int new_segment_id = AddEntity("Snake_Body.ent", vector3(-20, -20, 1));
	snake.Insert(SeekEntity(new_segment_id));
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
		main();
	}
}

void ETHCallback_Snake_Head(ETHEntity@ thisEntity)
{
	ETHInput@ input = GetInputHandle();
	
	if(time % 5 == 0) {
		thisEntity.AddToPositionXY(moveDirection);
		lastPos = thisEntity.GetPosition();
		directionFlag = false;
	}

	if(input.GetKeyState(K_RIGHT) == KS_HIT && !directionFlag && !movingLeft){
		movingUp = false;
		movingRight = true;
		movingDown = false;
		directionFlag = true;
		thisEntity.SetAngle(270);
		moveDirection = vector2(snake_speed, 0.0f);
	}

	if (input.GetKeyState(K_LEFT) == KS_HIT && !directionFlag && !movingRight){
		movingUp = false;
		movingLeft = true;
		movingDown = false;
		directionFlag = true;
		thisEntity.SetAngle(90);
		moveDirection = vector2(-snake_speed, 0.0f);
	}

	if (input.GetKeyState(K_UP) == KS_HIT && !directionFlag && !movingDown){
		movingUp = true;
		movingLeft = false;
		movingRight = false;
		directionFlag = true;
		thisEntity.SetAngle(0);
		moveDirection = vector2(0.0f, -snake_speed);
	}

	if (input.GetKeyState(K_DOWN) == KS_HIT && !directionFlag && !movingUp){
		movingLeft = false;
		movingRight = false;
		movingDown = true;
		directionFlag = true;
		thisEntity.SetAngle(180);
		moveDirection = vector2(0.0f, snake_speed);
	}

	if (input.GetKeyState(K_SPACE) == KS_HIT){ // change KS_HIT to KS_DOWN for laser snake
		vector3 facing = getDirectionVector3(270 - thisEntity.GetAngle());
		AddEntity("bullet.ent", thisEntity.GetPosition() + facing * 10);
	}

	if(input.GetKeyState(K_V) == KS_DOWN)
	{
		// create new snake section
		incrementSnakeSection();
	}

	/*if(thisEntity.PlayParticleSystem(0))
	{
		
	}*/
}

void ETHCallback_Snake_Body(ETHEntity@ thisEntity)
{
	
	/*vector2 curr_pos = thisEntity.GetPositionXY();
	int target_x = thisEntity.GetInt("target_x");
	int target_y = thisEntity.GetInt("target_y");
	vector2 target_pos(target_x, target_y);

	//if(target_pos != curr_pos)
	//	thisEntity.AddToPositionXY(target_pos - curr_pos);

	float dx = 0;
	float dy = 0;

	if(curr_pos.x < target_x)
	{
		// move right 1
		dx = delta_snake;
	} else if(curr_pos.x > target_x)
	{
		// move left 1
		dx = -delta_snake;
	} else if(curr_pos.y < target_y)
	{
		// move down 1
		dy = delta_snake;
	} else if(curr_pos.y > target_y)
	{
		// move up 1
		dy = -delta_snake;
		
	}

	//thisEntity.AddToPositionXY(vector2(dx, dy));

	// get next target
	int entity_id = thisEntity.GetInt("target_obj");
	ETHEntity@ target_entity;
	if(entity_id < 0)
	{
		// targeting head
		@target_entity = SeekEntity("Snake_Head.ent");
	} else {
		@target_entity = snake[entity_id];
	}

	vector2 new_target = target_entity.GetPositionXY();
	if((new_target - thisEntity.GetPositionXY()).length() != 0)
	{
		thisEntity.SetInt("target_x", new_target.x);
		thisEntity.SetInt("target_y", new_target.y);
	}
	//print("Targeting x=" + thisEntity.GetInt("target_x") + " y=" + thisEntity.GetInt("target_y"));
	print("" + target_entity.GetPositionX() + " " + target_entity.GetPositionY());
	*/
}

void ETHCallback_bullet(ETHEntity@ thisEntity)
{
	const vector2 screenSize = GetScreenSize();
	vector3 bulletPos = thisEntity.GetPosition();
	int destroy = thisEntity.GetInt("destroyed");

	if(bulletPos.x < 0 || bulletPos.y < 0 || bulletPos.x > screenSize.x || bulletPos.y > screenSize.y || destroy > 0)
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
		DeleteEntity(thisEntity);
	}
}

void ETHBeginContactCallback_food_capsule(
	ETHEntity@ thisEntity,
	ETHEntity@ other,
	vector2 contactPointA,
	vector2 contactPointB,
	vector2 contactNormal)
{
	if (other.GetEntityName() == "bullet.ent")
	{
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
		print(other.GetPosition().x + ", " + other.GetPosition().y);
		print(thisEntity.GetPosition().x + ", " + thisEntity.GetPosition().y);
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
