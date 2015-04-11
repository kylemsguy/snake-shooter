/*
 Hello world!
*/

#include "eth_util.angelscript"

int health = 100;

void main()
{
	LoadScene("scene/Main.esc", "init", "CheckHealth");

	// Prefer setting window properties in the app.enml file
	// SetWindowProperties("Ethanon Engine", 1024, 768, true, true, PF32BIT);
}

void init()
{
	health = 100;
	LoadMusic("bgm/Ouroboros.mp3");
	LoopSample("bgm/Ouroboros.mp3", true);
	PlaySample("bgm/Ouroboros.mp3");
}

void CheckHealth()
{
	if(health <= 0)
		GameOver();
}

void GameOver()
{
	// game over logic here
}

void ETHCallback_snakehead(ETHEntity@ thisEntity)
{
	ETHInput@ input = GetInputHandle();

	if(input.KeyDown(K_RIGHT)){
		thisEntity.SetAngle(270);
		thisEntity.AddToPositionXY(vector2(2.0f, 0.0f));
	}

	if (input.KeyDown(K_LEFT)){
		thisEntity.SetAngle(90);
		thisEntity.AddToPositionXY(vector2(-2.0f, 0.0f));
	}

	if (input.KeyDown(K_UP)){
		thisEntity.SetAngle(0);
		thisEntity.AddToPositionXY(vector2(0.0f,-2.0f));
	}

	if (input.KeyDown(K_DOWN)){
		thisEntity.SetAngle(180);
		thisEntity.AddToPositionXY(vector2(0.0f, 2.0f));
	}

	if (input.GetKeyState(K_SPACE) == KS_HIT){
		AddEntity("bullet.ent", thisEntity.GetPosition());
	}
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

void ETHBeginContactCallback_wall(
	ETHEntity@ thisEntity,
	ETHEntity@ other,
	vector2 contactPointA,
	vector2 contactPointB,
	vector2 contactNormal)
{
	if (other.GetEntityName() == "snakehead.ent")
	{
		// snake head hit wall. Game over.
		GameOver();
	}
	else if(other.GetEntityName() == "bullet.ent")
	{
		// Destroy bullet
		DeleteEntity(other);
	}
}

void ETHBeginContactCallback_snake_body(
	ETHEntity@ thisEntity,
	ETHEntity@ other,
	vector2 contactPointA,
	vector2 contactPointB,
	vector2 contactNormal)
{
	if (other.GetEntityName() == "snakehead.ent")
	{
		// eats own body. game over.
		GameOver();
	}
	else if (other.GetEntityName() == "bullet.ent")
	{
		// shot itself. Decrease health
		health -= 20;
	}
}
