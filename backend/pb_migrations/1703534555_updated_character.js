/// <reference path="../pb_data/types.d.ts" />
migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("4azs03x0jxul9qw")

  collection.name = "characters"

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("4azs03x0jxul9qw")

  collection.name = "character"

  return dao.saveCollection(collection)
})
