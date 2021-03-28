//*******************************************************************************************
//  FILE:   XComDownloadableContentInfo_WOTCRustyMeditation.uc                                    
//  
//	File created by RustyDios	06/08/19	01:30	
//	LAST UPDATED				27/06/20	17:00
//
//	ADDS LOCALISATION HANDLER FOR NEW ABILITIES VALUES
//	ADDS ABILITY TO ALL STANDARD SHARD GAUNTLETS
//
//*******************************************************************************************

class X2DownloadableContentInfo_WOTC_RustyMeditation extends X2DownloadableContentInfo config (RustyMeditationConfig);

// Grab variables from the config
var config bool bEnableLogging, bOverrideARGauntlets;
var config array<name> ItemTemplatesToGetMeditation;

static event OnLoadedSavedGame(){}

static event InstallNewCampaign(XComGameState StartState){}

//*******************************************************************************************
// Tag Expansion Handler - this creates the custom string fields for localisation file
//*******************************************************************************************
static function bool AbilityTagExpandHandler(string InString, out string OutString)
{
	local name TagText;
	
	TagText = name(InString);
	switch (TagText)
	{
		case 'MEDITATION_FOCUS_RECOVERY':
			OutString = string(class'X2Ability_TemplarMeditation'.default.iMEDITATION_FOCUS_RECOVERY);
			return true;
		case 'MEDITATION_COST_AP':
			OutString = string(class'X2Ability_TemplarMeditation'.default.iMEDITATION_COST_AP);
			return true;
		case 'MEDITATION_COST_FREE':
			OutString = string(class'X2Ability_TemplarMeditation'.default.bMEDITATION_COST_FREE);
			return true;
		case 'MEDITATION_COST_TURNENDING':
			OutString = string(class'X2Ability_TemplarMeditation'.default.bMEDITATION_COST_TURNENDING);
			return true;
		case 'MEDITATION_COST_COOLDOWN':
			OutString = string(class'X2Ability_TemplarMeditation'.default.iMEDITATION_COST_COOLDOWN);
			return true;
		case 'MEDITATION_COST_CHARGES':
			OutString = string(class'X2Ability_TemplarMeditation'.default.iMEDITATION_COST_CHARGES);
			return true;
		case 'MEDITATION_COST_BLOOD':
			Outstring = string(class'X2Ability_TemplarMeditation'.default.iMEDITATION_COST_BLOOD.Damage);
			return true;
		default:
            return false;
    }  
}

//*******************************************************************************************
// ADD/CHANGES AFTER TEMPLATES LOAD ~ OPTC ~
//*******************************************************************************************
static event OnPostTemplatesCreated()
{
	local X2ItemTemplateManager					AllItems;			//holder for all items
	local X2ItemTemplate						CurrentItem;
	
	//local X2WeaponTemplate		WeaponTemplate;
	//local X2PairedWeaponTemplate	PairedTemplate;
	local X2EquipmentTemplate		EquipTemplate;

	local int i;

	AllItems			= class'X2ItemTemplateManager'.static.GetItemTemplateManager();

	//////////////////////////////////////////////////////////////////////////////////////////
	// TEMPLAR MEDITATION:	ADDS A MEDITATION ABILITY TO GAUNTLETS TO GAIN FOCUS
	//////////////////////////////////////////////////////////////////////////////////////////

	for(i = 0; i < default.ItemTemplatesToGetMeditation.length ; i++)
	{
		CurrentItem = AllItems.FindItemTemplate(default.ItemTemplatesToGetMeditation[i]);

		/* //add to paired weapons matching
		PairedTemplate = X2PairedWeaponTemplate(CurrentItem);

		if (PairedTemplate != none)
		{
			PairedTemplate.Abilities.AddItem ('TemplarMeditation');

			`LOG("Patched Paired Weapon :: Templar Meditation added to :: " @PairedTemplate.GetItemFriendlyName() ,default.bEnableLogging,'WOTC_RustyMeditation');
		}

		//add to weapons matching
		WeaponTemplate = X2WeaponTemplate(CurrentItem);

		if (WeaponTemplate != none)
		{
			WeaponTemplate.Abilities.AddItem ('TemplarMeditation');

			`LOG("Patched Weapon :: Templar Meditation added to :: " @WeaponTemplate.GetItemFriendlyName() ,default.bEnableLogging,'WOTC_RustyMeditation');
		}*/

		//add to equipment matching ... covers BOTH the above cases
		EquipTemplate = X2EquipmentTemplate(CurrentItem);

		if (EquipTemplate != none)
		{
			EquipTemplate.Abilities.AddItem ('TemplarMeditation');

			`LOG("Patched Equipment :: Templar Meditation added to :: " @EquipTemplate.GetItemFriendlyName() ,default.bEnableLogging,'WOTC_RustyMeditation');
		}
	}
}
