BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "account_username" (
    "id" bigserial PRIMARY KEY,
    "userId" text NOT NULL,
    "username" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "username_user_unique" ON "account_username" USING btree ("userId");
CREATE UNIQUE INDEX "username_unique" ON "account_username" USING btree ("username");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "chat_read" (
    "id" bigserial PRIMARY KEY,
    "gardenId" bigint NOT NULL,
    "userId" text NOT NULL,
    "messageId" bigint NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "chat_read_user" ON "chat_read" USING btree ("gardenId", "userId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "drive_message" (
    "id" bigserial PRIMARY KEY,
    "gardenId" bigint NOT NULL,
    "authorId" text NOT NULL,
    "username" text NOT NULL,
    "text" text NOT NULL,
    "replyToId" bigint,
    "nodeId" bigint,
    "nodeName" text,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "message_drive_id" ON "drive_message" USING btree ("gardenId", "id");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "drive_message"
    ADD CONSTRAINT "drive_message_fk_0"
    FOREIGN KEY("gardenId")
    REFERENCES "garden_record"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


INSERT INTO "account_username" ("userId", "username")
SELECT "authUserId"::text, 'garden_' || substr(md5(random()::text || clock_timestamp()::text || "authUserId"::text), 1, 12)
FROM "serverpod_auth_core_profile";

--
-- MIGRATION VERSION FOR garden
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('garden', '20261006071331375', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261006071331375', "timestamp" = now();

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
