/// <reference path="../pb_data/types.d.ts" />
migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("4azs03x0jxul9qw")

  collection.viewRule = "@request.headers.token = \"ajshdwuqyezbxcbvzxbcvqytuqweyt\""
  collection.createRule = "@request.headers.token = \"ajshdwuqyezbxcbvzxbcvqytuqweyt\""
  collection.updateRule = "@request.headers.token = \"ajshdwuqyezbxcbvzxbcvqytuqweyt\""
  collection.deleteRule = "@request.headers.token = \"ajshdwuqyezbxcbvzxbcvqytuqweyt\""

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("4azs03x0jxul9qw")

  collection.viewRule = "user = @request.auth.id"
  collection.createRule = "user = @request.auth.id"
  collection.updateRule = "user = @request.auth.id"
  collection.deleteRule = "@request.auth.id = user.id"

  return dao.saveCollection(collection)
})
