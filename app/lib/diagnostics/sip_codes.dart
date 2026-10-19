/// Human-readable explanations of common SIP response codes.
class SipCodeHelp {
  const SipCodeHelp(this.title, this.explanation, this.suggestion);
  final String title;
  final String explanation;
  final String suggestion;
}

SipCodeHelp explainSipCode(int code) {
  switch (code) {
    case 400:
      return const SipCodeHelp('Bad request', 'The server could not understand the request.', 'Check the account settings (domain, username, proxy). If it persists, send a SIP trace to your provider.');
    case 401:
      return const SipCodeHelp('Authentication required', 'The server rejected the credentials (or is asking for them).', 'Check the username, authentication username and password. Some providers use a separate "auth ID".');
    case 403:
      return const SipCodeHelp('Forbidden', 'The server understood the request but refuses it: wrong password, account disabled, or your IP is not allowed.', 'Re-enter the password, check the account is active, and confirm your public IP is not blocked (fail2ban/ACL).');
    case 404:
      return const SipCodeHelp('Not found', 'The server does not know this user or number.', 'Check the username and domain; for calls, check the dialled number and dial rules.');
    case 405:
      return const SipCodeHelp('Method not allowed', 'The server does not support this request.', 'Usually harmless for OPTIONS pings. For REGISTER, check you are talking to a SIP registrar.');
    case 407:
      return const SipCodeHelp('Proxy authentication required', 'The outbound proxy needs credentials.', 'Check the account password and outbound proxy settings.');
    case 408:
      return const SipCodeHelp('Request timeout', 'No answer from the server in time.', 'Check the server address and port, firewalls, and try TCP or TLS. Repeated timeouts on UDP only can point to SIP ALG on the router.');
    case 410:
      return const SipCodeHelp('Gone', 'The number no longer exists.', 'Check the dialled number.');
    case 415:
      return const SipCodeHelp('Unsupported media type', 'The other side does not accept the content type or codecs offered.', 'Enable more codecs (e.g. PCMU/PCMA) in Settings > Codecs.');
    case 420:
    case 421:
      return const SipCodeHelp('Extension not supported', 'The server requires a SIP extension this client did not offer.', 'Check the account NAT/ICE/100rel/timers options.');
    case 423:
      return const SipCodeHelp('Interval too brief', 'The registration expiry is shorter than the server allows.', 'Increase the registration expiry in the account settings.');
    case 480:
      return const SipCodeHelp('Temporarily unavailable', 'The user is not registered or cannot be reached right now.', 'Check the other party is registered; on registration, the server may be overloaded: retry later.');
    case 481:
      return const SipCodeHelp('Call/transaction does not exist', 'The server lost the dialog state (e.g. after a restart or network change).', 'Hang up and retry. If frequent, enable session timers.');
    case 482:
    case 483:
      return const SipCodeHelp('Loop detected', 'The request circled between servers.', 'Check forwarding and routing configuration on the PBX.');
    case 484:
      return const SipCodeHelp('Address incomplete', 'The dialled number is too short.', 'Dial the full number or check dial rules.');
    case 486:
      return const SipCodeHelp('Busy here', 'The other party is busy.', 'Try again later.');
    case 487:
      return const SipCodeHelp('Request terminated', 'The call was cancelled before it was answered.', 'Normal when the caller hangs up while it rings.');
    case 488:
      return const SipCodeHelp('Not acceptable here', 'No common codec or encryption setting with the other side.', 'Check codecs and SRTP (a mandatory-SRTP account cannot call a plain-RTP endpoint).');
    case 491:
      return const SipCodeHelp('Request pending', 'Two re-INVITEs collided.', 'Normally retried automatically.');
    case 500:
      return const SipCodeHelp('Server error', 'The server failed internally.', 'Retry later and contact the provider if it continues.');
    case 502:
      return const SipCodeHelp('Bad gateway', 'An upstream server returned an invalid answer.', 'Retry later; contact the provider if it continues.');
    case 503:
      return const SipCodeHelp('Service unavailable', 'The server is overloaded, down, or rejecting this client (rate limit).', 'Wait and retry, check the provider status page, or try another server/port.');
    case 504:
      return const SipCodeHelp('Server timeout', 'An upstream server did not answer in time.', 'Retry later.');
    case 600:
      return const SipCodeHelp('Busy everywhere', 'All destinations are busy.', 'Try again later.');
    case 603:
      return const SipCodeHelp('Declined', 'The other party rejected the call.', 'Nothing to fix: the call was declined.');
    case 604:
      return const SipCodeHelp('Does not exist anywhere', 'The number does not exist.', 'Check the dialled number.');
    case 606:
      return const SipCodeHelp('Not acceptable', 'The other party cannot accept the session as offered.', 'Check codecs and encryption settings.');
  }
  if (code >= 100 && code < 200) return SipCodeHelp('Provisional ($code)', 'The request is being processed.', '');
  if (code >= 200 && code < 300) return SipCodeHelp('Success ($code)', 'The request succeeded.', '');
  if (code >= 300 && code < 400) return SipCodeHelp('Redirected ($code)', 'The destination moved.', 'Check forwarding settings.');
  if (code >= 400 && code < 500) return SipCodeHelp('Client error ($code)', 'The server rejected the request.', 'Check the account and dialled number.');
  if (code >= 500 && code < 600) return SipCodeHelp('Server error ($code)', 'The server failed to process the request.', 'Retry later or contact the provider.');
  if (code >= 600 && code < 700) return SipCodeHelp('Global failure ($code)', 'The request cannot be fulfilled anywhere.', '');
  return SipCodeHelp('No response', 'No SIP response was received.', 'Check the network connection and server address.');
}
