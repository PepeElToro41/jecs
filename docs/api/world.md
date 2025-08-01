# World

A World contains entities which have components. The World is queryable and can be used to get entities with a specific set of components and to perform different kinds of operations on them.

# Functions

## new

`World` utilizes a class, meaning jecs allows you to create multiple worlds.

```luau
function World.new(): World
```

Example:

::: code-group

```luau [luau]
local world = jecs.World.new()
local myOtherWorld = jecs.World.new()
```

```ts [typescript]
import { World } from "@rbxts/jecs";

const world = new World();
const myOtherWorld = new World();
```

:::

# Methods

## entity

Creates a new entity. It accepts the overload to create an entity with a specific ID.

```luau
function World:entity<T>(
	id: Entity<T>? -- The desired id
): Entity<T>
```

Example:

::: code-group
```luau [luau]
local entity = world:entity()
```
```ts [typescript]
const entity = world.entity();
```
:::

## component

Creates a new component. Do note components are entities as well, meaning jecs allows you to add other components onto them.

These are meant to be added onto other entities through `add` and `set`

```luau
function World:component<T>(): Entity<T> -- The new component.
```

Example:

::: code-group

```luau [luau]
local Health = world:component() :: jecs.Entity<number> -- Typecasting this will allow us to know what kind of data the component holds!
```

```ts [typescript]
const Health = world.component<number>();
```

:::

## get

Returns the data present in the component that was set in the entity. Will return nil if the component was a tag or is not present.

```luau
function World:get<T>(
    entity: Entity, -- The entity
    id: Entity<T> -- The component ID to fetch
): T?
```

Example:

::: code-group

```luau [luau]
local Health = world:component() :: jecs.Entity<number>

local Entity = world:entity()
world:set(Entity, Health, 100)

print(world:get(Entity, Health))

-- Outputs:
-- 100
```

```ts [typescript]
const Health = world.component<number>();

const Entity = world.entity();
world.set(Entity, Health, 100);

print(world.get(Entity, Health));

// Outputs:
// 100
```

:::

## has

Returns whether an entity has a component (ID). Useful for checking if an entity has a tag or if you don't care of the data that is inside the component.

```luau
function World:has(
    entity: Entity, -- The entity
    id: Entity<T> -- The component ID to check
): boolean
```

Example:

::: code-group

```luau [luau]
local IsMoving = world:component()
local Ragdolled = world:entity() -- This is a tag, meaning it won't contain data
local Health = world:component() :: jecs.Entity<number>

local Entity = world:entity()
world:set(Entity, Health, 100)
world:add(Entity, Ragdolled)

print(world:has(Entity, Health))
print(world:has(Entity, IsMoving)

print(world:get(Entity, Ragdolled))
print(world:has(Entity, Ragdolled))

-- Outputs:
-- true
-- false
-- nil
-- true
```

```ts [typescript]
const IsMoving = world.component();
const Ragdolled = world.entity(); // This is a tag, meaning it won't contain data
const Health = world.component<number>();

const Entity = world.entity();
world.set(Entity, Health, 100);
world.add(Entity, Ragdolled);

print(world.has(Entity, Health));
print(world.has(Entity, IsMoving));

print(world.get(Entity, Ragdolled));
print(world.has(Entity, Ragdolled));

// Outputs:
// true
// false
// nil
// true
```

:::

## add

Adds a component (ID) to the entity. Useful for adding a tag to an entity, as this adds the component to the entity without any additional values inside

```luau
function World:add(
    entity: Entity, -- The entity
    id: Entity<T> -- The component ID to add
): void
```

::: info
This function is idempotent, meaning if the entity already has the id, this operation will have no side effects.
:::

## set

Adds or changes data in the entity's component.

```luau
function World:set(
    entity: Entity, -- The entity
    id: Entity<T>, -- The component ID to set
    data: T -- The data of the component's type
): void
```

Example:

::: code-group

