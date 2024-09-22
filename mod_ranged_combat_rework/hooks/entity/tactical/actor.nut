::ModRangedCombatRework.HooksMod.hook("scripts/entity/tactical/actor", function(q) {
	q.m.LastStepTile <- null; // to track the position of last tile before taking a step
	q.m.WatcherAttackCount <- 0; // to determine how many attack a watcher can do before stopping

	q.setLastStepTile <- function( _result, _newTile )
	{
		if (_result)
			m.LastStepTile = _newTile; // to update the tile
		
		return _result;
	}

	q.onRemovedFromMap = @(__original) function()
	{
		::Tactical.Entities.removeOverwatchZone(this);

		__original();
	}

	q.onTurnStart = @(__original) function()
	{
		m.WatcherAttackCount = 0; // reset the count, can set it back in the skill

		__original();
	}

	q.onMovementStart = @(__original) function( _tile, _numTiles )
	{
		__original(_tile, _numTiles);

		// set the current as this
		m.LastStepTile = _tile;
	}

	q.onMovementStep = @(__original) function( _tile, _levelDifference )
	{
		local ret = __original(_tile, _levelDifference);

		if (
			!ret // result is fasle so can't even move
			|| m.CurrentMovementType == ::Const.Tactical.MovementType.Involuntary // this is being pushed back not actual regular movement
			|| !::Tactical.TurnSequenceBar.isActiveEntity(this); // not on my turn lol
		)
			return setLastStepTile(ret, _tile);

		if (
			m.CurrentProperties.IsImmuneToZoneOfControl // has immunity
			|| m.LastStepTile.IsHidingEntity // has hiding place
			|| m.LastStepTile.Properties.Effect != null && m.LastStepTile.Properties.Effect.Type == "smoke" // within smokescreen
		)
			return setLastStepTile(ret, _tile);

		local overwatchZones = ::Tactical.Entities.getWatchersByActor(this);

		if (overwatchZones.len() == 0) // no watcher found
			return setLastStepTile(__original(_tile, _levelDifference), _tile);

		::MSU.Array.shuffle(overwatchZones); // let them be randomized
		local self = this;

		foreach (watcher in overwatchZones)
		{
			if (watcher.m.WatcherAttackCount <= 0)
				continue; // has no counter to perform attack

			if (watcher.getMoraleState() == ::Const.MoraleState.Fleeing || watcher.getCurrentProperties().IsStunned)
				continue; // can't act at all

			if (!watcher.getCurrentProperties().getVision() < watcher.getTile().getDistanceTo(self.m.LastStepTile))
				continue; // not within vision

			local AoO = watcher.getSkills().getSkillsByFunction(function(_skill) {
				if (::Const.Tactical.RangedAoOList.find(_skill.getID()) == null)
					return false; // must be a valid skill

				if (_skill.isDisabled() || !_skill.isUsable() || !_skill.isInRange(self.m.LastStepTile, watcher.getTile()))
					return false; // can be used on that tile

				// mustnt be blocked by cover
				return ::Const.Tactical.Common.getBlockedTiles(watcher.getTile(), self.m.LastStepTile, watcher.getFaction()).len() == 0;
			});

			if (AoO.len() == 0)
				continue; // no valid skill to use

			// save up these values
			local previous = AoO[0].m.IsVisibleTileNeeded, delay = AoO[0].m.Delay;

			// a hack to go around the range restriction outside of user's turn
			AoO[0].m.Delay = 0;
			AoO[0].m.IsVisibleTileNeeded = false;

			// perform the attack
			AoO[0].useForFree(self.m.LastStepTile);

			 // restore them back to normal
			AoO[0].m.IsVisibleTileNeeded = previous;
			AoO[0].m.Delay = delay;
			return false; // deny the movement
		}

		return setLastStepTile(ret, _tile);
	}

	q.onMovementFinish = @(__original) function( _tile )
	{
		__original(_tile);

		// reset it
		m.LastStepTile = null;
	}

});