# sensu-checks-http-response-time

Sensu gem to get http response time checks and metrics. uses curl to gather data.
Supports sudo for better access right management.
Supports user defined metric name addition if you want to test more than one resource per host. (ie. "hostname.appendstring.http_response_time.time_total 123")


## DEPENDENCIES

obviously curl


## INSTALLATION

This gem will give an actual installation explanation, as the default sensu plugins miss it and the sensu documentation lacks any detailed explanation.

If this gem is listed in rubygems.org, you can just go ahead and do
~~sensu-install -p sensu-check-http-response-time~~


Updated:
As Sensu expects the naming to be "sensu-plugins-FOO", you need to do it another way:
```
/opt/sensu/embedded/bin/gem install --no-ri --no-rdoc sensu-checks-http-response-time
```

If this does not work for you, you can still install it; the hard way.
```
git clone git@github.com:vmpublishing/sensu-checks-http-response-time [SOME_PATH]
cd [SOME_PATH]
/opt/sensu/embedded/bin/gem build *.gemspec
/opt/sensu/embedded/bin/gem install *.gem
```

Alter `/opt/sensu/embedded/bin/gem` to the path to the gem-file sensu uses on your machine.


## USAGE

### checks

#### Parameters

| name | parameter_name | default value | required | description |
|------|----------------|---------------|----------|-------------|
| sudo | -s, --sudo | false | no | run curl with sudo (and possibly avoid running sensu as root) |
| url | -u, --URL | / | no | relative URL on the given domain |
| port | -p, --port | 80 | no | port to check on the target host |
| host | -h, --host | nil | no | alternating http-hostname for the given address, overrides the possible hostname of address |
| address | -a, --address |  | yes | address to look up (ie. www.gruenderszene.de) |
| protocol | -x, --protocol | https | no | protocol to use in curl query |
| user | -U, --user | nil | no | optional basic auth username |
| pass | -P, --password | nil | no | optional basic auth password |
| method | -m, --method | GET | no | http method to use (GET, POST, DELETE, etc.) |
| body_data | -d, --body_data | nil | no | body data to send along the request |
| headers | -H, --headers |  | no | set request headers, comma separated |
| user_agent | -A, --user-agent |  | no | user agent string to use for the request |
| warn | -W, --warn-level | 500 | no | values above this threshold will trigger a warning notification |
| critical | -C, --critical-level | 1000 | values above this threshold will trigger a critical notification |

#### sample json config file
```
{
  "checks": {
    "check_some_site_response_time": {
      "command":      "check-http-response-time.rb -h some-site.com -a 123.234.34.45 -x http -W 300 -C 800 -u /favicon.ico",
      "standalone":   "true",
      "interval":     60,
      "timeout":      360,
      "ttl":          300,
      "refresh":      "3600",
      "occurrences":  2
    }
  }
}
```


### metrics

#### Parameters

| name | parameter_name | default value | required | description |
|------|----------------|---------------|----------|-------------|
| sudo | -s, --sudo | false | no | run curl with sudo (and possibly avoid running sensu as root) |
| fields | -f, --fields | time_total,time_namelookup,time_connect,time_pretransfer,time_redirect,time_starttransfer | no | The stats fields to get from curl, comma sepparated. See curl -w |
| scheme | -C, --scheme | hostname | no | Metric naming scheme, text to prepend to metric and scheme_append |
| url | -u, --URL | / | no | relative URL on the given domain |
| port | -p, --port | 80 | no | port to check on the target host |
| host | -h, --host | nil | no | alternating http-hostname for the given address, overrides the possible hostname of address |
| address | -a, --address |  | yes | address to look up (ie. www.gruenderszene.de) |
| protocol | -x, --protocol | https | no | protocol to use in curl query |
| user | -U, --user | nil | no | optional basic auth username |
| pass | -P, --password | nil | no | optional basic auth password |
| method | -m, --method | GET | no | http method to use (GET, POST, DELETE, etc.) |
| body_data | -d, --body_data | nil | no | body data to send along the request |
| headers | -H, --headers |  | no | set request headers, comma separated |
| user_agent | -A, --user-agent |  | no | user agent string to use for the request |

#### sample json config file
```
{
  "metrics": {
    "check_some_site_response_time": {
      "type":         "metric",
      "command":      "check-http-response-time.rb -h some-site.com -a 123.234.34.45 -x http -S somesite.somerole -u /favicon.ico",
      "standalone":   "true",
      "interval":     60,
      "timeout":      360,
      "handlers":     "influxdb-extension",
      "ttl":          300
    }
  }
}
```


## CONTRIBUTING

Bug reports and pull requests are welcome on GitHub at https://github.com/vmpublishing/sensu-checks-http-response-time.

