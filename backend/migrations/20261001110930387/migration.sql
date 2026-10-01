BEGIN;

--
-- ACTION ALTER TABLE
--
--
-- ACTION ALTER TABLE
--
--
-- ACTION ALTER TABLE
--
--
-- ACTION ALTER TABLE
--
--
-- ACTION ALTER TABLE
--
--
-- ACTION ALTER TABLE
--
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "drive_event"
    ADD CONSTRAINT "drive_event_fk_0"
    FOREIGN KEY("gardenId")
    REFERENCES "garden_record"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "file_chunk"
    ADD CONSTRAINT "file_chunk_fk_0"
    FOREIGN KEY("versionId")
    REFERENCES "file_version"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "file_comment"
    ADD CONSTRAINT "file_comment_fk_0"
    FOREIGN KEY("nodeId")
    REFERENCES "file_node"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "file_lease"
    ADD CONSTRAINT "file_lease_fk_0"
    FOREIGN KEY("nodeId")
    REFERENCES "file_node"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "file_node"
    ADD CONSTRAINT "file_node_fk_0"
    FOREIGN KEY("gardenId")
    REFERENCES "garden_record"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "file_version"
    ADD CONSTRAINT "file_version_fk_0"
    FOREIGN KEY("nodeId")
    REFERENCES "file_node"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- MIGRATION VERSION FOR garden
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('garden', '20261001110930387', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261001110930387', "timestamp" = now();

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
