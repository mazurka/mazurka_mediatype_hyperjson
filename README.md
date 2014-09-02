mazurka_mediatype_hyperjson
===========================

[hyper+json](https://github.com/hypergroup/hyper-json) media type for [mazurka](https://github.com/mazurka/mazurka)

Examples
--------

### Collection

```js
{
  collection: [
    @users.get(User.id) + {
      name: User.name
    }
  || User <- Users]
  create: @users.create()
}
```
