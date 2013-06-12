% Pick up health, the different pills have different limits
neededItem(health, mini_health)      :- status(Health, _, _, _), Health < 20.

% Don't use the super health pack for just 20 health
neededItem(health, super_health)     :- status(Health, _, _, _), Health < 150.
neededItem(health, health)           :- status(Health, _, _, _), Health < 100.
neededItem(armor, small_armor)       :- status(_, Armour, _, _), Armour < 50.
neededItem(armor, super_armor)       :- status(_, Armour, _, _), Armour < 150.

% Need weapons we don't have a good weapon yet
neededItem(weapon, ItemType)         :- not(weapon(ItemType,_,_)), goodWeapon(Good), not(weapon(Good, _, _)).

goodWeapon(flak_cannon).
goodWeapon(rocket_launcher).

% Need ammo when ammo lower than half
neededItem(ammo, flak_cannon)        :- weapon(flak_cannon, Ammo, _),    Ammo < 18.
neededItem(ammo, rocket_launcher)    :- weapon(rocket_launcher, Ammo, _),Ammo < 15.

% Adrenaline is useful when we don't have 100 yet
usefulItem(adrenaline, adrenaline) :- status(_, _, Adrenaline, _), Adrenaline < 100.

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
	location(X1, Y1, Z1) = A,
	location(X2, Y2, Z2) = B,
	Dx is abs(X1 - X2), Dy = abs(Y1 - Y2), Dz = abs(Z1 - Z2),
	Distance is Dx + Dy + Dz.

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

% Combo knowledge:
% choose type of combo according to role
usefullCombo(booster) :- status(Health, _, _, _), Health < 40.
usefullCombo(speed) :- role(flag_capturer).
usefullCombo(beserk) :- role(flag_defender).
usefullCombo(beserk) :- role(defender).
usefullCombo(beserk) :- role(assassin).
usefullCombo(beserk) :- role(attacker).
	
% time the combo
% use booster at any time
goodComboTiming(booster) :- true.

% use speed when:
% holding the flag
goodComboTiming(speed) :- holding(flag).

% seeing the flag
goodComboTiming(speed) :- flag(_, none, _).

% close to the enemy flag
goodComboTiming(speed) :- otherTeam(Team), base(Team, BasePos), distance(BasePos, Distance), Distance < 2000.
	
% use beserk when:
% you see a enemy bot
goodComboTiming(beserk) :- otherTeam(Team), bot(_, _, Team, _, _, _).
