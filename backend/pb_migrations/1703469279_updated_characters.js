/// <reference path="../pb_data/types.d.ts" />
migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("1lvfhuoudydnlz4")

  collection.listRule = "@request.headers.token != \"\" && @request.auth.id != \"\""
  collection.viewRule = "@request.headers.token != \"\" && @request.auth.id != \"\""
  collection.createRule = "@request.headers.token != \"\" && @request.auth.id != \"\""
  collection.updateRule = "@request.headers.token != \"\" && @request.auth.id != \"\""
  collection.deleteRule = "@request.headers.token != \"\" && @request.auth.id != \"\""

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("1lvfhuoudydnlz4")

  collection.listRule = "@request.headers.token != \"\""
  collection.viewRule = "@request.headers.token != \"\""
  collection.createRule = "@request.headers.token != \"\""
  collection.updateRule = "@request.headers.token != \"\""
  collection.deleteRule = "@request.headers.token != \"\""

  return dao.saveCollection(collection)
})
