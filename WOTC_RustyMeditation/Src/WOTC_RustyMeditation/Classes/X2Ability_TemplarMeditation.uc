//*******************************************************************************************
//  FILE:   X2Ability_TemplarMeditation                                  
//  
//	File created by RustyDios	17/03/20	03:00	
//	LAST UPDATED				23/10/20	07:00
//
//	ADDS a way for templars to gain focus without killing
//	Copied from Alterd-Rushnano 'Caster Gauntlet' https://steamcommunity.com/sharedfiles/filedetails/?id=2024073766
//	A few minor adjustments made, like checking focus level, making it cost 'blood'
//
//*******************************************************************************************

class X2Ability_TemplarMeditation extends X2Ability_TemplarAbilitySet config (RustyMeditationConfig);

//grab config vars
var config int iMEDITATION_FOCUS_RECOVERY;

var config WeaponDamageValue iMEDITATION_COST_BLOOD;
var config int iMEDITATION_COST_AP, iMEDITATION_COST_COOLDOWN, iMEDITATION_COST_CHARGES;
var config bool bMEDITATION_COST_FREE, bMEDITATION_COST_TURNENDING;

//add the ability to the game
static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(Create_TemplarMeditation());

	return Templates;
}

//create the ability
static function X2AbilityTemplate Create_TemplarMeditation()
{
	local X2AbilityTemplate						Template;
	local X2Effect_ModifyTemplarFocus			FocusEffect;

	local X2AbilityCost_ActionPoints			ActionPointCost;
	local X2AbilityCooldown						Cooldown;
	local X2AbilityCharges						Charges;
	local X2AbilityCost_Charges					ChargeCost;

	local X2Effect_ApplyWeaponDamage			Effect;

	local X2Condition_CheckCurrentFocusLevel	CheckFocus;
	local X2Condition_UnitStatCheck				CheckHealth;

	local array<name>							SkipExclusions;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'TemplarMeditation');

	//standard ability stuffs
	//UILibrary_XPACK_Common.PerkIcons.UIPerk_meditation	//UILibrary_XPACK_Common.UIPerk_bond_standbyme	//UILibrary_XPACK_Common.PerkIcons.UIPerk_InnerFocus
	//RustyMeditationIcon.UIPerk_TemplarMeditation
	Template.IconImage = "img:///RustyMeditationIcon.UIPerk_TemplarMeditation";
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.Hostility = eHostility_Neutral;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.REND_PRIORITY + 1;	//after rend, before everything else :)
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";

	Template.bDisplayInUITacticalText = true;
	Template.bDisplayInUITooltip = true;
	Template.bDontDisplayInAbilitySummary = false;

	//typical ability visualization
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bShowPostActivation = true;
	Template.bSkipFireAction = false;
	Template.bStationaryWeapon = true;

	Template.CustomFireAnim = 'HL_Lens';
	Template.ActivationSpeech = 'Amplify';

	//targeting and triggering, nevermiss, self target, player selection
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	//add exclusion if focus is already maxed or unit is dead
	CheckFocus = new class 'X2Condition_CheckCurrentFocusLevel';
	CheckFocus.bIsNotAtMax = true;
	Template.AbilityShooterConditions.AddItem(CheckFocus);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	
	//allow activation even if burning or disoriented
	SkipExclusions.AddItem(class'X2StatusEffects'.default.BurningName);
	SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);
	Template.AddShooterEffectExclusions(SkipExclusions);

	//costs ... action points
	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = default.iMEDITATION_COST_AP;				// 2
	ActionPointCost.bFreeCost = default.bMEDITATION_COST_FREE;				// false
	ActionPointCost.bConsumeAllPoints = default.bMEDITATION_COST_TURNENDING;// false
	Template.AbilityCosts.AddItem(ActionPointCost);

	//costs ... cooldown
	if (default.iMEDITATION_COST_COOLDOWN > 0)
	{
		Cooldown = new class'X2AbilityCooldown';
		Cooldown.iNumTurns = default.iMEDITATION_COST_COOLDOWN;				// 3 turns
		Template.AbilityCooldown = Cooldown;
	}

	//costs ... charges
	if (default.iMEDITATION_COST_CHARGES > 0)
	{
		Charges = new class 'X2AbilityCharges';
		Charges.InitialCharges = default.iMEDITATION_COST_CHARGES;			// 0 charges
		Template.AbilityCharges = Charges;

		ChargeCost = new class'X2AbilityCost_Charges';
		ChargeCost.NumCharges = 1;
		Template.AbilityCosts.AddItem(ChargeCost);	
	}

	//costs ... blood
	if (default.iMEDITATION_COST_BLOOD.Damage > 0)									
	{
		//ensure the unit has MORE health than the cost
		CheckHealth = new class 'X2Condition_UnitStatCheck';
			//AddCheckStat(StatType, Value, CheckType=eCheck_Exact, ValueMax=0, ValueMin=0, bCheckAsPercent=false)
		CheckHealth.AddCheckStat(eStat_HP, default.iMEDITATION_COST_BLOOD.Damage, eCheck_GreaterThan);
		Template.AbilityShooterConditions.AddItem(CheckHealth);

		//Apply the damage as 'weapon damage' to self ... uses custom fire anim from above
		Effect = new class'X2Effect_ApplyWeaponDamage';
		Effect.bExplosiveDamage = false;
		Effect.bIgnoreBaseDamage = true;
		//Effect.DamageTag = 'Meditation';
		Effect.bAllowFreeKill = false;
		Effect.bAllowWeaponUpgrade = false;
		Effect.bBypassShields = true;
		Effect.bIgnoreArmor = true;
		Effect.bBypassSustainEffects = true;

			// (Damage = 0, Spread = 0, PlusOne = 0, Crit = 0, Pierce = 0, Shred = 0, Rupture = 0, Tag = "", DamageType="Psi")
		Effect.EffectDamageValue = default.iMEDITATION_COST_BLOOD;			
		Effect.EnvironmentalDamageAmount = 0;

		Template.AddShooterEffect(Effect);
	}

	//actually increase the focus
	FocusEffect = new class'X2Effect_ModifyTemplarFocus';
	FocusEffect.ModifyFocus = default.iMEDITATION_FOCUS_RECOVERY;			// 2
	Template.AddShooterEffect(FocusEffect);

	//override the original caster gauntlets if set
	if (class'X2DownloadableContentInfo_WOTC_RustyMeditation'.default.bOverrideARGauntlets)
	{
		Template.OverrideAbilities.AddItem('Meditation');
	}

	return Template;
}
