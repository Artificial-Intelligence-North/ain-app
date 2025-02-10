# Artificial Intelligence North

Artificial Intelligence North main application stack

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

- Ruby version

- System dependencies

- Configuration

- Database creation

- Database initialization

- How to run the test suite

- Services (job queues, cache servers, search engines, etc.)

- Deployment instructions

- ...

# Generate JWT keys

```sh
openssl genrsa -out key.pem 512
```

```sh
openssl rsa -in key.pem -outform PEM -pubout -out public.pem
```
