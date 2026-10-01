BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "drive_event" (
    "id" bigserial PRIMARY KEY,
    "gardenId" bigint NOT NULL,
    "revision" bigint NOT NULL,
    "operation" text NOT NULL,
    "authorId" text NOT NULL,
    "node" json,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "event_revision_unique" ON "drive_event" USING btree ("gardenId", "revision");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "file_chunk" (
    "id" bigserial PRIMARY KEY,
    "versionId" bigint NOT NULL,
    "chunkIndex" bigint NOT NULL,
    "size" bigint NOT NULL,
    "checksum" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "chunk_unique" ON "file_chunk" USING btree ("versionId", "chunkIndex");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "file_comment" (
    "id" bigserial PRIMARY KEY,
    "nodeId" bigint NOT NULL,
    "authorId" text NOT NULL,
    "text" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "comment_node" ON "file_comment" USING btree ("nodeId", "createdAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "file_lease" (
    "id" bigserial PRIMARY KEY,
    "nodeId" bigint NOT NULL,
    "holderId" text NOT NULL,
    "token" text NOT NULL,
    "expiresAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "lease_node_unique" ON "file_lease" USING btree ("nodeId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "file_node" (
    "id" bigserial PRIMARY KEY,
    "gardenId" bigint NOT NULL,
    "parentId" bigint NOT NULL,
    "name" text NOT NULL,
    "activeName" text,
    "kind" text NOT NULL,
    "size" bigint NOT NULL DEFAULT 0,
    "version" bigint NOT NULL DEFAULT 0,
    "deleted" boolean NOT NULL DEFAULT false,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "node_sibling_unique" ON "file_node" USING btree ("gardenId", "parentId", "activeName");
CREATE INDEX "node_directory" ON "file_node" USING btree ("gardenId", "parentId", "deleted");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "file_version" (
    "id" bigserial PRIMARY KEY,
    "nodeId" bigint NOT NULL,
    "authorId" text NOT NULL,
    "baseVersion" bigint NOT NULL,
    "size" bigint NOT NULL,
    "chunkCount" bigint NOT NULL,
    "committed" boolean NOT NULL DEFAULT false,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "version_node" ON "file_version" USING btree ("nodeId", "committed", "createdAt");

--
-- ACTION ALTER TABLE
--
ALTER TABLE "garden_record" ADD COLUMN "revision" bigint NOT NULL DEFAULT 0;

--
-- MIGRATION VERSION FOR garden
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('garden', '20261001104438617', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261001104438617', "timestamp" = now();

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
