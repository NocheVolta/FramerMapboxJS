#fixing crossorigin problem

Utils.CORSproxy = (url) ->

		# Detect local IPv4/IvP6 addresses
		# https://stackoverflow.com/a/11327345
		regexp = /(^127\.)|(^192\.168\.)|(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)|(^::1$)|(^[fF][cCdD])/

		if regexp.test(window.location.hostname)
			return "http://#{window.location.host}/_server/proxy/#{url}"
		
		return "https://cors-anywhere.herokuapp.com/#{url}"

#httpRequest function	
exports.HTTPRequest= (url, responseFunc) ->

	r = new XMLHttpRequest
	r.open 'GET', Utils.CORSproxy(url), true
	r.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');

	r.onreadystatechange = ->
		if r.readyState != 4 or r.status != 200
# 			print r.readyState
			return
		else
# 			print respons
			response = JSON.parse(r.responseText)
			
			responseFunc(response)
			
	r.send()		


