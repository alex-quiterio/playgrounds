"""Converts an adventofcode.com day page (HTML on stdin) to Markdown on stdout.

Only the puzzle <article> blocks are kept. The first line printed is the title.
"""
import html
import re
import sys
from html.parser import HTMLParser


class PuzzleParser(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.depth = 0          # > 0 while inside <article>
        self.out = []
        self.in_pre = False
        self.title = None
        self.in_h2 = False
        self.link_stack = []

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag == "article":
            self.depth += 1
            return
        if not self.depth:
            return
        if tag == "h2":
            self.in_h2 = True
            self.out.append("\n## ")
        elif tag == "p":
            self.out.append("\n\n")
        elif tag == "pre":
            self.in_pre = True
            self.out.append("\n\n```text\n")
        elif tag == "code" and not self.in_pre:
            self.out.append("`")
        elif tag == "em":
            self.out.append("**")
        elif tag == "li":
            self.out.append("\n- ")
        elif tag == "ul":
            self.out.append("\n")
        elif tag == "a":
            href = attrs.get("href", "")
            if href.startswith("/"):
                href = "https://adventofcode.com" + href
            self.link_stack.append(href)
            self.out.append("[")

    def handle_endtag(self, tag):
        if tag == "article":
            self.depth -= 1
            self.out.append("\n")
            return
        if not self.depth:
            return
        if tag == "h2":
            self.in_h2 = False
            self.out.append("\n")
        elif tag == "pre":
            self.in_pre = False
            if self.out and not self.out[-1].endswith("\n"):
                self.out.append("\n")
            self.out.append("```\n")
        elif tag == "code" and not self.in_pre:
            self.out.append("`")
        elif tag == "em":
            self.out.append("**")
        elif tag == "a" and self.link_stack:
            self.out.append("](%s)" % self.link_stack.pop())

    def handle_data(self, data):
        if not self.depth:
            return
        if self.in_h2:
            text = data.strip().strip("-").strip()
            if self.title is None:
                self.title = text
            self.out.append(text)
            return
        if self.in_pre:
            self.out.append(data)
        else:
            self.out.append(re.sub(r"\s+", " ", data))


def main():
    parser = PuzzleParser()
    parser.feed(sys.stdin.read())
    if parser.title is None:
        sys.exit("no puzzle found in the page")
    body = "".join(parser.out)
    body = re.sub(r"\*\*`([^`]*)`\*\*", r"**`\1`**", body)
    body = re.sub(r"\n{3,}", "\n\n", body).strip()
    print(parser.title)
    print(body)


if __name__ == "__main__":
    main()
