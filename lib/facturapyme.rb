require 'uri'
require 'net/https'
require 'json'

class FacturaPyme

  def initialize (host, api_key, version = 'v1')
    @headers = {
      'User-Agent' =>  'SDK FacturaPyme',
      'Cache-Control' =>  'no-cache',
      'Authorization' =>  api_key
    }
    @url = URI.parse(host+ '/api/'+ version +'/')
    @http = Net::HTTP.new(@url.host, @url.port)
    self.ssl(true)
  end

  def debug()
    @http.set_debug_output($stdout)
  end

  def ssl(ssl)
    @http.use_ssl = ssl
  end

  def get (endPoint)
    uri = URI.parse(@url.to_s+endPoint)
    request = Net::HTTP::Get.new(uri.request_uri, @headers)
    return self.processResponse(@http.request(request))
  end

  def post(endPoint, data)
    uri = URI.parse(@url.to_s+endPoint)
    request = Net::HTTP::Post.new(uri.request_uri, @headers)
    request.content_type = 'application/json'
    request.body = JSON.generate(data)
    return self.processResponse(@http.request(request))
  end

  def pdf(tipoDte, folio)
      return self.get('dte/pdf/'+tipoDte.to_s+'/'+folio.to_s)
  end

  def xml(tipoDte, folio)
      return self.get('dte/xml/'+tipoDte.to_s+'/'+folio.to_s)
  end

  def enviaDTE(documento)
      return self.post('dte', documento)
  end
  def estadoDTE(id)
      return self.get('dte/'+id.to_s)
  end
  def processResponse(response)
    body = response.body
    if response.content_type == 'application/json'
        body = JSON.parse(body)
    end
    if response.code.to_i > 400
       raise 'error:['+response.code+']'+body['error']
    end
    return body
  end
end
