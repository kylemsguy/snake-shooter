/*
 Hello world!
*/

#include "eth_util.angelscript"

vector2 moveDirection = vector2(0.0f, -2.0f);
vector3 headDirectionChange;
ETHEntityArray snake;

void main()
{
	LoadScene("scenes/Main.esc", "setUp", "");

	// Prefer setting window properties in the app.enml file
	// SetWindowProperties("Ethanon Engine", 1024, 768, true, true, PF32BIT);
}

void setUp()
{

	GetEntityArray("Snake_Body.ent", snake);

}

void ETHCallback_Snake_Head(ETHEntity@ thisEntity)
{
	ETHInput@ input = GetInputHandle();
	
	thisEntity.AddToPositionXY(moveDirection);
	const uint numBody = snake.Size();
	for (uint t = 0; t < numBody; t++)
    {
		snake[t].AddToPositionXY(moveDirection);
    }

	if(input.GetKeyState(K_RIGHT) == KS_HIT){
		headDirectionChange = thisEntity.GetPosition();
		thisEntity.SetAngle(270);
		moveDirection = vector2(2.0f, 0.0f);
	}

	if (input.GetKeyState(K_LEFT) == KS_HIT){
		headDirectionChange = thisEntity.GetPosition();
		thisEntity.SetAngle(90);
		moveDirection = vector2(-2.0f, 0.0f);
	}

	if (input.GetKeyState(K_UP) == KS_HIT){
		headDirectionChange = thisEntity.GetPosition();
		thisEntity.SetAngle(0);
		moveDirection = vector2(0.0f, -2.0f);
	}

	if (input.GetKeyState(K_DOWN) == KS_HIT){
		headDirectionChange = thisEntity.GetPosition();
		thisEntity.SetAngle(180);
		moveDirection = vector2(0.0f, 2.0f);
	}

	if (input.GetKeyState(K_SPACE) == KS_HIT){
		AddEntity("bullet.ent", thisEntity.GetPosition());
	}

	/*if(thisEntity.PlayParticleSystem(0))
	{
		
	}*/
}

void ETHCallback_bullet(ETHEntity@ thisEntity)
{
	const vector2 screenSize = GetScreenSize();
	vector3 bulletPos = thisEntity.GetPosition();

	if(bulletPos.x < 0 || bulletPos.y < 0 || bulletPos.x > screenSize.x || bulletPos.y > screenSize.y)
	{
		DeleteEntity(thisEntity);
		return;
	}

	const float speed = 15.0f;

	if(thisEntity.GetInt("isDirectionSet") == 0)
	{
		ETHEntity@ playerEntity = SeekEntity("trianglething.ent");
		float angle = 270 - playerEntity.GetAngle();
		float x = speed * cos(degreeToRadian(angle));
		float y = speed * sin(degreeToRadian(angle));

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

void ETHBeginContactCallback_snakebody(
	ETHEntity@ thisEntity,
	ETHEntity@ other,
	vector2 contactPointA,
	vector2 contactPointB,
	vector2 contactNormal)
{
	if (other.GetEntityName() == "snakehead.ent")
	{
		// a 'snakehead.ent' hit the snake body, that must result in game over
		//explodeMyBarrel(thisEntity);
	}
	else if(other.GetEntityName() == "bullet.ent")
	{
		// a bullet hit the body. Decrease life
	}
}
