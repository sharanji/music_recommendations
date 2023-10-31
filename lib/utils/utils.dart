/// Import the extensions if you prefer the convenience of calling an extension.
import 'package:text_analysis/extensions.dart';

class Utils {
  static findMatchedWord(String term, candidates) {
    final matches = term.matches(candidates);
    return matches;
  }

  static processText(String text, List areaofText) {
    var address = '';
    var domain = '';
    var numbers = '';
    var email = '';
    var names = '';
    var possibleNames = '';
    var industryNames = '';
    var organizationName = '';

    Map data = {};

    try {
      for (var i = 0; i < areaofText.length; i++) {
        bool flag = false;
        RegExp addressPattern = RegExp(
            r"\bindia\b|\b\d{6}\b|\b\d{3} \d{3}\b|\broad\b|\bfloor\b|\b\w+nagar\b|\bplot\b|\bpost\b|\bdist\b|\btaluk\b|\b\w+opp\b|\bline\b|\bno\b|");
        RegExp domainPattern = RegExp(
            r'\bwww\b|/[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)?/gi');
        RegExp numberPattern = RegExp(
            r'\b\d{10}\b|\b\d{5} \d{5}\b|\b\d{12}\b|\b\d{5}-\d{5}\b|\b\d{4} \d{3} \d{3}\b|\b\d{2}-\d{8}\b|\b\d{2} \d{4} \d{4}\b|\b\d{2}-\d{4}-\d{4}\b|\b\w+phone\b|\b\w+044\b');

        RegExp emailPattern = RegExp(
            r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b|\b\w+email:\b|\@');
        RegExp industryPattern = RegExp(
            r'\b\w+ings\b|\b\w+ing\b|\b\w+iers\b|\b\w+ices\b|\b\w+tion\b|\b\w+limited\b');
        RegExp namePattern = RegExp(
            r"\b\w+managing\b|\b\w+director\b|^[A-Za-z\s.'-]{2,40}(?:\s[A-Za-z\s.'-]{2,40})?$");
        areaofText[i][1] = areaofText[i][1].toString().replaceAll('\n', '');

        if (domainPattern.hasMatch(areaofText[i][1].toLowerCase())) {
          var start = domainPattern
              .allMatches(areaofText[i][1].toLowerCase())
              .first
              .start;
          String extractedDomain =
              "$domain${areaofText[i][1].toString().substring(start)}";
          if (extractedDomain != domain) {
            domain += extractedDomain;
          }
          flag = true;
        }

        if (addressPattern.hasMatch(areaofText[i][1].toLowerCase())) {
          var temp = areaofText[i][1]
              .toString()
              .toLowerCase()
              .replaceAll(numberPattern, '')
              .replaceAll(email, '')
              .replaceAll(domain, '')
              .replaceAll('email', '')
              .replaceAll('phone', '')
              .replaceAll('cell', '')
              .replaceAll('tel', '')
              .replaceAll('+91', '')
              .replaceAll(':', '')
              .replaceAll(' | ', '');
          address = '$address$temp';
          flag = true;
        }

        if (emailPattern.hasMatch(areaofText[i][1].toLowerCase())) {
          email =
              '$email ${areaofText[i][1].toString().replaceAll(domainPattern, '')} , ';
          flag = true;
        }

        if (numberPattern.hasMatch(areaofText[i][1].toLowerCase())) {
          var allMatches =
              numberPattern.allMatches(areaofText[i][1].toLowerCase());

          for (var match in allMatches) {
            var startNum = match.start;
            var endNum = match.end;

            String number = areaofText[i][1]
                .toString()
                .substring(startNum, endNum)
                .replaceAll(' ', '');
            if (number.length == 12) {
              number = number.substring(2);
            }
            numbers = "$numbers $number";
          }

          flag = true;
        }

        if (namePattern.hasMatch(areaofText[i][1].toLowerCase()) &&
            !addressPattern.hasMatch(areaofText[i][1].toLowerCase())) {
          // industryNames +
          var nameMatches =
              namePattern.allMatches(areaofText[i][1].toLowerCase());
          for (var match in nameMatches) {
            var startNum = match.start;
            var endNum = match.end;

            String _name = areaofText[i][1]
                .toString()
                // .substring(startNum, endNum)
                .replaceAll(email, '')
                .replaceAll(domainPattern, '')
                .replaceAll(industryPattern, '')
                .replaceAll(numberPattern, '')
                .replaceAll(industryPattern, '');

            names += " ${_name.replaceAll(RegExp(r'\b\d+\b|[+,-]'), '')}";
          }

          flag = true;
        }

        if (industryPattern.hasMatch(areaofText[i][1].toLowerCase())) {
          Iterable<RegExpMatch> industryMatches =
              industryPattern.allMatches(areaofText[i][1].toLowerCase());

          for (RegExpMatch match in industryMatches) {
            if (match.input.length > 50) {
              continue;
            }
            var start = match.start;
            var end = match.end;
            String industry = '${areaofText[i][1].substring(start, end)} - ';

            industryNames += areaofText[i][1]
                .toString()
                .replaceAll(RegExp(r'\b\d+\b|[+,-]'), '');
          }
          flag = true;
        }

        // if (areaofText[i][1].toString().replaceAll(" ", '').length < 45) {
        //   if (domainPattern
        //       .hasMatch(areaofText[i][1].toString().toLowerCase())) {
        //     continue;
        //   }
        //   industryNames +=
        //       "${areaofText[i][1].toString().replaceAll(emailPattern, '').replaceAll(domainPattern, '')} ,";
        // }

        if (!flag) {
          possibleNames += areaofText[i][1] + " -- ";
        }
      }

      // manual processing
      for (var i = 0; i < areaofText.length; i++) {
        List splittesTxt = areaofText[i][1].split(' ');

        List domainSplit = domain.split('.');

        List matches = findMatchedWord(domainSplit[1], splittesTxt);
        for (var m in matches) {
          organizationName += m;
        }

        email.split(RegExp(r'\b@\b|\.')).forEach((element) {
          List matches = findMatchedWord(element, splittesTxt);
          for (var m in matches) {
            names += m;
          }
        });
      }

      names.replaceAll(organizationName, '');

      if (email != '') {
        List splittesTxt = email.split('@');
        if (splittesTxt.length > 1) {
          names = splittesTxt[0];
        }
      }

      text = '$text address : $address \n';
      text = '$text domain : $domain \n';
      text = '$text numbers : $numbers  \n';
      text = '$text Emails : $email  \n';
      text = '$text Industry : $industryNames  \n';
      text = '$text Names : $names  \n';
      text = '$text Possible Names : $possibleNames  \n';
      text = '$text Oranization : $organizationName  \n';

      text = '$text$organizationName';
      text = '$text$names';

      List? splittedEmail = email.split('@');

      data = {
        'names': areaofText[0][1],
        'address': address,
        'numbers': numbers,
        'website': domain,
        'domain': industryNames,
        'email': email,
        'industry': industryNames,
        'keywords': possibleNames,
      };
    } catch (e) {
      return [
        '',
        {
          'names': '',
          'address': address,
          'numbers': numbers,
          'website': domain,
          'domain': industryNames,
          'email': email,
          'industry': industryNames,
          'keywords': possibleNames,
        }
      ];
    }

    return [
      text,
      data,
    ];
  }
}
