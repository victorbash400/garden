BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "file_version" ADD COLUMN "operationId" uuid;
ALTER TABLE "file_version" ADD COLUMN "editRequest" text;
CREATE UNIQUE INDEX "version_edit_operation" ON "file_version" USING btree ("authorId", "operationId");

--
-- MIGRATION VERSION FOR garden
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('garden', '20261004123955258', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261004123955258', "timestamp" = now();

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
