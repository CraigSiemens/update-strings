# update-strings

A wrapper around `genstrings` that will look through the source code in a project and update Localizable.strings with any missing strings and remove old ones.

## Install
```
brew install CraigSiemens/tap/update-strings
```

Finds all the uses of `NSLocalizedString(...)` in you sources and updated your existing strings files to have have to new strings or remove old strings.
```
update-strings -s path/to/source -o path/to/en.lproj
```

Finds all the strings files in the directoy and sorts their contents by key.
```
update-strings sort Modules/
```
