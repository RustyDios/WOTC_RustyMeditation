//*******************************************************************************************
//  FILE:   X2Condition_CheckCurrentFocusLevel                               
//  
//	File created by RustyDios	22/03/20	15:30	
//	LAST UPDATED				26/03/2020	15:30
//
//	A condition to check if current focus level is < or >= Max
//
//*******************************************************************************************

class X2Condition_CheckCurrentFocusLevel extends X2Condition;

//var config setup
var bool bIsNotAtMax;
var bool bIsAtMax;

//call meets condition for target
event name CallMeetsCondition(XComGameState_BaseObject kTarget) 
{
    local XComGameState_Unit				UnitState;
	local XComGameState_Effect_TemplarFocus FocusState; //templar focus state
	local int								FocusLevel;

    UnitState = XComGameState_Unit(kTarget);

    if (UnitState != none)
    {
        //	Prevent meditation if the templar already has max focus, since it would be a waste
		FocusState = UnitState.GetTemplarFocusEffectState();
		Focuslevel = UnitState.GetTemplarFocusLevel();

		if (bIsNotAtMax)
		{
			if (FocusState != none && FocusLevel < FocusState.GetMaxFocus(UnitState) )
			{
				return 'AA_Success'; 
			}
		}

		if (!bIsNotAtMax && bIsAtMax)
		{
			if (FocusState != none && FocusLevel >= FocusState.GetMaxFocus(UnitState) )
			{
				return 'AA_Success'; 
			}
		}

    }
    else 
    {
        return 'AA_NotAUnit';
    }

    return 'AA_AbilityUnavailable'; 
}

/*
//pulled the check from dropped focus loot, X2FocusLootItemTemplate CanBeLootedByUnit
event name CallMeetsConditionWithSource(XComGameState_BaseObject kTarget, XComGameState_BaseObject kSource) 
{ 
	local XComGameState_Unit	SourceUnit; //target and shooter will be the same for this
	local XComGameState_Unit	TargetUnit;
	
	local XComGameState_Effect_TemplarFocus FocusState; //templar focus state
	local int	FocusLevel;

	SourceUnit = XComGameState_Unit(kSource);
	TargetUnit = XComGameState_Unit(kTarget);
	
	if (SourceUnit != none && TargetUnit != none)
	{
		//	Prevent meditation if the templar already has max focus, since it would be a waste
		FocusState = SourceUnit.GetTemplarFocusEffectState();
		Focuslevel = SourceUnit.GetTemplarFocusLevel();

		if (FocusState != none && FocusLevel < FocusState.GetMaxFocus(SourceUnit) )
		{
			return 'AA_Success'; 
		}

		FocusState = TargetUnit.GetTemplarFocusEffectState();
		if (FocusState != none && FocusLevel < FocusState.GetMaxFocus(TargetUnit) )
		{
			return 'AA_Success'; 
		}

	}
	
	return 'AA_AbilityUnavailable';
}
*/
