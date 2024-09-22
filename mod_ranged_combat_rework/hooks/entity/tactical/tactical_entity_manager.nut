::ModRangedCombatRework.HooksMod.hook("scripts/entity/tactical/tactical_entity_manager", function(q) {
	q.m.OverwatchZone <- {};

	q.getOverwatchZone <- function()
	{
		return m.OverwatchZone;
	}

	q.getOverwatchZoneByID <- function( _ID )
	{
		if (_ID in m.OverwatchZone)
			return m.OverwatchZone[_ID];
		else
			return null;
	}

	q.getOverwatchZoneUser <- function( _user )
	{
		return getOverwatchZoneByID(_user.getID());
	}

	q.addOverwatchZone <- function( _user, _tileArray )
	{
		if (_user.getID() in m.OverwatchZone)
			m.OverwatchZone[_user.getID()] = {};
		else
			m.OverwatchZone[_user.getID()] <- {};

		foreach (tile in _tileArray)
		{
			m.OverwatchZone[_user.getID()][tile.ID] <- 
			{
				X = tile.SquareCoords.X,
				Y = tile.SquareCoords.Y
			};
		}
	}

	q.removeOverwatchZone <- function( _user )
	{
		return m.OverwatchZone.rawdelete(_user.getID()) != null;
	}

	q.isTileInsideOverwatchZone <- function( _tile )
	{
		foreach (id, zoneTable in m.OverwatchZone)
		{
			if (_tile.ID in zoneTable)
				return true;
		}

		return false;
	}

	q.isActorInsideOverwatchZone <- function( _actor )
	{
		foreach (id, zoneTable in m.OverwatchZone)
		{
			if (!(_actor.getTile().ID in zoneTable))
				continue;

			local e = ::Tactical.getEntityByID(id);

			if (e != null && e.isPlacedOnMap() && e.isAlive() && !e.isAlliedWith(_actor))
				return true;
		}

		return false;
	}

	q.getWatchersByActor <- function( _actor )
	{
		local ret = [];

		foreach (id, zoneTable in m.OverwatchZone)
		{
			if (!(_actor.getTile().ID in zoneTable))
				continue;

			local e = ::Tactical.getEntityByID(id);

			if (e == null || !e.isPlacedOnMap() || !e.isAlive() || e.isAlliedWith(_actor))
				continue;

			ret.push(e);
		}

		return ret;
	}

});