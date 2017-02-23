#!/usr/bin/env ruby


require 'sensu-plugin/check/cli'
require 'net/http'
require 'net/https'


class CheckHttpResponseTime < Sensu::Plugin::Check::CLI


  option :sudo,
         short:            '-s',
         long:             '--sudo',
         description:      'run curl with sudo (and possibly avoid running sensu as root)',
         boolean:          true,
         default:          false

  option :url,
         short:            '-u URL',
         long:             '--url URL',
         description:      'relative URL on the given domain, defaults to /',
         default:          '/'

  option :port,
         short:            '-p PORT',
         long:             '--port PORT',
         description:      'port to check on the target host, defaults to 80',
         default:          80

  option :host,
         short:            '-h HOSTNAME',
         long:             '--host HOSTNAME',
         description:      'alternating http-hostname for the given address, overrides the possible hostname of address, using this in combination with an IP-address will result in zero values for time_namelookup',
         default:          nil

  option :address,
         short:            '-a ADDRESS',
         long:             '--address ADDRESS',
         description:      'address to look up (ie. www.gruenderszene.de)',
         required:         true

  option :protocol,
         short:            '-x PROTOCOL',
         long:             '--protocol PROTOCOL',
         description:      'protocol to use in curl query, defaults to https',
         default:          'https'

  option :user,
         short:            '-U USER',
         long:             '--user USER',
         description:      'user to use with basic auth',
         default:          nil

  option :pass,
         short:            '-P PASSWORD',
         long:             '--password',
         description:      'password to use with basic auth',
         default:          nil

  option :method,
         short:            '-m METHOD',
         long:             '--method METHOD',
         description:      'http method to use (GET, POST, DELETE, etc.), defaults to GET',
         default:          'GET'

  option :body_data,
         short:            '-d DATA',
         long:             '--body_data DATA',
         description:      'body data to send along',
         default:          nil

  option :headers,
         short:            '-H HEADER',
         long:             '--headers HEADER',
         description:      'set header field, comma separated',
         default:          ''

  option :user_agent,
         short:            '-A USER_AGENT',
         long:             '--user-agent',
         description:      'set the user agent header',
         default:          nil

  option :warn,
         short:            '-W WARN_LEVEL_IN_MS',
         long:             '--warn-level WARN_LEVEL_IN_MS',
         description:      'values above this threshold will trigger a warning notification, defaults to 500',
         default:          500

  option :critical,
         short:            '-C CRTICIAL_LEVEL_IN_MS',
         long:             '--critical-level CRITICAL_LEVEL_IN_MS',
         description:      'values above this threshold will trigger a critical notification, defaults to 1000',
         default:          1000

  def run

    # init variable
    command = ""

    # enable sudo use if requested
    command += "sudo " if config[:sudo]

    # basic command
    command += "curl -sq "

    # prepare domain part
    domain_string = config[:address]
    if config[:port]
      config[:host] = config[:address] if !config[:host]
      domain_string += ":#{config[:port]}"
    end

    # add all headers
    config[:headers].split(',').each do |header_string|
      command += "-H \"#{header_string.gsub(/"/, '\\"')}\" "
    end

    # prepare optional hostname override
    if config[:host]
      command += "-H \"Host: #{config[:host]}\" "
    end

    # add body
    command += "-d '#{config[:body_data].gsub(/'/, "\\'")}' " if config[:body_data]

    # use specified method
    command += "-X#{config[:method].upcase} " if config[:method]

    # use given username and password
    if config[:user]
      command += "-u #{config[:user]}"
      command += ":#{config[:pass]}"
      command += " "
    end

    # add user agent
    command += "-A '#{config[:user_agent].gsub(/'/, "\\'")}' " if config[:user_agent]

    # squelch site output
    command += '--output /dev/null '

    command += '-w "%{time_total}"'

    # add target uri
    command += "\"#{config[:protocol]}://#{domain_string}#{config[:url]}\""

    # fetch stats
    time_total = `#{command}`
    time_total_ms = (time_total.to_f * 1000.0).ceil.to_i

    if time_total > config[:critical]
      critical "request exceeded critical level: #{time_total}ms"
    elsif time_total > config[:warning]
      warning "request exceeded warning level: #{time_total}ms"
    end

  end

end

