// List of Includes
#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <clientprefs>
#include <multicolors>

// The code formatting rules we wish to follow
#pragma semicolon 1;
#pragma newdecls required;


// Our List of Variables
int LastPressedButton[MAXPLAYERS + 1];

// Cookie Specific Variables
bool option_key_ultimate[MAXPLAYERS + 1] = {true,...};
bool option_key_ability[MAXPLAYERS + 1] = {true,...};
bool option_key_information[MAXPLAYERS + 1] = {true,...};

Handle cookie_key_ultimate = INVALID_HANDLE;
Handle cookie_key_ability = INVALID_HANDLE;
Handle cookie_key_information = INVALID_HANDLE;


// The retrievable information about the plugin itself 
public Plugin myinfo = 
{
	name		= "[CS:GO] Default Skill Keybinds",
	author		= "Manifest @Road To Glory",
	description	= "Players will have their Ability set on [Use] and ultimate set to [Inspect] by default.",
	version		= "V. 1.0.0 [Beta]",
	url			= ""
};


// This happens when the plugin is loaded
public void OnPluginStart()
{
	// Adds a command listener to check whenever a player inspects his weapon
	AddCommandListener(Command_Ultimate, "+lookatweapon");

	// Cookie Stuff
	cookie_key_ultimate = RegClientCookie("Key Ultimate On/Off 1", "keyult1337", CookieAccess_Private);
	cookie_key_ability = RegClientCookie("Key Ability On/Off 1", "keyabi1337", CookieAccess_Private);
	cookie_key_information = RegClientCookie("Key Information On/Off 1", "keyinf1337", CookieAccess_Private);

	SetCookieMenuItem(CookieMenuHandler_key_ultimate, cookie_key_ultimate, "Key Ultimate");
	SetCookieMenuItem(CookieMenuHandler_key_ability, cookie_key_ability, "Key Ability");
	SetCookieMenuItem(CookieMenuHandler_key_information, cookie_key_information, "Key Information");

	// Loads Our Translation File
	LoadTranslations("custom_WCS_KeyBinds.phrases");
}


//////////////////////
// Ultimate Section //
//////////////////////

// This happens whenever a player presses the button he uses to inspect his weapoon
public Action Command_Ultimate(int client, const char[] command, int argc)
{
	// If the client meets our criteria for validation then execute this section
	if(IsValidClient(client))
	{
		if(option_key_ultimate[client])
		{
			// Makes the player use the command "ultimate" which will activate the WC:S ultimate
			ClientCommand(client, "ultimate");
		}
	}
}



/////////////////////
// Ability Section //
/////////////////////

// Whenever a player presses a key this section happens
public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if(option_key_ability[client])
	{
		// Loops through the buttons
		for (int i = 0; i < 25; i++)
		{
			// Creates a variable named button and stores the obtained data within it
			int button = (1 << i);
			
			// If the button that was pressed is equals to our variable "button" then execute this section
			if ((buttons & button))
			{
				if (!(LastPressedButton[client] & button))
				{
					// If the button that was pressed is the use button, then execute this section
					if(button & IN_USE)
					{
						// Makes the player use the command "ability" which will activate the WC:S ability
						ClientCommand(client, "ability");
					}
				}
			}
		}
	}

	LastPressedButton[client] = buttons;

	return Plugin_Continue;
}


// This happens whenever a player disconnects
public void OnClientDisconnect_Post(int client)
{
	// Changes the LastPressedButton variable to 0
	LastPressedButton[client] = 0;
}



/////////////////////////////
// Connect Message Section //
/////////////////////////////

// This happens when a client connects to the server
public void OnClientPutInServer(int client)
{
	// If our client is not Source TV then execute this section
	if(!IsClientSourceTV(client))
	{
		// If our client is not a replay bot then execute this section
		if(!IsClientReplay(client))
		{
			// If our client is not a bot then execute this section
			if (!IsFakeClient(client))
			{
				if(option_key_information[client])
				{
					// After 20.0 seconds calls upon the function named Timer_SendMessage 
					CreateTimer(20.0, Timer_SendMessage, client);
				}
			}
		}
	}
}


// This function is called upon 20 seconds after a player joins the server
public Action Timer_SendMessage(Handle timer, int client)
{
	// Checks if the player meets our client validation criteria
	if(IsValidClient(client))
	{
		// Sends out multi-language message to the player
		CPrintToChat(client, "%t", "Key Bind Connect Message");
	}
}



/////////////////////
// Validation Bool //
/////////////////////

