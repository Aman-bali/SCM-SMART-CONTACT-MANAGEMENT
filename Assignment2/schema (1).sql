-- Smart Contact Management (SCM) — Assignment 2 schema sketch
-- Dialect: MySQL 8.0. This is a target-state ownership-clean sketch, not a claim
-- that every table is already persisted by the current implementation.
-- Auth owns users; Contact owns contacts/groups; Media owns media metadata;
-- Notification owns delivery records; Gateway owns idempotency records.
-- Audit is MongoDB-backed and Integration is stateless, so neither has SQL tables.

CREATE TABLE IF NOT EXISTS users (
  user_id VARCHAR(64) NOT NULL PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  email VARCHAR(180) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NULL,
  phone_number VARCHAR(30) NULL,
  provider VARCHAR(30) NOT NULL DEFAULT 'LOCAL',
  provider_user_id VARCHAR(120) NULL,
  roles VARCHAR(120) NOT NULL DEFAULT 'ROLE_USER',
  enabled BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_users_provider_identity (provider, provider_user_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS contacts (
  contact_id VARCHAR(64) NOT NULL PRIMARY KEY,
  owner_user_id VARCHAR(64) NOT NULL COMMENT 'Opaque reference to Auth user; no cross-service FK',
  name VARCHAR(120) NOT NULL,
  email VARCHAR(180) NULL,
  phone_number VARCHAR(30) NULL,
  address VARCHAR(300) NULL,
  description VARCHAR(1000) NULL,
  favorite BOOLEAN NOT NULL DEFAULT FALSE,
  website_link VARCHAR(255) NULL,
  linkedin_link VARCHAR(255) NULL,
  picture_url VARCHAR(500) NULL COMMENT 'URL/reference owned by Media service',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_contacts_owner (owner_user_id),
  KEY idx_contacts_email (email),
  KEY idx_contacts_name (name)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS contact_groups (
  group_id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  owner_user_id VARCHAR(64) NOT NULL COMMENT 'Opaque reference to Auth user; no cross-service FK',
  name VARCHAR(80) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_group_owner_name (owner_user_id, name),
  KEY idx_groups_owner (owner_user_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS contact_group_members (
  group_id BIGINT NOT NULL,
  contact_id VARCHAR(64) NOT NULL,
  PRIMARY KEY (group_id, contact_id),
  CONSTRAINT fk_group_members_group FOREIGN KEY (group_id) REFERENCES contact_groups(group_id) ON DELETE CASCADE,
  CONSTRAINT fk_group_members_contact FOREIGN KEY (contact_id) REFERENCES contacts(contact_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS media_assets (
  media_id VARCHAR(64) NOT NULL PRIMARY KEY,
  owner_user_id VARCHAR(64) NOT NULL COMMENT 'Opaque reference to Auth user; no cross-service FK',
  file_name VARCHAR(255) NOT NULL,
  content_type VARCHAR(100) NOT NULL,
  size_bytes BIGINT UNSIGNED NOT NULL,
  storage_key VARCHAR(500) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT chk_media_size CHECK (size_bytes <= 2097152),
  KEY idx_media_owner (owner_user_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS notification_delivery_log (
  notification_id VARCHAR(64) NOT NULL PRIMARY KEY,
  recipient_email VARCHAR(180) NOT NULL,
  notification_type VARCHAR(50) NOT NULL,
  subject VARCHAR(255) NOT NULL,
  delivery_status VARCHAR(40) NOT NULL,
  failure_reason VARCHAR(1000) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_notification_status_created (delivery_status, created_at),
  KEY idx_notification_recipient (recipient_email)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS idempotency_keys (
  idempotency_key VARCHAR(255) NOT NULL PRIMARY KEY,
  scope VARCHAR(255) NOT NULL,
  request_hash CHAR(64) NOT NULL,
  response_status SMALLINT UNSIGNED NOT NULL,
  response_body JSON NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  expires_at TIMESTAMP NULL,
  KEY idx_idempotency_expiry (expires_at)
) ENGINE=InnoDB;

-- Audit service uses document collections (audit-logs, contact-notes, activity-stream)
-- in MongoDB in the intended architecture; collections are documented in schema.drawio.
-- Integration service is stateless and does not own a SQL table.
