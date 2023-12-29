/// <reference path="../pb_data/types.d.ts" />
migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("4azs03x0jxul9qw")

  // remove
  collection.schema.removeField("zubgv4ba")

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("4azs03x0jxul9qw")

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "zubgv4ba",
    "name": "color",
    "type": "text",
    "required": true,
    "presentable": false,
    "unique": false,
    "options": {
      "min": null,
      "max": null,
      "pattern": ""
    }
  }))

  return dao.saveCollection(collection)
})