```luau [luau]
local Health = world:component() :: jecs.Entity<number>

local Entity = world:entity()
world:set(Entity, Health, 100)

print(world:get(Entity, Health))

world:set(Entity, Health, 50)
print(world:get(Entity, Health))

-- Outputs:
-- 100
-- 50
```

```ts [typescript]
const Health = world.component<number>();

const Entity = world.entity();
world.set(Entity, Health, 100);

print(world.get(Entity, Health));

world.set(Entity, Health, 50);
print(world.get(Entity, Health));

// Outputs:
// 100
// 50
```
:::

:::info
`world:set(entity, component, value)` propagates that a change has happened for thes component on this entity, while mutating a value directly would not.
:::

## query

Creates a [`query`](query) with the given components (IDs). Entities that satisfies the conditions of the query will be returned and their corresponding data.

```luau
function World:query(
    ...: Entity -- The components to query with
): Query
```

Example:

::: code-group

```luau [luau]
-- Entity could also be a component if a component also meets the requirements, since they are also entities which you can add more components onto
for entity, position, velocity in world:query(Position, Velocity) do

end
```

```ts [typescript]
// Roblox-TS allows to deconstruct tuples on the act like if they were arrays!
// Entity could also be a component if a component also meets the requirements, since they are also entities which you can add more components onto
for (const [entity, position, velocity] of world.query(Position, Velocity) {
    // Do something
}
```

:::

:::info
Queries are uncached by default, this is generally very cheap unless you have high fragmentation from e.g. relationships.

:::

## target

Get the target of a relationship.
This will return a target (second element of a pair) of the entity for the specified relationship. The index allows for iterating through the targets, if a single entity has multiple targets for the same relationship.
If the index is larger than the total number of instances the entity has for the relationship or if there is no pair with the specified relationship on the entity, the operation will return nil.

```luau
function World:target(
    entity: Entity, -- The entity
    relation: Id, -- The relationship between the entity and the target
    nth: number, -- The index
): Id? -- The target for the relationship at the specified index.
```
Example:

::: code-group

```luau [luau]
local function timers_count(world: types.World)
	local timers = world
		:query(jecs.pair(ct.Timer, jecs.w))
		:without(ct.Destroy)
		:cached()

	return function(_, dt: number)
		for entity in timers do
			local index = 0
			local nth = world:target(entity, ct.Timer, index)
			while nth do
				local timer = world:get(entity, jecs.pair(ct.Timer, nth))
				local elapsed = timer.elapsed + dt
				if elapsed >= timer.duration then
					world:add(entity, ct.Destroy)
				end
				timer.elapsed = elapsed
			end
		end
	end
end
```

```ts [typescript]
const entity = world.entity();
print(world.contains(entity));
print(world.contains(1));
print(world.contains(2));

// Outputs:
// true
// true
// false
```

:::


## parent

Get parent (target of ChildOf relationship) for entity. If there is no ChildOf relationship pair, it will return nil.

```luau
function World:parent(
    child: Entity -- The child ID to find the parent of
): Entity? -- Returns the parent of the child
```

This operation is the same as calling:

```luau
world:target(entity, jecs.ChildOf, 0)
```

## contains

Checks if an entity or component (id) exists in the world.

```luau
function World:contains(
    entity: Entity,
): boolean
```

Example:

::: code-group

```luau [luau]
local entity = world:entity()
print(world:contains(entity))
print(world:contains(1))
print(world:contains(2))

-- Outputs:
-- true
-- true
-- false
```

```ts [typescript]
const entity = world.entity();
print(world.contains(entity));
print(world.contains(1));
print(world.contains(2));

// Outputs:
// true
// true
// false
```

:::

## remove

Removes a component (ID) from an entity

```luau
function World:remove<T>(
    entity: Entity,
	component: Id<T>
): void
```

Example:

::: code-group

```luau [luau]
local IsMoving = world:component()

local entity = world:entity()
world:add(entity, IsMoving)

print(world:has(entity, IsMoving))

world:remove(entity, IsMoving)
print(world:has(entity, IsMoving))

-- Outputs:
-- true
-- false
```

