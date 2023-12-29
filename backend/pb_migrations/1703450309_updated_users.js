/// <reference path="../pb_data/types.d.ts" />
migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("_pb_users_auth_")

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "jiehiggi",
    "name": "access",
    "type": "select",
    "required": false,
    "presentable": false,
    "unique": false,
    "options": {
      "maxSelect": 1,
      "values": [
        "admin",
        "mod"
      ]
    }
  }))

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "g6acbll7",
    "name": "characters",
    "type": "relation",
    "required": false,
    "presentable": false,
    "unique": false,
    "options": {
      "collectionId": "1lvfhuoudydnlz4",
      "cascadeDelete": false,
      "minSelect": null,
      "maxSelect": null,
      "displayFields": null
    }
  }))

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "eg4wt5v8",
    "name": "banned",
    "type": "bool",
    "required": false,
    "presentable": false,
    "unique": false,
    "options": {}
  }))

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("_pb_users_auth_")

  // remove
  collection.schema.removeField("jiehiggi")

  // remove
  collection.schema.removeField("g6acbll7")

  // remove
  collection.schema.removeField("eg4wt5v8")

  return dao.saveCollection(collection)
})
