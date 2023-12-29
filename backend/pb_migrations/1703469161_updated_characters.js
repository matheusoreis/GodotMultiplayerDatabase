/// <reference path="../pb_data/types.d.ts" />
migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("1lvfhuoudydnlz4")

  collection.listRule = "@request.auth.id != \"\" && @request.headers.token != \"\""
  collection.viewRule = "@request.auth.id != \"\" && @request.headers.token != \"\""
  collection.createRule = "@request.auth.id != \"\" && @request.headers.token != \"\""
  collection.updateRule = "@request.auth.id != \"\" && @request.headers.token != \"\""
  collection.deleteRule = "@request.auth.id != \"\" && @request.headers.token != \"\""

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("1lvfhuoudydnlz4")

  collection.listRule = "@request.auth.id != \"\""
  collection.viewRule = "@request.auth.id != \"\""
  collection.createRule = "@request.auth.id != \"\""
  collection.updateRule = "@request.auth.id != \"\""
  collection.deleteRule = "@request.auth.id != \"\""

  return dao.saveCollection(collection)
})
