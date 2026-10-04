BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "filesystem_receipt" (
    "id" bigserial PRIMARY KEY,
    "gardenId" bigint NOT NULL,
    "authorId" text NOT NULL,
    "request" json NOT NULL,
    "operationId" uuid NOT NULL,
    "events" json NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "filesystem_operation_unique" ON "filesystem_receipt" USING btree ("gardenId", "authorId", "operationId");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "filesystem_receipt"
    ADD CONSTRAINT "filesystem_receipt_fk_0"
    FOREIGN KEY("gardenId")
    REFERENCES "garden_record"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR garden
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('garden', '20261004110221798', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261004110221798', "timestamp" = now();

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
