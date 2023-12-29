/// <reference path="../pb_data/types.d.ts" />
migrate((db) => {
  const collection = new Collection({
    "id": "4azs03x0jxul9qw",
    "created": "2023-12-25 20:01:47.076Z",
    "updated": "2023-12-25 20:01:47.076Z",
    "name": "character",
    "type": "base",
    "system": false,
    "schema": [
      {
        "system": false,
        "id": "cifvmtli",
        "name": "user",
        "type": "relation",
        "required": false,
        "presentable": false,
        "unique": false,
        "options": {
          "collectionId": "_pb_users_auth_",
          "cascadeDelete": false,
          "minSelect": null,
          "maxSelect": 1,
          "displayFields": null
        }
      },
      {
        "system": false,
        "id": "dojlc2zm",
        "name": "name",
        "type": "text",
        "required": false,
        "presentable": false,
        "unique": false,
        "options": {
          "min": null,
          "max": null,
          "pattern": ""
        }
      }
    ],
    "indexes": [],
    "listRule": null,
    "viewRule": null,
    "createRule": null,
    "updateRule": null,
    "deleteRule": null,
    "options": {}
  });

  return Dao(db).saveCollection(collection);
}, (db) => {
  const dao = new Dao(db);
  const collection = dao.findCollectionByNameOrId("4azs03x0jxul9qw");

  return dao.deleteCollection(collection);
})
