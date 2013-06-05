% Andrenaline is useful when we don't have 100 yet
usefulItem(andrenaline, andrenaline) :- status(_, _, Adrenaline, _), Adrenaline < 100.

% Pick up health, the different pills have different limits
usefulItem(health, mini_health)      :- status(Health, _, _, _), Health < 199.

% Don't use the super health pack for just 20 health
usefulItem(health, super_health)     :- status(Health, _, _, _), Health < 180.
usefulItem(health, health)           :- status(Health, _, _, _), Health < 100.
usefulItem(armor, small_armor)       :- status(_, Armour, _, _), Armour < 50.
usefulItem(armor, super_armor)       :- status(_, Armour, _, _), Armour < 150.

% Pick up weapons we don't have yet
usefulItem(weapon, ItemType)         :- not(weapon(ItemType,_,_)).

% Pick up all the ammo when we're not full yet
usefulItem(ammo, assault_rifle)      :- weapon(assault_rifle, Ammo, AltAmmo), (Ammo < 200; AltAmmo < 8).
usefulItem(ammo, bio_rifle)          :- weapon(bio_rifle, Ammo, _),      Ammo < 100.
usefulItem(ammo, shock_rifle)        :- weapon(shock_rifle, Ammo, _),    Ammo < 50.
usefulItem(ammo, minigun)            :- weapon(minigun, Ammo, _),        Ammo < 300.
usefulItem(ammo, link_gun)           :- weapon(link_gun, Ammo, _),       Ammo < 220.
usefulItem(ammo, flak_cannon)        :- weapon(flak_cannon, Ammo, _),    Ammo < 35.
usefulItem(ammo, rocket_launcher)    :- weapon(rocket_launcher, Ammo, _),Ammo < 30.
usefulItem(ammo, lightning_gun)      :- weapon(lightning_gun, Ammo, _),  Ammo < 40.
usefulItem(ammo, sniper_rifle)       :- weapon(sniper_rifle, Ammo, _),   Ammo < 35.

% There are two teams, red and blue (this is needed for otherTeam).
team(red).
team(blue).

% True if the Team is our own team
ownTeam(Team) :- self(_, _, Team).

% True if the Team is the enemy
otherTeam(Team) :- team(Team), not(ownTeam(Team)).

holdingFlag :- flag(_, HolderUnrealID, _), self(HolderUnrealID, _, _).

% Calculate distance from point A to point B
manhattanDistance(A, B, Distance) :-
	location(X1, Y1, _) = A,
	location(X2, Y2, _) = B,
	Dx is abs(X1 - X2), Dy = abs(Y1 - Y2),
	Distance is Dx + Dy.

% Calculate the distance from this agent to object UnrealID
distance(UnrealID, Distance) :-
	navPoint(UnrealID, PointLoc, _),
	orientation(OwnLoc, _, _),
	manhattanDistance(PointLoc, OwnLoc, Distance).

% Calculate the distance from this agent to item UnrealID
distance(UnrealID, Distance) :-
	item(UnrealID, _, _, NavPointID),
	distance(NavPointID, Distance).

% Calculate the distance from this agent to bot UnrealID
distance(UnrealID, Distance) :-
	bot(UnrealID, _, _, BotLoc, _, _),
	orientation(OwnLoc, _, _),
	manhattanDistance(BotLoc, OwnLoc, Distance).

% Are we stuck?
isStuck :- stuckCounter(Count), Count > 5.