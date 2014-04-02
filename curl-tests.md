# REST API example

The REST API to the example app is described below.

## Get list of Things

### Request

`GET /thing/`

    curl -i -H 'Accept: application/json' http://localhost:7000/thing/

### Response

    HTTP/1.1 200 OK
    Date: Wed, 02 Apr 2014 03:29:58 GMT
    Status: 200 OK
    Connection: close
    Content-Type: application/json;charset=utf-8
    Content-Length: 2
    X-Content-Type-Options: nosniff
    
    []

## Create a new Thing

### Request

`POST /thing/`

    curl -i -H 'Accept: application/json' -d 'name=Foo&status=new' http://localhost:7000/thing

### Response

    HTTP/1.1 201 Created
    Date: Wed, 02 Apr 2014 03:29:58 GMT
    Status: 201 Created
    Connection: close
    Content-Type: application/json;charset=utf-8
    Location: /thing/1
    Content-Length: 36
    X-Content-Type-Options: nosniff
    
    {"id":1,"name":"Foo","status":"new"}

## Get a specific Thing

### Request

`GET /thing/id`

    curl -i -H 'Accept: application/json' http://localhost:7000/thing/1

### Response

    HTTP/1.1 200 OK
    Date: Wed, 02 Apr 2014 03:29:58 GMT
    Status: 200 OK
    Connection: close
    Content-Type: application/json;charset=utf-8
    Content-Length: 36
    X-Content-Type-Options: nosniff
    
    {"id":1,"name":"Foo","status":"new"}

## Get a non-existent Thing

### Request

`GET /thing/id`

    curl -i -H 'Accept: application/json' http://localhost:7000/thing/9999

### Response

    HTTP/1.1 404 Not Found
    Date: Wed, 02 Apr 2014 03:29:58 GMT
    Status: 404 Not Found
    Connection: close
    Content-Type: application/json;charset=utf-8
    Content-Length: 35
    X-Content-Type-Options: nosniff
    
    {"status":404,"reason":"Not found"}

## Create another new Thing

### Request

`POST /thing/`

    curl -i -H 'Accept: application/json' -d 'name=Bar&junk=rubbish' http://localhost:7000/thing

### Response

    HTTP/1.1 201 Created
    Date: Wed, 02 Apr 2014 03:29:58 GMT
    Status: 201 Created
    Connection: close
    Content-Type: application/json;charset=utf-8
    Location: /thing/2
    Content-Length: 35
    X-Content-Type-Options: nosniff
    
    {"id":2,"name":"Bar","status":null}

## Get list of Things again

### Request

`GET /thing/`

    curl -i -H 'Accept: application/json' http://localhost:7000/thing/

### Response

    HTTP/1.1 200 OK
    Date: Wed, 02 Apr 2014 03:29:58 GMT
    Status: 200 OK
    Connection: close
    Content-Type: application/json;charset=utf-8
    Content-Length: 74
    X-Content-Type-Options: nosniff
    
    [{"id":1,"name":"Foo","status":"new"},{"id":2,"name":"Bar","status":null}]

## Change a Thing's state

### Request

`PUT /thing/:id/status/changed`

    curl -i -H 'Accept: application/json' -X PUT http://localhost:7000/thing/1/status/changed

### Response

    HTTP/1.1 200 OK
    Date: Wed, 02 Apr 2014 03:29:59 GMT
    Status: 200 OK
    Connection: close
    Content-Type: application/json;charset=utf-8
    Content-Length: 40
    X-Content-Type-Options: nosniff
    
    {"id":1,"name":"Foo","status":"changed"}

## Get changed Thing

### Request

`GET /thing/id`

    curl -i -H 'Accept: application/json' http://localhost:7000/thing/1

### Response

    HTTP/1.1 200 OK
    Date: Wed, 02 Apr 2014 03:29:59 GMT
    Status: 200 OK
    Connection: close
    Content-Type: application/json;charset=utf-8
    Content-Length: 40
    X-Content-Type-Options: nosniff
    
    {"id":1,"name":"Foo","status":"changed"}

## Change a Thing

### Request

`PUT /thing/:id`

    curl -i -H 'Accept: application/json' -X PUT -d 'name=Foo&status=changed2' http://localhost:7000/thing/1

