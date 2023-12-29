/// <reference path="../pb_data/types.d.ts" />
migrate((db) => {
  const collection = new Collection({
    "id": "1lvfhuoudydnlz4",
    "created": "2023-12-24 01:59:05.428Z",
    "updated": "2023-12-24 01:59:05.428Z",
    "name": "characters",
    "type": "base",
    "system": false,
    "schema": [
      {
        "system": false,
        "id": "xt1eubrh",
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
        "id": "q2nta2mt",
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
      },
      {
        "system": false,
        "id": "u8fuytq3",
        "name": "sprite",
        "type": "number",
        "required": false,
        "presentable": false,
        "unique": false,
        "options": {
          "min": null,
          "max": null,
          "noDecimal": false
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
  const collection = dao.findCollectionByNameOrId("1lvfhuoudydnlz4");

  return dao.deleteCollection(collection);
})
