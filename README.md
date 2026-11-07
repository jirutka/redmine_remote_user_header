# Redmine Remote-User Header

A minimal Redmine plugin that adds the authenticated user’s login to the `Remote-User` HTTP response header.
It allows reverse proxies such as Nginx to include the username in access logs for individual requests.

```http
Remote-User: flynnkev
```

For unauthenticated requests, Redmine returns:

```http
Remote-User: anonymous
```


## Requirements

Redmine 6.0 or newer. No additional gems or database migrations are required.

GitHub Actions CI tests against Redmine 6.0, 6.1, and 7.0.


## Installation

Clone the repository into Redmine’s `plugins` directory.

```sh
cd /path/to/redmine/plugins
git clone https://github.com/jirutka/redmine_remote_user_header.git
```

Restart Redmine to load the plugin.


## Behavior

The header contains the effective Redmine login from `User.current` after request processing.
Unauthenticated requests use the literal value `anonymous`, including after logout and on failed login attempts.
A missing header means the request was not processed by the plugin or an identity could not be safely determined.
The header also applies to Redmine-generated redirects and authorization errors.


## nginx

Hide the internal response header from clients and add its value to your existing access log format.

```nginx
location / {
    proxy_pass http://redmine;
    proxy_hide_header Remote-User;
}
```

Use `$upstream_http_remote_user` in your `log_format`, for example:

```nginx
log_format redmine escape=json '{'
    '"request":"$request",'
    '"status":$status,'
    '"user.name":"$upstream_http_remote_user"'
    '}';
```

When the header is absent, nginx logs `-`, which should be removed or converted to a missing field in your ingestion pipeline.
The `Remote-User` header is not a standardized authentication mechanism and must not be trusted when supplied by clients.


## Tests

Run integration tests from the Redmine root with a configured test database:

```sh
RAILS_ENV=test bundle exec rake db:prepare
RAILS_ENV=test bundle exec rake redmine:plugins:test NAME=redmine_remote_user_header
```

GitHub Actions runs the test suite against the supported Redmine versions.


## License

This project is licensed under [MIT License](http://opensource.org/licenses/MIT/).
For the full text of the license, see the [LICENSE](LICENSE) file.