```ts [typescript]
const IsMoving = world.component();

const entity = world.entity();
world.add(entity, IsMoving);

print(world.has(entity, IsMoving));

world.remove(entity, IsMoving);
print(world.has(entity, IsMoving));

// Outputs:
// true
// false
```

:::

## delete

Deletes an entity and all of its related components and relationships.

```luau
function World:delete(
    entity: Entity
): void
```

Example:

::: code-group

```luau [luau]
local entity = world:entity()
print(world:has(entity))

world:delete(entity)

print(world:has(entity))

-- Outputs:
-- true
-- false
```

```ts [typescript]
const entity = world.entity();
print(world.has(entity));

world.delete(entity);

print(world.has(entity));

// Outputs:
// true
// false
```

:::

## clear

Clears all of the components and relationships of the entity without deleting it.

```luau
function World:clear(
    entity: Entity
): void
```

## each

Iterate over all entities with the specified component.
Useful when you only need the entity for a specific ID and you want to avoid creating a query.

```luau
function World:each(
	component: Id -- The component ID
): () -> Entity
```

Example:
::: code-group
```luau [luau]
local id = world:component()
for entity in world:each(id) do
	-- Do something
end
```
```ts [typescript]
const id = world.component();
for (const entity of world.each(id)) {
	// Do something
}
```
:::

## children

Iterate entities in root of parent

```luau
function World:children(
	parent: Entity -- The parent entity
): () -> Entity
```

This is the same as calling:

```luau
world:each(pair(ChildOf, parent))
```

## range

Enforces a check for entities to be created within a desired range.
```luau
function World:range(
	range_begin: number -- The starting point,
	range_end: number? -- The end point (optional)
)
```

Example:

::: code-group
```luau [luau]
world:range(1000, 5000) -- Entities will be created with IDs 1000-5000

local entity = world:entity()
print(entity) -- Will be >= 1000 and < 5000
```
```ts [typescript]
world.range(1000, 5000) // Entities will be created with IDs 1000-5000

const entity = world.entity()
print(entity) // Will be >= 1000 and < 5000
```
:::

## parent

Gets the parent entity of the specified entity using the built-in `ChildOf` relationship.

```luau
function World:parent(
    entity: Entity
): Entity? -- Returns the parent entity or nil if no parent
```

Example:

::: code-group
```luau [luau]
local parent = world:entity()
local child = world:entity()

world:add(child, pair(jecs.ChildOf, parent))

local retrieved_parent = world:parent(child)
print(retrieved_parent == parent) -- true
```
```ts [typescript]
const parent = world.entity()
const child = world.entity()

world.add(child, pair(jecs.ChildOf, parent))

const retrievedParent = world.parent(child)
print(retrievedParent === parent) // true
```
:::

## contains

Checks if an entity exists and is alive in the world.

```luau
function World:contains(
    entity: Entity
): boolean
```

Example:

::: code-group
```luau [luau]
local entity = world:entity()
print(world:contains(entity)) -- true

world:delete(entity)
print(world:contains(entity)) -- false
```
```ts [typescript]
const entity = world.entity()
print(world.contains(entity)) // true

world.delete(entity)
print(world.contains(entity)) // false
```
:::

## exists

Checks if the entity ID exists regardless of whether it is alive or not. Useful to know if the ID is occupied in the entity index.

```luau
function World:exists(
    entity: Entity
): boolean
```

## cleanup

Cleans up deleted entities and their associated data. This is automatically called by jecs, but can be called manually if needed.

```luau
function World:cleanup(): void
```

Example:

::: code-group
```luau [luau]
local entity = world:entity()
world:delete(entity)

-- Cleanup is usually automatic, but can be called manually
world:cleanup()
```
```ts [typescript]
const entity = world.entity()
world.delete(entity)

// Cleanup is usually automatic, but can be called manually
world.cleanup()
```
:::