### Response

    HTTP/1.1 200 OK
    Date: Wed, 02 Apr 2014 03:29:59 GMT
    Status: 200 OK
    Connection: close
    Content-Type: application/json;charset=utf-8
    Content-Length: 41
    X-Content-Type-Options: nosniff
    
    {"id":1,"name":"Foo","status":"changed2"}

## Attempt to change a Thing using partial params

### Request

`PUT /thing/:id`

    curl -i -H 'Accept: application/json' -X PUT -d 'status=changed3' http://localhost:7000/thing/1

### Response

    HTTP/1.1 200 OK
    Date: Wed, 02 Apr 2014 03:29:59 GMT
    Status: 200 OK
    Connection: close
    Content-Type: application/json;charset=utf-8
    Content-Length: 41
    X-Content-Type-Options: nosniff
    
    {"id":1,"name":"Foo","status":"changed3"}

## Attempt to change a Thing using invalid params

### Request

`PUT /thing/:id`

    curl -i -H 'Accept: application/json' -X PUT -d 'id=99&status=changed4' http://localhost:7000/thing/1

### Response

    HTTP/1.1 200 OK
    Date: Wed, 02 Apr 2014 03:29:59 GMT
    Status: 200 OK
    Connection: close
    Content-Type: application/json;charset=utf-8
    Content-Length: 41
    X-Content-Type-Options: nosniff
    
    {"id":1,"name":"Foo","status":"changed4"}

## Change a Thing using the _method hack

### Request

`POST /thing/:id?_method=POST`

    curl -i -H 'Accept: application/json' -X POST -d 'name=Baz&_method=PUT' http://localhost:7000/thing/1

### Response

    HTTP/1.1 200 OK
    Date: Wed, 02 Apr 2014 03:29:59 GMT
    Status: 200 OK
    Connection: close
    Content-Type: application/json;charset=utf-8
    Content-Length: 41
    X-Content-Type-Options: nosniff
    
    {"id":1,"name":"Baz","status":"changed4"}

## Change a Thing using the _method hack in the url

### Request

`POST /thing/:id?_method=POST`

    curl -i -H 'Accept: application/json' -X POST -d 'name=Qux' http://localhost:7000/thing/1?_method=PUT

### Response

    HTTP/1.1 404 Not Found
    Date: Wed, 02 Apr 2014 03:29:59 GMT
    Status: 404 Not Found
    Connection: close
    Content-Type: text/html;charset=utf-8
    Content-Length: 35
    X-XSS-Protection: 1; mode=block
    X-Content-Type-Options: nosniff
    X-Frame-Options: SAMEORIGIN
    
    {"status":404,"reason":"Not found"}

## Delete a Thing

### Request

`DELETE /thing/id`

    curl -i -H 'Accept: application/json' -X DELETE http://localhost:7000/thing/1/

### Response

    HTTP/1.1 204 No Content
    Date: Wed, 02 Apr 2014 03:29:59 GMT
    Status: 204 No Content
    Connection: close
    X-Content-Type-Options: nosniff
    

## Try to delete same Thing again

### Request

`DELETE /thing/id`

    curl -i -H 'Accept: application/json' -X DELETE http://localhost:7000/thing/1/

### Response

    HTTP/1.1 404 Not Found
    Date: Wed, 02 Apr 2014 03:29:59 GMT
    Status: 404 Not Found
    Connection: close
    Content-Type: application/json;charset=utf-8
    Content-Length: 35
    X-Content-Type-Options: nosniff
    
    {"status":404,"reason":"Not found"}

## Get deleted Thing

### Request

`GET /thing/1`

    curl -i -H 'Accept: application/json' http://localhost:7000/thing/1

### Response

    HTTP/1.1 404 Not Found
    Date: Wed, 02 Apr 2014 03:29:59 GMT
    Status: 404 Not Found
    Connection: close
    Content-Type: application/json;charset=utf-8
    Content-Length: 35
    X-Content-Type-Options: nosniff
    
    {"status":404,"reason":"Not found"}

## Delete a Thing using the _method hack

### Request

`DELETE /thing/id`

    curl -i -H 'Accept: application/json' -X POST -d'_method=DELETE' http://localhost:7000/thing/2/

### Response

    HTTP/1.1 204 No Content
    Date: Wed, 02 Apr 2014 03:29:59 GMT
    Status: 204 No Content
    Connection: close
    X-Content-Type-Options: nosniff
    

