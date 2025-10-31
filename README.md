# deneote: sensible note management for neovim

(WIP) Neovim port of the Denote Emacs package. Provides various utilities to
enforce a sensible name scheme on your notes. Under construction, not meant for
public consumption etc. Building for Neorg support first.

## Roadmap

- [x] Redesign component system and clean up API
- [ ] Add suggestions for persistent keywords
- [ ] Add (bulk) renaming of existing files
- [ ] Add search within files, equiv. `denote-dired`
- [ ] Add support for other plain text standards
    - [ ] org
    - [ ] Markdown + YAML
    - [ ] Markdown + TOML
    - [ ] Add fallback behavior for "unsupported" filetypes
- [ ] Add much more granular configuration of plugin behaviors
  - [ ] Allow users to pass in their own hooks to handle unsupported file
    formats
  - [ ] Allow customization of file name template (e.g., removing `T` in the
    ID)
  - [ ] Allow custom definitions for prompts via component system
- [ ] Add backlinking features

## Overview

The Deneote system organizes itself about a central file naming convention.
Here's an example of a typical file outputted by Deneote:

``` 20251028T123846--my-first-note__foo_bar.norg ```

This file stem consists of 3 parts:
1. The string `20251028T123846` is a timestamp that serves as the note's ID.
   This particular note was created on 2025-10-28 at 12:38:46.
2. The string `my-first-note` is a user-defined title for the note (hyphenated
   and all-lowercase).
3. The string `foo_bar` is a list of two keywords `foo` and `bar` delimited by
   underscores.

The ID and title are delimited by a double hyphen `--`; the title and keywords
are delimited by a double underscore `__`.

This is a simple idea, and it makes several key operations and design elements
trivially easy for us to understand and implement. Deneote lends itself well to
the following workflows:

- **Atomic notes.** One file per note, à la the
  [Zettelkasten](https://zettelkasten.de/introduction/) method.
- **Searching and filtering.** By exposing choice types of metadata in the
  filename, we don't need to maintain databases or other overhead to
  effectively index and search our notes: Unix interfaces like
  [ripgrep](https://github.com/BurntSushi/ripgrep) (or Neovim plugins like
  [oil.nvim](https://github.com/stevearc/oil.nvim)) are familiar and plenty
  robust.
- **Standard-agnostic.** The basic functionality of Deneote is compatible with
  any file type, so it can be easily configured to fit your preferred standard,
  or switch between them based on user input. (Adding fully-featured support is
  largely a matter of generating format-specific metadata.)
