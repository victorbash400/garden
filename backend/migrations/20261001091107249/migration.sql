BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "garden_member" (
    "id" bigserial PRIMARY KEY,
    "gardenId" bigint NOT NULL,
    "userId" text NOT NULL,
    "role" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "garden_user_unique" ON "garden_member" USING btree ("gardenId", "userId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "garden_record" (
    "id" bigserial PRIMARY KEY,
    "name" text NOT NULL,
    "ownerId" text NOT NULL,
    "invitationHash" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "invitation_hash_unique" ON "garden_record" USING btree ("invitationHash");


--
-- MIGRATION VERSION FOR garden
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('garden', '20261001091107249', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261001091107249', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260824182259319', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182259319', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260924105404509', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105404509', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260924105232991', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105232991', "timestamp" = now();


COMMIT;
