//#include <sourcemod>
//#include <cstrike>
#include <SteamWorks>
#include <multicolors>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "0.1.6"

public Plugin myinfo = 
{
	name = "[VX] Auth Check", 
	author = "Yekta.T", 
	description = "If the server has a Steam connection and the Steam auth values of the players joining the server cannot be retrieved, they will be kicked from the game.", 
	version = PLUGIN_VERSION, 
	url = "vortexguys.com"
};


ConVar gc_PluginEnabled;
ConVar gc_RetryTime;
ConVar gc_MaxAttempts;

bool g_bPluginEnabled = true;
bool g_bConnectedtoSteam = true;
bool g_bAwaitingAuth[MAXPLAYERS + 1] = { false, ... };

int g_iRetryTime;
int g_iMaxAttempts;
int g_iAttempts[MAXPLAYERS + 1];

char g_sKickText[1000];

public void OnPluginStart()
{
	gc_PluginEnabled = CreateConVar("sm_vxauthcontrol_enabled", "1", "0 Disabled, 1 Enables", _, true, 0.0, true, 1.0);
	gc_RetryTime = CreateConVar("sm_vxauthcontrol_retrytime", "20", "How many seconds should the server wait before retrying if the Steam auth information of the player joining the server cannot be retrieved?");
	gc_MaxAttempts = CreateConVar("sm_vxauthcontrol_maxattempts", "3", "After each retry time, if the auth value cannot be retrieved, it is recorded as a failed attempt. At which failed attempt should the player be kicked from the server?", _, true, 1.0);
	
	HookConVarChange(gc_PluginEnabled, Callback_ConvarChange);
	HookConVarChange(gc_RetryTime, Callback_ConvarChange);
	HookConVarChange(gc_MaxAttempts, Callback_ConvarChange);
	LoadTranslations("vx_authcheck.phrases");
}

public void Callback_ConvarChange(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if (StrEqual(oldValue, newValue, false))
		return;
	
	int inewValue = StringToInt(newValue);
	if (convar == gc_PluginEnabled)
		g_bPluginEnabled = inewValue ? true : false;
	else if (convar == gc_RetryTime)
		g_iRetryTime = inewValue;
	else if (convar == gc_MaxAttempts)
		g_iMaxAttempts = inewValue;
}

public void OnConfigsExecuted()
{
	g_bPluginEnabled = GetConVarBool(gc_PluginEnabled);
	g_iMaxAttempts = GetConVarInt(gc_MaxAttempts);
	g_iRetryTime = GetConVarInt(gc_RetryTime);
}

public void OnMapStart()
{
	char szMainPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, szMainPath, sizeof(szMainPath), "configs");
	
	Format(szMainPath, sizeof(szMainPath), "%s\\vx_authchecker.txt", szMainPath);
	
	g_sKickText = "\n";
	Handle hFile = INVALID_HANDLE;
	hFile = OpenFile(szMainPath, "r");
	
	if (hFile == INVALID_HANDLE)
	{
		g_sKickText = "\n- TR: - - - - - - - - - - - -\nSteam Kimliğinize ulaşamadık, lütfen tekrar deneyin.\n\n- EN: - - - - - - - - - - - -\nUnable to access your Steam identity, please try again.";
		LogError("[VX CHECK AUTH] FILE \"%s\" IS NOT FOUND!", szMainPath);
	} else
	{
		char buffer[128];
		while (!IsEndOfFile(hFile))
		{
			ReadFileLine(hFile, buffer, sizeof(buffer));
			StrCat(g_sKickText, 512, buffer);
		}
	}
}

public void OnClientPutInServer(int client)
{
	if (!g_bPluginEnabled)return;
	
	g_bAwaitingAuth[client] = true;
	g_iAttempts[client] = g_iMaxAttempts;
	VX_CreateTimer(client);
}

public void OnClientAuthorized(int client, const char[] auth)
{
	g_bAwaitingAuth[client] = false;
}

void VX_CreateTimer(int client)
{
	CreateTimer(g_iRetryTime * 1.0, TIMER_AuthCheck, GetClientUserId(client));
}

public Action TIMER_AuthCheck(Handle timer, any iClient)
{
	if (!g_bPluginEnabled)return Plugin_Stop;
	
	int client = GetClientOfUserId(iClient);
	if (!client && !g_bAwaitingAuth[client] && !g_bConnectedtoSteam)return Plugin_Stop;
	
	char sAuth[32], sName[32];
	bool success = GetClientAuthId(client, AuthId_Steam2, sAuth, 32);
	if (!success
		 || (StrContains(sAuth, "STEAM_ID", false) != -1))
	{
		if (g_iAttempts[client] > 1)
		{
			g_iAttempts[client]--;
			GetClientName(client, sName, 32);
			LogMessage("%s's Steam Auth check has failed. %i attempts left.", sName, g_iAttempts[client]);
			
			
			PrintToChat(client, " ");
			PrintToChat(client, " ");
			PrintToChat(client, "========================");
			CPrintToChat(client, "%t\n", "attemptFailed-0", sName);
			CPrintToChat(client, "%t\n", "attemptFailed-1", g_iAttempts[client]);
			CPrintToChat(client, "%t", "attemptFailed-2");
			PrintToChat(client, "========================");
			
			VX_CreateTimer(client);
		} else {
			KickClient(client, g_sKickText);
		}
	}
	
	return Plugin_Stop;
}

public int SteamWorks_SteamServersConnected()
{
	if (!g_bConnectedtoSteam)
		g_bConnectedtoSteam = true;
	LogMessage("Connection to Steam Servers Successful");
	return 1;
}

public int SteamWorks_SteamServersConnectFailure()
{
	if (g_bConnectedtoSteam)
		g_bConnectedtoSteam = false;
	LogMessage("Connection to Steam Servers Failed");
	return 1;
}

public int SteamWorks_SteamServersDisconnected()
{
	if (g_bConnectedtoSteam)
		g_bConnectedtoSteam = false;
	LogMessage("Connection to Steam Servers Failed");
	return 1;
} 