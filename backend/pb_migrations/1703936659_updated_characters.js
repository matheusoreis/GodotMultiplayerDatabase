/// <reference path="../pb_data/types.d.ts" />
migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("4azs03x0jxul9qw")

  collection.listRule = "@request.headers.token = \"ajshdwuqyezbxcbvzxbcvqytuqweyt\""

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("4azs03x0jxul9qw")

  collection.listRule = "user = @request.auth.id"

  return dao.saveCollection(collection)
})
