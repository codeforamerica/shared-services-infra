FROM squidfunk/mkdocs-material:9.6

# Install additional plugins for MkDocs.
RUN pip install markdown-callouts mdx_truly_sane_lists mkdocs-nav-weight

USER guest
