#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <vip_core>
#include <ogranichenie_oruzhija>

public Plugin:myinfo = 
{
	name = "[VIP] Weapon Restrict (Pheonix)",
	author = "R1KO",
	version = "1.0"
};

static const String:g_sFeature[] = "WeaponRestrictImmunity";


ArrayList g_hWeaponsBlackList, g_hWeaponsWhiteList;

public OnPluginStart() 
{
	g_hWeaponsBlackList = new ArrayList(32);
	g_hWeaponsWhiteList = new ArrayList(32);

	if(VIP_IsVIPLoaded())
	{
		VIP_OnVIPLoaded();
	}
}

public OnPluginEnd() 
{
	if(CanTestFeatures() && GetFeatureStatus(FeatureType_Native, "VIP_UnregisterFeature") == FeatureStatus_Available)
	{
		VIP_UnregisterFeature(g_sFeature);
	}
}

public VIP_OnVIPLoaded()
{
	VIP_RegisterFeature(g_sFeature, BOOL);
}

public OO_Return OO_OnPickOrBuyOver(int iClient, int iDefinitionIndex, const char[] szWeapon, int iEnt, int iWeapLimit, int iWeapNow)
{
	if(VIP_IsClientVIP(iClient) && VIP_IsClientFeatureUse(iClient, g_sFeature) && IsAllowedWeapon(szWeapon))
	{
		return OO_Allow;
	}

	return OO_Ignored;
}

bool IsAllowedWeapon(const char[] szWeapon)
{
	if (g_hWeaponsWhiteList.Length)
	{
		return g_hWeaponsWhiteList.FindString(szWeapon) != -1;
	}

	return !g_hWeaponsBlackList.Length || g_hWeaponsBlackList.FindString(szWeapon) == -1;
}

public void OnConfigsExecuted()
{
	char szPath[PLATFORM_MAX_PATH];
	
	BuildPath(Path_SM, szPath, sizeof(szPath), "data/vip/modules/restrict_weapons_black.ini");
	ReadFileToArray(szPath, g_hWeaponsBlackList);
	
	BuildPath(Path_SM, szPath, sizeof(szPath), "data/vip/modules/restrict_weapons_white.ini");
	ReadFileToArray(szPath, g_hWeaponsWhiteList);
}

void ReadFileToArray(const char[] szPath, ArrayList hArray)
{
	hArray.Clear();

	char szBuffer[PLATFORM_MAX_PATH];
	File hFile = OpenFile(szPath, "r");
	if(!hFile)
	{
		return;
	}

	while (!hFile.EndOfFile() && hFile.ReadLine(szBuffer, sizeof(szBuffer)))
	{
		TrimString(szBuffer);
		if(!szBuffer[0])
		{
			continue;
		}

		hArray.PushString(szBuffer);
	}

	hFile.Close();
}
