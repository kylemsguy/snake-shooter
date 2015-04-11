/*
 Hello world!
*/

#include "eth_util.angelscript"

// constants
const float snake_speed = 2.0f;
const float delta_snake = 26.0f;
const float bullet_speed = 15.0f;

// variables
int health;
vector2 moveDirection;
vector3 headDirectionChange;
ETHEntityArray snake;

void main()
{
	LoadScene("scenes/Main.esc", "init", "CheckHealth");

	// Prefer setting window properties in the app.enml file
	// SetWindowProperties("Ethanon Engine", 1024, 768, true, true, PF32BIT);
}

void init()
{
	// init variables
	health = 100;
	moveDirection = vector2(0.0f, -snake_speed);
	
	// init snake body sections
	GetEntityArray("Snake_Body.ent", snake);
	snake[0].SetInt("target_obj", -1);
	//snake[1].SetInt("target_obj", 0);

	// init music and sfx
	LoadMusic("bgm/Ouroboros.mp3");
	LoopSample("bgm/Ouroboros.mp3", true);
	PlaySample("bgm/Ouroboros.mp3");
	LoadSoundEffect("soundfx/pew.wav");
}

void CheckHealth()
{
	DrawText(vector2(10,10), "Health: " + health, "Verdana14_shadow.fnt", ARGB(250,255,255,255));
	if(health <= 0)
		GameOver();
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
	
	thisEntity.AddToPositionXY(moveDirection);
	/*const uint numBody = snake.Size();

	for (uint t = 0; t < numBody; t++)
    {
		snake[t].AddToPositionXY(moveDirection);
    }*/

	if(input.GetKeyState(K_RIGHT) == KS_HIT){
		headDirectionChange = thisEntity.GetPosition();
		thisEntity.SetAngle(270);
		moveDirection = vector2(snake_speed, 0.0f);
	}

	if (input.GetKeyState(K_LEFT) == KS_HIT){
		headDirectionChange = thisEntity.GetPosition();
		thisEntity.SetAngle(90);
		moveDirection = vector2(-snake_speed, 0.0f);
	}

	if (input.GetKeyState(K_UP) == KS_HIT){
		headDirectionChange = thisEntity.GetPosition();
		thisEntity.SetAngle(0);
		moveDirection = vector2(0.0f, -snake_speed);
	}

	if (input.GetKeyState(K_DOWN) == KS_HIT){
		headDirectionChange = thisEntity.GetPosition();
		thisEntity.SetAngle(180);
		moveDirection = vector2(0.0f, snake_speed);
	}

	if (input.GetKeyState(K_SPACE) == KS_HIT){
		AddEntity("bullet.ent", thisEntity.GetPosition());
	}

	if(input.GetKeyState(K_V) == KS_HIT)
	{
		// create new snake section
	}

	/*if(thisEntity.PlayParticleSystem(0))
	{
		
	}*/
}

void ETHCallback_Snake_Body(ETHEntity@ thisEntity)
{
	vector2 curr_pos = thisEntity.GetPositionXY();
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
		float x = bullet_speed * cos(degreeToRadian(angle));
		float y = bullet_speed * sin(degreeToRadian(angle));

		thisEntity.SetFloat("xspeed", x);
		thisEntity.SetFloat("yspeed", y);
		thisEntity.SetInt("isDirectionSet", 1);
	}
	thisEntity.AddToPositionXY(vector2(thisEntity.GetFloat("xspeed"), thisEntity.GetFloat("yspeed")));
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

void ETHBeginContactCallback_food_pellet(
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
	if (other.GetEntityName() == "snake_head.ent")
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
	}
}
