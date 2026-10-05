BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "account_notification" (
    "id" bigserial PRIMARY KEY,
    "recipientEmail" text NOT NULL,
    "gardenId" bigint,
    "invitationId" bigint,
    "kind" text NOT NULL,
    "title" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "readAt" timestamp without time zone
);

-- Indexes
CREATE INDEX "notification_recipient_cursor" ON "account_notification" USING btree ("recipientEmail", "id");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "drive_invitation" (
    "id" bigserial PRIMARY KEY,
    "gardenId" bigint NOT NULL,
    "inviterId" text NOT NULL,
    "recipientEmail" text NOT NULL,
    "role" text NOT NULL,
    "expiresAt" timestamp without time zone NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "acceptedBy" text,
    "acceptedAt" timestamp without time zone,
    "declinedAt" timestamp without time zone,
    "revokedAt" timestamp without time zone,
    "deliveryStatus" text NOT NULL DEFAULT 'notConfigured'::text,
    "deliveryMessageId" text,
    "deliveryError" text
);

-- Indexes
CREATE INDEX "invitation_recipient" ON "drive_invitation" USING btree ("recipientEmail", "gardenId");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "drive_invitation"
    ADD CONSTRAINT "drive_invitation_fk_0"
    FOREIGN KEY("gardenId")
    REFERENCES "garden_record"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR garden
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('garden', '20261005104935143-drive-sharing', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261005104935143-drive-sharing', "timestamp" = now();

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
