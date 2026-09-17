-- Many world-side entrances, and which one is your door (tw_char).
--
-- house_portal was a single row pinned at id = 1, because there was one way in
-- and it lived at one place in the world. That is the wrong shape as soon as
-- the point is a doorway you build: an inn in Goldshire, a house in a village,
-- a cellar somewhere. So the table becomes what it always looked like -- many
-- rows -- and `id` becomes a real auto-increment key rather than the constant 1.
--
-- WHY THE ID MATTERS BEYOND THE ROW: each portal's gameobject guid is derived
-- from it, HOUSE_PORTAL_GUID_MIN + id, carved off the TOP of the housing block
-- while furniture allocates upward from the bottom. So an id is not just a key,
-- it is an address, and reusing one would put a new door where an old one was.
-- Never renumber this table.
--
-- house.portal_id is which entrance that house calls home -- set by clicking a
-- portal and choosing it, or with .house portal home <id>. 0 means none chosen,
-- which is a supported state: the way out then falls back to the hearthstone,
-- exactly as an unplaced portal always did.

ALTER TABLE `house_portal`
    MODIFY COLUMN `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
    ADD COLUMN IF NOT EXISTS `name`       varchar(48) NOT NULL DEFAULT '',
    ADD COLUMN IF NOT EXISTS `created_at` bigint(20)  NOT NULL DEFAULT 0;

ALTER TABLE `house`
    ADD COLUMN IF NOT EXISTS `portal_id` int(10) unsigned NOT NULL DEFAULT 0;
