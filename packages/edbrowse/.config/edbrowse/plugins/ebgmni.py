#!/usr/bin/env python3
import argparse
import base64
import getpass
import ignition  # pip install ignition-gemini
import os
import sys

from collections import namedtuple
from cryptography.hazmat.primitives.serialization import Encoding
from urllib import parse

MAX_REDIRECTS = 3


def escape_html(html):
    html = html.replace('&', '&amp;')
    html = html.replace('<', '&lt;')
    html = html.replace('>', '&gt;')
    html = html.replace('"', '&quot;')
    html = html.replace("'", '&#039;')

    return html

def gmi_to_html(data, url=None, lang=None, cert=None, **_):
    Mode = namedtuple('Mode', ['name', 'open', 'close'])
    INITIAL_MODE = Mode('initial', None, None)
    DEFAULT_MODE = Mode('default', None, None)
    BLOCKQUOTE_MODE = Mode('blockquote', '<blockquote><p>',
                           '</p></blockquote>\n')
    HEADING_MODE = Mode('heading', None, None)
    LIST_MODE = Mode('list', '<ul>\n', '</ul>\n')
    PARAGRAPH_MODE = Mode('paragraph', '<p>', '</p>\n')
    PRE_FORMATTED_MODE = Mode('pre_formatted', '<figure>\n<pre><code>',
                              '</code></pre>\n</figure>\n')

    html_parts = []
    title = None
    last_mode = INITIAL_MODE
    new_mode = INITIAL_MODE

    for line in data.splitlines():
        if last_mode == PRE_FORMATTED_MODE:
            if line.startswith('```'):
                html_parts.append(last_mode.close)
                last_mode = DEFAULT_MODE
            else:
                html_parts.append(f"{escape_html(line)}\n")
            continue

        html_part = None
        heading = None
        caption = None

        if line.startswith('###'):
            new_mode = HEADING_MODE
            heading = escape_html(line[3:]).strip()
            html_part = f"<h3>{heading}</h3>\n"

        elif line.startswith('##'):
            new_mode = HEADING_MODE
            heading = escape_html(line[2:]).strip()
            html_part = f"<h2>{heading}</h2>\n"

        elif line.startswith('#'):
            new_mode = HEADING_MODE
            heading = escape_html(line[1:]).strip()
            html_part = f"<h1>{heading}</h1>\n"

        elif line.startswith('```'):
            new_mode = PRE_FORMATTED_MODE
            caption = escape_html(line[3:]).strip()

        elif line.startswith("=>"):
            link_tokens = line[2:].strip().split(maxsplit=1)
            if link_tokens:
                new_mode = LIST_MODE
                link_url = ignition.url(link_tokens[0], url)
                link_url = link_url.replace('"', '%22')
                link_url = link_url.replace("'", '%27')
                link_url = link_url.replace('<', '%3c')
                link_url = link_url.replace('>', '%3e')
                link_title = escape_html(link_tokens[-1])
                html_part = f'<li><a href="{link_url}">{link_title}</a>\n'

        elif line.startswith("*"):
            new_mode = LIST_MODE
            html_part = f"<li>{escape_html(line[1:].strip())}\n"

        elif line.startswith('>'):
            new_mode = BLOCKQUOTE_MODE
            # two line breaks followed by a non blank line starts a new paragraph.
            if (last_mode == new_mode and len(html_parts) >= 2
                    and html_parts[-2].endswith('<br>\n')
                    and html_parts[-1] == '<br>\n' and line.strip() != ''):
                html_parts.pop()
                html_parts[-1] = html_parts[-1][:-5] + "</p>\n<p>"
            html_part = f"{escape_html(line[1:].strip())}<br>\n"

        else:
            new_mode = PARAGRAPH_MODE
            # two line breaks followed by a non blank line starts a new paragraph.
            if (last_mode == new_mode and len(html_parts) >= 2
                    and html_parts[-2].endswith('<br>\n')
                    and html_parts[-1] == '<br>\n' and line.strip() != ''):
                html_parts.pop()
                html_parts[-1] = html_parts[-1][:-5] + "</p>\n<p>"
            # Don't output the first blank line after a mode change. It's
            # common to include a blank line between a
            # heading/list/pre formatted block and a paragraph, but this
            # shouldn't show up in the HTML.
            if (new_mode == last_mode or last_mode == INITIAL_MODE
                    or line.strip() != ''):
                html_part = f"{escape_html(line.strip())}<br>\n"

        if heading and not title:
            title = heading

        # If the mode has changed, close the old and open the new mode
        if new_mode != last_mode:
            # It's common to insert a blank line before headings, listts, and
            # preformatted blocks. We don't want this in the HTML.
            if html_parts and html_parts[-1] == '<br>\n':
                html_parts.pop()
            # The last paragraph or blockquote will always end with a line break. Strip it out.
            if html_parts and html_parts[-1].endswith('<br>\n'):
                html_parts[-1] = html_parts[-1][:-5]
            if last_mode.close:
                html_parts.append(last_mode.close)
            # Blank lines between headings, lists, quotes, etc, will result in
            # an empty paragraph. We don't want these.
            if (len(html_parts) >= 2 and html_parts[-2] == PARAGRAPH_MODE.open
                    and html_parts[-1] == PARAGRAPH_MODE.close):
                html_parts = html_parts[:-2]
            if new_mode.open:
                html_parts.append(new_mode.open)
            if new_mode == PRE_FORMATTED_MODE and caption:
                html_parts[
                    -1] = f"<figure>\n<figcaption>{caption}</figcaption>\n{html_parts[-1][9:]}"

        if html_part:
            html_parts.append(html_part)

        last_mode = new_mode

    if html_parts and html_parts[-1].endswith('<br>\n'):
        html_parts[-1] = html_parts[-1][:-5]

    root_url, up_url = None, None
    if url:
        url_unpacked = parse.urlsplit(url, scheme='gemini')
        root_url = parse.urlunsplit(
            (url_unpacked.scheme, url_unpacked.netloc, '/', '', ''))
        up_url = ignition.url('.', url.rstrip('/'))

    html_out = "<!DOCTYPE html>\n"
    if lang:
        html_out += f"<html lang=\"{lang}\">\n"
    html_out += f"<meta charset=\"utf-8\">\n"
    if title:
        html_out += f"<title>{title}</title>\n"
    if url:
        html_out += "<nav>\n"
        html_out += f"<a href=\"{root_url}\">/</a>"
        html_out += f" | <a href=\"{up_url}\">Up</a>"
        html_out += f" | <a href=\"{url}\">.</a>"
        if cert:
            cert_b64 = base64.urlsafe_b64encode(cert.public_bytes(Encoding.DER))
            html_out += f" | <a href=\"x509certb64://{cert_b64.decode()}\">Certificate</a>"
        html_out += "\n</nav>\n<hr>\n"
    html_out += "<main>\n"
    html_out += ''.join(html_parts)
    html_out += "</main>\n"

    return html_out


