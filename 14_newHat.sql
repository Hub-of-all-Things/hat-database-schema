--liquibase formatted sql

--changeset hubofallthings:jsonData context:structuresonly

CREATE TABLE hat.data_json (
  record_id UUID      NOT NULL PRIMARY KEY,
  source    VARCHAR   NOT NULL,
  owner     UUID      NOT NULL REFERENCES hat.user_user (user_id),
  date      TIMESTAMP NOT NULL DEFAULT (NOW()),
  data      JSONB     NOT NULL,
  hash      BYTEA NOT NULL UNIQUE
);

--rollback DROP TABLE hat.data_json;

--changeset hubofallthings:jsonDataGroups context:structuresonly

CREATE TABLE hat.data_json_groups (
  group_id UUID      NOT NULL PRIMARY KEY,
  owner    UUID      NOT NULL REFERENCES hat.user_user (user_id),
  date     TIMESTAMP NOT NULL DEFAULT (NOW())
);

CREATE TABLE hat.data_json_group_records (
  group_id  UUID NOT NULL REFERENCES hat.data_json_groups (group_id),
  record_id UUID NOT NULL REFERENCES hat.data_json (record_id),
  PRIMARY KEY (group_id, record_id)
);

--rollback DROP TABLE hat.data_json_group_records;
--rollback DROP TABLE hat.data_json_groups;

--changeset hubofallthings:combinators-bundles context:structuresonly

CREATE TABLE hat.data_combinators (
  combinator_id VARCHAR NOT NULL PRIMARY KEY,
  combinator    JSONB   NOT NULL
);

CREATE TABLE hat.data_bundles (
  bundle_id VARCHAR NOT NULL PRIMARY KEY,
  bundle    JSONB   NOT NULL
);

--rollback DROP TABLE hat.data_combinators;
--rollback DROP TABLE hat.data_bundles;

--changeset hubofallthings:hatServiceNamespaces
ALTER TABLE hat.applications ADD COLUMN namespace VARCHAR NOT NULL DEFAULT('');
UPDATE hat.applications SET namespace = lower(title);
UPDATE hat.applications SET namespace = 'rumpel' WHERE title = 'RumpelLite';

--changeset hubofallthings:newDataDebits

CREATE TABLE hat.data_debit_contract (
  data_debit_key VARCHAR   NOT NULL PRIMARY KEY,
  date_created   TIMESTAMP NOT NULL,
  client_id      UUID      NOT NULL REFERENCES hat.user_user (user_id)
);

CREATE TABLE hat.data_debit_bundle (
  data_debit_key VARCHAR   NOT NULL REFERENCES hat.data_debit_contract (data_debit_key),
  bundle_id      VARCHAR   NOT NULL REFERENCES hat.data_bundles (bundle_id),
  date_created   TIMESTAMP NOT NULL,
  start_date     TIMESTAMP NOT NULL,
  end_date       TIMESTAMP NOT NULL,
  rolling        BOOLEAN   NOT NULL,
  enabled        BOOLEAN   NOT NULL,
  PRIMARY KEY (data_debit_key, bundle_id)
);

--changeset hubofallthings:userRoles

CREATE TABLE hat.user_role_available (
  name VARCHAR PRIMARY KEY
);

CREATE TABLE hat.user_role (
  user_id UUID REFERENCES hat.user_user (user_id)            NOT NULL,
  role    VARCHAR REFERENCES hat.user_role_available (name)  NOT NULL,
  extra   VARCHAR
);

INSERT INTO hat.user_role_available VALUES ('owner');
INSERT INTO hat.user_role_available VALUES ('platform');
INSERT INTO hat.user_role_available VALUES ('validate');

INSERT INTO hat.user_role_available VALUES ('datadebit');
INSERT INTO hat.user_role_available VALUES ('datacredit');
INSERT INTO hat.user_role_available VALUES ('namespacewrite');
INSERT INTO hat.user_role_available VALUES ('namespaceread');

INSERT INTO hat.user_role SELECT user_id, lower(role), NULL
                          FROM hat.user_user;

ALTER TABLE hat.user_user
  DROP COLUMN role;

--rollback ALTER TABLE hat.user_user ADD COLUMN role VARCHAR NOT NULL DEFAULT('');
--rollback UPDATE hat.user_user SET hat.user_user.role = hat.user_role.role FROM hat.user_role WHERE hat.user_user.user_id = hat.user_role.user_id
--rollback DROP TABLE hat.user_role;
--rollback DROP TABLE hat.user_role_available;
