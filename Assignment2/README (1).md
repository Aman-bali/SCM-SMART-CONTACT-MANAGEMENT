# Smart Contact Management — Assignment 2 submission

This folder contains the six required assignment deliverables plus this README.

- `design.pdf`: capabilities, service ownership, service contracts, central operation specification, and service-property validation.
- `services.drawio`: editable service design diagram (open at https://app.diagrams.net/).
- `services.png`: exported service design diagram.
- `schema.drawio`: editable data-ownership / ER diagram.
- `schema.png`: exported schema diagram.
- `schema.sql`: MySQL 8.0 target-state schema sketch.

## Important accuracy note
The uploaded project describes a microservice architecture with a Node/Express API Gateway and Java/Spring Boot services. The source also contains inconsistencies: gateway code implements some API paths directly, the media service uses process-local in-memory storage, the notification service stores a process-local dispatch log, and the audit repository currently uses in-memory maps despite MongoDB configuration. The diagrams and SQL are an **assignment benchmark / target-state design**. Proposed persistence is labeled as such in the PDF. The SQL intentionally avoids cross-service foreign keys for user IDs; services should resolve those references through contracts. Audit data is modeled as MongoDB collections and therefore is not represented as SQL CREATE TABLE statements.


## Git commit
From the root of your SCM repository, copy this folder's contents into a directory such as `assignment-2-submission/`, then run:

```bash
git add assignment-2-submission
git commit -m "Add SCM services contracts and schema assignment"
git push
```

Open both `.drawio` files in diagrams.net to edit them. The PNG files are exports for quick review.
