# COlony game

This is a prototype of a city builder / colony sim / RPG mix type of game. You play as a new settlement in a completely wild area.
Inspirations include Bloons Monkey City, Dwarf Fortress, and any RPG I've played (like 2).

The main game loop is the following:
1. receive a mandate from your capital city
2. work to fulfill the mandate day-by-day
	1. assign workers to resource collection jobs
	2. assign workers to construction jobs
	3. assign workers to self-care jobs
	4. fight against enemy attacks at night
3. fulfill the mandate by having enough resources
4. repeat

## Controls

WASD to move camera around, click on buttons and names, hover over names for extra info sometimes.
Probably buggy because they're Godot defaults speedily thrown together.

## Mechanics

### Time

Time is spent manually, this progresses the day. It's measured in minutes. You can view your current time
as the remaining minutes before the day ends (you get 18 hours to do things) and as a clock time. Once time
is spent, the next day arrives. The moment of the day passing has special things happen, like battles.

### Mandate

At the start of each week, you receive a new mandate. This is a list of resources you have to have at the end of
the week. Then these resources get absorbed and you will be rewarded. Otherwise, you lose standing with your
capital city. If that standing is negative, it's game over. In the prototype, you can miss 2 mandates before that happens.

### Jobs

Jobs are things your workers can do (like cutting a tree, building a house, fishing, moving between residences...).
Jobs take a specific amount of time depending on the amount of workers assigned to the job as well as those
workers' skills (both making the job take less time). Jobs can require resources (used up when job completes)
or tools (not used up) (both are reserved on job creation, so only one job can use the same resouces/tools at a time).

The user interface displays information about jobs on the bottom-right panel and in job creation menus
when you hover over the names.

### Workers

...are what will do jobs for you. Each job takes up energy from the worker, and workers cannot do jobs with no energy
(right now there might be a passive energy regen that bypasses this but shhh...). They also need food around every 18 hours,
and if they don't get it, they lose hp and eventually die. Each worker lives in a residence, which are map tiles, for example houses.
Residences have a maximum capacity, which limits the amount of workers your colony can have. Each day, a new worker joins
your colony with a 75% chance if there is space for it to join.

The user interface displays information about workers when you hover over their names in the worker panel
or in job creation menus.

### Battles

This is the RPG part. If you upset nature enough (-10 standing) (this happens when you cut trees), you'll get attacked.
This is very basic at the moment.
You choose 3 workers as your party members. You can only attack the enemies and they can only attack your first party member.
If all party members die, it's game over, and if all enemies die, it's You win the battle!. Your workers will gain some skill,
but otherwise there is no reward at this time.

## Wishlist for Not Prototype

- Better battles
	- worker skills, buildings affecting what happens
	- more enemies (nature, black magic, enemy civilisations...)
- Building interplay
	- areas of effect e.g. happiness boost between buildings and parks
	- mechanical power - windmills, waterwheels supplying power to craftsstations
- Worker details
	- happiness levels?
- More civilisations
	- diplomacy..? trade routes vs wars
- Art assets, obviously