// We call upon this true and false statement whenever we wish to validate our player
bool IsValidClient(int client)
{
	// If the client is connected, and in-game, whilst not being either a replay bot or source tv, and is within the amount of possible clients, then execute this section
	if (!(1 <= client <= MaxClients) || !IsClientConnected(client) || !IsClientInGame(client) || IsClientSourceTV(client) || IsClientReplay(client))
	{
		return false;
	}

	return true;
}


////////////////////////
// Cookie Stuff Below //
////////////////////////

public void OnClientCookiesCached(int client)
{
	option_key_ultimate[client] = GetCookiekey_ultimate(client);
	option_key_ability[client] = GetCookiekey_ability(client);
	option_key_information[client] = GetCookiekey_information(client);
}


bool GetCookiekey_ultimate(int client)
{
	char buffer[10];
	GetClientCookie(client, cookie_key_ultimate, buffer, sizeof(buffer));
	
	return !StrEqual(buffer, "Off");
}


bool GetCookiekey_ability(int client)
{
	char buffer[10];
	GetClientCookie(client, cookie_key_ability, buffer, sizeof(buffer));
	
	return !StrEqual(buffer, "Off");
}


bool GetCookiekey_information(int client)
{
	char buffer[10];
	GetClientCookie(client, cookie_key_information, buffer, sizeof(buffer));
	
	return !StrEqual(buffer, "Off");
}


public void CookieMenuHandler_key_ultimate(int client, CookieMenuAction action, any key_ultimate, char[] buffer, int maxlen)
{	
	if (action == CookieMenuAction_DisplayOption)
	{
		char status[16];
		if (option_key_ultimate[client])
		{
			Format(status, sizeof(status), "%s", "[ON]", client);
		}
		else
		{
			Format(status, sizeof(status), "%s", "[OFF]", client);
		}
		
		Format(buffer, maxlen, "Button 'Inspect' Casts Ultimate: %s", status);
	}
	else
	{
		option_key_ultimate[client] = !option_key_ultimate[client];
		
		if (option_key_ultimate[client])
		{
			SetClientCookie(client, cookie_key_ultimate, "On");
			CPrintToChat(client, "%t", "Ultimate Key Enabled");
		}
		else
		{
			SetClientCookie(client, cookie_key_ultimate, "Off");
			CPrintToChat(client, "%t", "Ultimate Key Disabled");
			CPrintToChat(client, "%t", "Ultimate Key How To Bind");
		}
		
		ShowCookieMenu(client);
	}
}


public void CookieMenuHandler_key_ability(int client, CookieMenuAction action, any key_ability, char[] buffer, int maxlen)
{	
	if (action == CookieMenuAction_DisplayOption)
	{
		char status[16];
		if (option_key_ability[client])
		{
			Format(status, sizeof(status), "%s", "[ON]", client);
		}
		else
		{
			Format(status, sizeof(status), "%s", "[OFF]", client);
		}
		
		Format(buffer, maxlen, "Button 'Use' Casts Ability: %s", status);
	}
	else
	{
		option_key_ability[client] = !option_key_ability[client];
		
		if (option_key_ability[client])
		{
			SetClientCookie(client, cookie_key_ability, "On");
			CPrintToChat(client, "%t", "Ability Key Enabled");
		}
		else
		{
			SetClientCookie(client, cookie_key_ability, "Off");
			CPrintToChat(client, "%t", "Ability Key Disabled");
			CPrintToChat(client, "%t", "Ability Key How To Bind");
		}
		
		ShowCookieMenu(client);
	}
}


public void CookieMenuHandler_key_information(int client, CookieMenuAction action, any key_information, char[] buffer, int maxlen)
{	
	if (action == CookieMenuAction_DisplayOption)
	{
		char status[16];
		if (option_key_information[client])
		{
			Format(status, sizeof(status), "%s", "[ON]", client);
		}
		else
		{
			Format(status, sizeof(status), "%s", "[OFF]", client);
		}
		
		Format(buffer, maxlen, "Key Bind Message When Connecting: %s", status);
	}
	else
	{
		option_key_information[client] = !option_key_information[client];
		
		if (option_key_information[client])
		{
			SetClientCookie(client, cookie_key_information, "On");
			CPrintToChat(client, "%t", "Key Bind Message Enabled");
		}
		else
		{
			SetClientCookie(client, cookie_key_information, "Off");
			CPrintToChat(client, "%t", "Key Bind Message Disabled");
		}
		
		ShowCookieMenu(client);
	}
}