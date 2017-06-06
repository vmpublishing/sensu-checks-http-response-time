#!/usr/bin/env ruby


require 'sensu-plugin/metric/cli'
require 'socket'


class MetricHttpResponseTime < Sensu::Plugin::Metric::CLI::Graphite

  option :sudo,
         short:            '-s',
         long:             '--sudo',
         description:      'run curl with sudo (and possibly avoid running sensu as root)',
         boolean:          true,
         default:          false

  option :fields,
         short:            '-f fieldlist',
         long:             '--fields fieldlist',
         description:      'The stats fields to get from curl, comma sepparated. See curl -w',
         default:          'time_total,time_namelookup,time_connect,time_pretransfer,time_redirect,time_starttransfer'

  option :scheme,
         short:            '-C SCHEME',
         long:             '--scheme SCHEME',
         description:      'Metric naming scheme, text to prepend to metric and scheme_append',
         default:          "#{Socket.gethostname}"

  option :url,
         short:            '-u URL',
         long:             '--url URL',
         description:      'relative URL on the given domain, defaults to /',
         default:          '/'

  option :port,
         short:            '-p PORT',
         long:             '--port PORT',
         description:      'port to check on the target host, defaults to 80',
         default:          443

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

  option :scheme_append,
         short:            '-S APPEND_STRING',
         long:             '--scheme-append APPEND_STRING',
         description:      'Set a string that will be placed right after the host identification and the script identification but before the measurements',
         default:          nil

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
         long:             '--user-agent USER_AGENT',
         description:      'set the user agent header',
         default:          nil


  def run

    unless config[:fields].empty?

      # init variable
      command = ""

      # enable sudo use if requested
      command += "sudo " if config[:sudo]

      # basic command
      command += "curl -sq "

      # add all headers
      config[:headers].split(',').each do |header_string|
        command += "-H \"#{header_string.gsub(/"/, '\\"')}\" "
      end

      # prepare optional hostname override
      if config[:host] && config[:address]
        command += "--resolve '#{config[:host]}:#{config[:port]}:#{config[:address]}' "
      end

      # add the selected fields
      fields = config[:fields].split(',').map do |field|
        "#{field} %{#{field}}"
      end.join("\n")
      command += "-w \"#{fields}\" "

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

      # add target uri
      domain_string = config[:host] || config[:address]
      command += "\"#{config[:protocol]}://#{domain_string}#{config[:url]}\""

      # fetch stats
      stats_string = `#{command}`

      # send them along
      base_path  = config[:scheme]
      base_path += ".#{config[:scheme_append]}" if config[:scheme_append]
      base_path += ".http_response_time"
      stats_string.split("\n").each do |stat_line|
        stats = stat_line.split(' ').compact
        output "#{base_path}.#{stats[0].gsub(/[^a-zA-Z0-9_\.]/, '_')}", stats[1]
      end

    end

    ok
  end

end

