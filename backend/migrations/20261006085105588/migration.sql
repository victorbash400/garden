BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "conversation" (
    "id" bigserial PRIMARY KEY,
    "gardenId" bigint NOT NULL,
    "creatorId" text NOT NULL,
    "title" text NOT NULL,
    "directKey" text,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "conversation_drive" ON "conversation" USING btree ("gardenId", "id");
CREATE UNIQUE INDEX "conversation_direct" ON "conversation" USING btree ("gardenId", "directKey");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "conversation_member" (
    "id" bigserial PRIMARY KEY,
    "conversationId" bigint NOT NULL,
    "userId" text NOT NULL,
    "readCursor" bigint NOT NULL DEFAULT 0
);

-- Indexes
CREATE UNIQUE INDEX "conversation_member_user" ON "conversation_member" USING btree ("conversationId", "userId");
CREATE INDEX "conversation_user" ON "conversation_member" USING btree ("userId", "conversationId");

--
-- ACTION ALTER TABLE
--
ALTER TABLE "drive_message" ADD COLUMN "conversationId" bigint;
CREATE INDEX "message_conversation_id" ON "drive_message" USING btree ("conversationId", "id");
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "conversation"
    ADD CONSTRAINT "conversation_fk_0"
    FOREIGN KEY("gardenId")
    REFERENCES "garden_record"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "conversation_member"
    ADD CONSTRAINT "conversation_member_fk_0"
    FOREIGN KEY("conversationId")
    REFERENCES "conversation"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "drive_message"
    ADD CONSTRAINT "drive_message_fk_1"
    FOREIGN KEY("conversationId")
    REFERENCES "conversation"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- MIGRATION VERSION FOR garden
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('garden', '20261006085105588', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261006085105588', "timestamp" = now();

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
