/// <reference path="../pb_data/types.d.ts" />
migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("1lvfhuoudydnlz4")

  collection.createRule = " @request.auth.id != \"\""

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("1lvfhuoudydnlz4")

  collection.createRule = " @request.auth.id != \"\" && @request.auth.email != \"\""

  return dao.saveCollection(collection)
})
