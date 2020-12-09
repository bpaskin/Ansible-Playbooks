This is a playbook that checks URLs/URIs and hosts. 

The the following yaml parameters:

```
URIs:
  - myURI1
  - pizza
  - myWebApp
hostAndPorts:
  - 'my1.server.com:19445'
  - 'my1.server.com:19446'
  - 'my2.server.com:19445'
  - 'my2.server.com:19446'
```

In the above, the following URLs will be checked :
`https://my1.server.com:19445/myURI1`, `https://my1.server.com:19445/pizza`, `https://my1.server.com:19445/myWebApp`, `https://my1.server.com:19446/myURI1`, `https://my1.server.com:19446/pizza`, `https://my1.server.com:19446/myWebApp`, `https://my2.server.com:19445/myURI1`, `https://my2.server.com:19445/pizza`, `https://my2.server.com:19445/myWebApp`, `https://my2.server.com:19446/myURI1`, `https://my2.server.com:19446/pizza`, `https://my2.server.com:19446/myWebApp`
