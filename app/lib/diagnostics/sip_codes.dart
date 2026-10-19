import '../l10n/l10n.dart';

/// Human-readable explanations of common SIP response codes. The title is the
/// standard SIP reason phrase (a protocol token, not translated); the
/// explanation and suggestion are localised.
class SipCodeHelp {
  const SipCodeHelp(this.title, this.explanation, this.suggestion);
  final String title;
  final String explanation;
  final String suggestion;
}

SipCodeHelp explainSipCode(int code, AppLocalizations l) {
  switch (code) {
    case 400:
      return SipCodeHelp('Bad request', l.diagSip400Explain, l.diagSip400Fix);
    case 401:
      return SipCodeHelp('Authentication required', l.diagSip401Explain, l.diagSip401Fix);
    case 403:
      return SipCodeHelp('Forbidden', l.diagSip403Explain, l.diagSip403Fix);
    case 404:
      return SipCodeHelp('Not found', l.diagSip404Explain, l.diagSip404Fix);
    case 405:
      return SipCodeHelp('Method not allowed', l.diagSip405Explain, l.diagSip405Fix);
    case 407:
      return SipCodeHelp('Proxy authentication required', l.diagSip407Explain, l.diagSip407Fix);
    case 408:
      return SipCodeHelp('Request timeout', l.diagSip408Explain, l.diagSip408Fix);
    case 410:
      return SipCodeHelp('Gone', l.diagSip410Explain, l.diagSip410Fix);
    case 415:
      return SipCodeHelp('Unsupported media type', l.diagSip415Explain, l.diagSip415Fix);
    case 420:
    case 421:
      return SipCodeHelp('Extension not supported', l.diagSip421Explain, l.diagSip421Fix);
    case 423:
      return SipCodeHelp('Interval too brief', l.diagSip423Explain, l.diagSip423Fix);
    case 480:
      return SipCodeHelp('Temporarily unavailable', l.diagSip480Explain, l.diagSip480Fix);
    case 481:
      return SipCodeHelp('Call/transaction does not exist', l.diagSip481Explain, l.diagSip481Fix);
    case 482:
    case 483:
      return SipCodeHelp('Loop detected', l.diagSip483Explain, l.diagSip483Fix);
    case 484:
      return SipCodeHelp('Address incomplete', l.diagSip484Explain, l.diagSip484Fix);
    case 486:
      return SipCodeHelp('Busy here', l.diagSip486Explain, l.diagSip486Fix);
    case 487:
      return SipCodeHelp('Request terminated', l.diagSip487Explain, l.diagSip487Fix);
    case 488:
      return SipCodeHelp('Not acceptable here', l.diagSip488Explain, l.diagSip488Fix);
    case 491:
      return SipCodeHelp('Request pending', l.diagSip491Explain, l.diagSip491Fix);
    case 500:
      return SipCodeHelp('Server error', l.diagSip500Explain, l.diagSip500Fix);
    case 502:
      return SipCodeHelp('Bad gateway', l.diagSip502Explain, l.diagSip502Fix);
    case 503:
      return SipCodeHelp('Service unavailable', l.diagSip503Explain, l.diagSip503Fix);
    case 504:
      return SipCodeHelp('Server timeout', l.diagSip504Explain, l.diagSip504Fix);
    case 600:
      return SipCodeHelp('Busy everywhere', l.diagSip600Explain, l.diagSip600Fix);
    case 603:
      return SipCodeHelp('Declined', l.diagSip603Explain, l.diagSip603Fix);
    case 604:
      return SipCodeHelp('Does not exist anywhere', l.diagSip604Explain, l.diagSip604Fix);
    case 606:
      return SipCodeHelp('Not acceptable', l.diagSip606Explain, l.diagSip606Fix);
  }
  if (code >= 100 && code < 200) return SipCodeHelp(l.diagSipProvisionalTitle(code), l.diagSipProvisionalExplain, '');
  if (code >= 200 && code < 300) return SipCodeHelp(l.diagSipSuccessTitle(code), l.diagSipSuccessExplain, '');
  if (code >= 300 && code < 400) return SipCodeHelp(l.diagSipRedirectedTitle(code), l.diagSipRedirectedExplain, l.diagSipRedirectedFix);
  if (code >= 400 && code < 500) return SipCodeHelp(l.diagSipClientErrorTitle(code), l.diagSipClientErrorExplain, l.diagSipClientErrorFix);
  if (code >= 500 && code < 600) return SipCodeHelp(l.diagSipServerErrorTitle(code), l.diagSipServerErrorExplain, l.diagSipServerErrorFix);
  if (code >= 600 && code < 700) return SipCodeHelp(l.diagSipGlobalFailureTitle(code), l.diagSipGlobalFailureExplain, '');
  return SipCodeHelp(l.diagSipNoResponseTitle, l.diagSipNoResponseExplain, l.diagSipNoResponseFix);
}