def process_url(url, cacert_file=None, cacert_key=None):
    referer = None
    num_redirects = 0
    ca_cert = None
    if cacert_file and cacert_key:
        ca_cert = (cacert_file, cacert_key)

    while True:
        resp = ignition.request(url, referer=referer, ca_cert=ca_cert)
        if not resp.is_a(ignition.RedirectResponse):
            break
        url = resp.data()
        referer = resp.url
        num_redirects += 1
        if num_redirects > MAX_REDIRECTS:
            print("Too many redirects", file=sys.stderr)
            return 2

    if resp.is_a(ignition.InputResponse):
        print(f"{resp.data()}: ", end='', file=sys.stderr)
        if resp.status == 11:
            answer = getpass.getpass()
        else:
            answer = input()

        process_url(ignition.url('?' + parse.quote(answer), resp.url),
                    cacert_file, cacert_key)

    elif resp.is_a(ignition.TempFailureResponse) or resp.is_a(
            ignition.PermFailureResponse):
        print("Error from server:", resp.data(), file=sys.stderr)
        return 4
    elif resp.is_a(ignition.ClientCertRequiredResponse):
        print("Client certificate required:", resp.data(), file=sys.stderr)
        return 5
    elif resp.is_a(ignition.ErrorResponse):
        print("The request had an error:", resp.data(), file=sys.stderr)
        return 6
    elif resp.is_a(ignition.SuccessResponse):
        # Detect the media type, and handle text/gemini responses
        media_type, *params = (token.strip() for token in resp.meta.split(';'))
        params = dict(param.split('=', 1) for param in params if '=' in param)
        # parameter names are case insensitive
        params = {k.lower(): v for k, v in params.items()}
        # And so is charset
        if 'charset' in params:
            params['charset'] = params['charset'].lower()
        if media_type == 'text/gemini':
            print(gmi_to_html(resp.data(), resp.url, None, resp.certificate, **params))
        else:
            fp = os.fdopen(sys.stdout.fileno(), 'wb')
            fp.write(resp.raw_body)
            fp.flush()
    else:
        print("Unexpected response type", file=sys.stderr)
        return 7

    return 0


def main():
    parser = argparse.ArgumentParser(description='Gemini to HTML user agent')
    parser.add_argument(
        '-c',
        '--cacert-file',
        help='Location of the client certificate to use in requests')
    parser.add_argument('-C',
                        '--cacert-key',
                        help='Location to the client certificate key')
    parser.add_argument(
        '-H',
        '--known-hosts',
        help=
        'Location of a file containing hosts and certificate fingerprints, for trust on first use',
        default=os.path.expanduser('~/.ebgmni_known_hosts'))
    parser.add_argument('url', help='URL to request')
    args = parser.parse_args()

    if args.cacert_file and not args.cacert_key:
        print("A cacert file was provided, but no cacert key was specified",
              file=sys.stderr)
        sys.exit(1)

    ignition.set_default_hosts_file(args.known_hosts)

    sys.exit(process_url(args.url, args.cacert_file, args.cacert_key))


if __name__ == '__main__':
    main()
