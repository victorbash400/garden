BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "account_notification" ADD COLUMN "conversationId" bigint;
--
-- ACTION CREATE TABLE
--
CREATE TABLE "inbox_event" (
    "id" bigserial PRIMARY KEY,
    "userId" text NOT NULL,
    "gardenId" bigint NOT NULL,
    "conversationId" bigint,
    "kind" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "inbox_user_cursor" ON "inbox_event" USING btree ("userId", "id");


--
-- MIGRATION VERSION FOR garden
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('garden', '20261006093033965', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261006093033965', "timestamp" = now();

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
