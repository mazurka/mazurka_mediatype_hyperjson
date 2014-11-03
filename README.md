mazurka_mediatype_hyperjson
===========================

[hyper+json](https://github.com/hypergroup/hyper-json) media type for [mazurka](https://github.com/mazurka/mazurka)

Examples
--------

### Collection

```js
{
  collection: [
    @users:get(user) + {
      name: users:get_name(user)
    }
  || user <- users:list()]
  create: @users:create()
}
```

results in

```json
{
  "href": "/users",
  "collection": [
    {
      "href": "/users/1",
      "name": "Joe"
    },
    {
      "href": "/users/2",
      "name": "Mike"
    },
    {
      "href": "/users/2",
      "name": "Robert"
    }
  ],
  "create": {
    "action": "/users",
    "method": "POST",
    "input": {
      "name": {
        "type": "text",
        "required": true
      }
    }
  }
}
```
