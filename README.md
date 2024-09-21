markdown-easy
===========================

[![CI ubuntu badge](https://github.com/rreece/markdown-easy/actions/workflows/ci-ubuntu.yml/badge.svg)](https://github.com/rreece/markdown-easy/actions/workflows/ci-ubuntu.yml)
[![CI macos badge](https://github.com/rreece/markdown-easy/actions/workflows/ci-macos.yml/badge.svg)](https://github.com/rreece/markdown-easy/actions/workflows/ci-macos.yml)
[![CI windows badge](https://github.com/rreece/markdown-easy/actions/workflows/ci-windows.yml/badge.svg)](https://github.com/rreece/markdown-easy/actions/workflows/ci-windows.yml)

Easy way to compile markdown into documents.

*NOTE: This is work in progress.
I have a new motivation to clean up this project.
Please let me know if you find it useful.*

This project is meant to make writing easier and more productive.

So you want to write a document.
Maybe you'll share it on the web.
Maybe you want a polished pdf. 
Maybe it's a blog, research paper, book draft, or just a set of notes.
You don't want to think about typesetting details.
You just want to throw your ideas in some plain text files and call `make`.


Quick start
----------------------------------

Installation:

I'll write installation instructions another time. For now, you can see
hints in how the GitHub runner does the installation in the CI:
[`workflows/ci-ubuntu.yml`](https://github.com/rreece/markdown-easy/blob/main/.github/workflows/ci-ubuntu.yml), 
[`workflows/ci-macos.yml`](https://github.com/rreece/markdown-easy/blob/main/.github/workflows/ci-macos.yml), and 
[`workflows/ci-windows.yml`](https://github.com/rreece/markdown-easy/blob/main/.github/workflows/ci-windows.yml).

Starting a new document:

*Note: This will delete the markdown files in this example.*

```
make newdoc
```

Start writing with a text editor.
A first example file is created for you: `01-introduction.md`,
but you can structure your markdown files however you like.

When you are ready to make the document, call

```
make html
```

or

```
make pdf
```

*More explanation to come...*


See also
----------------------------------

-   [rreece.github.io/sw/markdown-memo](http://rreece.github.io/sw/markdown-memo)
-   [pandoc.org/README.html](http://pandoc.org/README.html)
-   [commonmark.org](http://commonmark.org/)
-   [github.com/lierdakil/pandoc-crossref](https://github.com/lierdakil/pandoc-crossref)

Other examples/blogs of writing with markdown:

-   [programminghistorian.org/lessons/sustainable-authorship-in-plain-text-using-pandoc-and-markdown](http://programminghistorian.org/lessons/sustainable-authorship-in-plain-text-using-pandoc-and-markdown)
-   [kprussing.github.io/writing-with-markdown](https://web.archive.org/web/20171026174128/http://kprussing.github.io/writing-with-markdown/)
-   [scholarlymarkdown.com](http://scholarlymarkdown.com/)
-   [github.com/simov/markdown-syntax](https://github.com/simov/markdown-syntax/blob/main/mermaid.md)
-   [markdownguide.org](https://www.markdownguide.org/getting-started/) --- source: [github.com/mattcone/markdown-guide-book](https://github.com/mattcone/markdown-guide-book/blob/master/manuscript/chapter3.md)
-   [github.com/gabyx/Technical-Markdown](https://github.com/gabyx/Technical-Markdown)
-   [mdBook](https://rust-lang.github.io/mdBook/)
-   [MkDocs](https://www.mkdocs.org/)


Author
----------------------------------

Ryan Reece ([@rreece](https://github.com/rreece))         
Created: October 26, 2023

