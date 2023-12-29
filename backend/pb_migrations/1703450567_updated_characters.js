/// <reference path="../pb_data/types.d.ts" />
migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("1lvfhuoudydnlz4")

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "jhqw6wd1",
    "name": "map_id",
    "type": "number",
    "required": false,
    "presentable": false,
    "unique": false,
    "options": {
      "min": null,
      "max": null,
      "noDecimal": false
    }
  }))

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "ghgbnfg3",
    "name": "position_x",
    "type": "number",
    "required": false,
    "presentable": false,
    "unique": false,
    "options": {
      "min": null,
      "max": null,
      "noDecimal": false
    }
  }))

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "kxjnp5bk",
    "name": "position_y",
    "type": "number",
    "required": false,
    "presentable": false,
    "unique": false,
    "options": {
      "min": null,
      "max": null,
      "noDecimal": false
    }
  }))

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "e1kchffq",
    "name": "is_banned",
    "type": "bool",
    "required": false,
    "presentable": false,
    "unique": false,
    "options": {}
  }))

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("1lvfhuoudydnlz4")

  // remove
  collection.schema.removeField("jhqw6wd1")

  // remove
  collection.schema.removeField("ghgbnfg3")

  // remove
  collection.schema.removeField("kxjnp5bk")

  // remove
  collection.schema.removeField("e1kchffq")

  return dao.saveCollection(collection)
})
