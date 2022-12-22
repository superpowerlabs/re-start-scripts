# re-start-scripts

A collection of scripts that we use in most of our web apps.

## Usage

To install or update it in a React repo in the folder bin:

```
curl -o- https://raw.githubusercontent.com/superpowerlabs/re-start-scripts/main/install.sh | bash
```

Later, edit `bin/extra-dependencies.sh` to adapt it to your app, if needed.

Finally, add in the scripts sectionn of package.json
``` 
"postinstall": "bin/post-install.sh"
```
and also the tests like this
```
"test": "npm run test:server; npm run test:client -- --watchAll=false",
"test:server": "mocha --exit",
"test:client": "react-scripts test",
```

## Credits

Author: Francesco Sullo

(c) 2022 Superpowerlabs 
