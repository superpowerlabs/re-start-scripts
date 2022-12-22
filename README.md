# re-start-scripts


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

## Credits

Author: Francesco Sullo

(c) 2022 Superpowerlabs 
